#include <cassert>
#include <cstdint>
#include <memory>

#include "avalon.hpp"
#include "mem.hpp"

namespace taller::avalon
{
	mem::mem(std::uint32_t base, std::uint32_t size)
	: slave(base, size, 4),
	  block(std::make_unique<line[]>(size >> 4))
	{}

	bool mem::read_line(std::uint32_t addr, line &data, unsigned byte_enable [[maybe_unused]])
	{
		data = block[addr];
		return true;/*ready();*/
	}

	bool mem::write_line(std::uint32_t addr, const line &data, unsigned byte_enable)
	{
		for (unsigned i = 0; i < 4; ++i) {
			std::uint32_t bytes = 0;

			if (byte_enable & 0b1000)
				bytes |= 0xff << 24;

			if (byte_enable & 0b0100)
				bytes |= 0xff << 16;

			if (byte_enable & 0b0010)
				bytes |= 0xff << 8;

			if (byte_enable & 0b0001)
				bytes |= 0xff;

			byte_enable >>= 4;
			block[addr].words[i] = (data.words[i] & bytes) | (block[addr].words[i] & ~bytes);
		}

		return true;/*ready();*/
	}

	bool mem::ready() noexcept
	{
		count = count > 0 ? count - 1 : 2;
		return count == 0;
	}
}
