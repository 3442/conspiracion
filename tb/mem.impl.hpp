#ifndef TALLER_MEM_IMPL_HPP
#define TALLER_MEM_IMPL_HPP

#include <cassert>
#include <cstdint>
#include <memory>

namespace taller::avalon
{
	template<typename Cell>
	mem<Cell>::mem(std::uint32_t base, std::uint32_t size)
	: slave(base, size, sizeof(Cell)),
	  block(std::make_unique<Cell[]>(size >> word_bits()))
	{}

	template<typename Cell>
	template<typename F>
	void mem<Cell>::load(F loader, std::size_t offset)
	{
		auto base = base_address();
		auto bits = word_bits();
		std::size_t size = address_span();
		std::size_t addr = base_address() + offset;

		while(addr >= base && addr < base + size)
		{
			std::size_t read = loader(&block[(addr - base) >> bits], (base + size - addr) >> bits);
			if(read == 0)
			{
				break;
			}

			addr += read << bits;
		}
	}

	template<typename Cell>
	bool mem<Cell>::read(std::uint32_t addr, std::uint32_t &data)
	{
		data = block[addr];
		return ready();
	}

	template<typename Cell>
	bool mem<Cell>::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable)
	{
		std::uint32_t bytes = 0;

		if(byte_enable & 0b1000)
		{
			bytes |= 0xff << 24;
		}

		if(byte_enable & 0b0100)
		{
			bytes |= 0xff << 16;
		}

		if(byte_enable & 0b0010)
		{
			bytes |= 0xff << 8;
		}

		if(byte_enable & 0b0001)
		{
			bytes |= 0xff;
		}

		block[addr] = (data & bytes) | (block[addr] & ~bytes);
		return ready();
	}

	template<typename Cell>
	bool mem<Cell>::ready() noexcept
	{
		count = count > 0 ? count - 1 : 2;
		return count == 0;
	}
}

#endif
