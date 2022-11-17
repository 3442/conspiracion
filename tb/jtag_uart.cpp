#include "avalon.hpp"
#include "jtag_uart.hpp"

namespace taller::avalon
{
	jtag_uart::jtag_uart(std::uint32_t base) noexcept
	: slave(base, 8, 4)
	{}

	bool jtag_uart::read(std::uint32_t addr, std::uint32_t &data) noexcept
	{
		switch(addr)
		{
			case 0:
				data = 0; //TODO
				break;

			case 1:
				data =
					  static_cast<std::uint32_t>(ctrl_re) << 0
					| static_cast<std::uint32_t>(ctrl_we) << 1
					//TODO: varios bits
					| static_cast<std::uint32_t>(ctrl_ac) << 10
					//TODO: disponibilidad de tx fifo
					| static_cast<std::uint32_t>(255) << 10;

				break;
		}

		return true;
	}

	bool jtag_uart::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept
	{
		switch(addr)
		{
			case 0:
				putchar(data & 0xff);
				ctrl_ac = 1;
				break;

			case 1:
				ctrl_re = !!(data & (1 << 0));
				ctrl_we = !!(data & (1 << 1));
				if(!!(data & (1 << 10)))
				{
					ctrl_ac = 0;
				}

				break;
		}

		return true;
	}
}
