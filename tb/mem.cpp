#include <cassert>
#include <cstdint>
#include <memory>

#include "mem.hpp"

namespace taller::avalon
{
	mem::mem(std::uint32_t base, std::uint32_t size)
	: base(base), mask(~(size - 1)),
	  block(std::make_unique<std::uint32_t[]>(size >> 2))
	{
		assert(!(size & 0b11) && !((size - 1) & size));
	}

	bool mem::read(std::uint32_t addr, std::uint32_t &data)
	{
		data = block[addr];
		return true;
	}

	bool mem::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable)
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
		return true;
	}
}
