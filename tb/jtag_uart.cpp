#include <cstdint>

#include <ncursesw/ncurses.h>

#include "avalon.hpp"
#include "jtag_uart.hpp"

namespace taller::avalon
{
	jtag_uart::jtag_uart(std::uint32_t base) noexcept
	: slave(base, 8, 4)
	{}

	jtag_uart::~jtag_uart() noexcept
	{
		release();
	}

	void jtag_uart::tick() noexcept
	{
		if(!took_over || rx_avail == sizeof rx)
		{
			return;
		}

		if(countdown > 0)
		{
			--countdown;
			return;
		}

		countdown = 10'000;

		int input = getch();
		if(input != ERR)
		{
			unsigned index = rx_next + rx_avail;
			if(index >= sizeof rx)
			{
				index -= sizeof rx;
			}

			rx[index] = input;
			++rx_avail;
		}

		ctrl_ac = 1;
	}

	bool jtag_uart::read(std::uint32_t addr, std::uint32_t &data) noexcept
	{
		bool valid_read;
		bool ctrl_ri;
		bool ctrl_wi;
		bool ctrl_rrdy;

		std::uint8_t read;

		switch(addr)
		{
			case 0:
				read = rx[rx_next];
				valid_read = rx_avail > 0;

				if(valid_read)
				{
					--rx_avail;
					rx_next = rx_next + 1 < sizeof rx ? rx_next + 1 : 0;
				}

				data
					= rx_avail   << 16
					| valid_read << 15
					| (read & 0xff);

				break;

			case 1:
				ctrl_ri = ctrl_re && rx_avail > 0;

				// Siempre se puede escribir
				ctrl_wi = ctrl_we;

				// Este bit no existe pero U-Boot lo espera por alguna razón
				ctrl_rrdy = rx_avail > 0;

				data
					= ctrl_re   << 0
					| ctrl_we   << 1
					| ctrl_ri   << 8
					| ctrl_wi   << 9
					| ctrl_ac   << 10
					| ctrl_rrdy << 12
					| 63        << 16;

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
				fflush(stdout);

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

	void jtag_uart::takeover() noexcept
	{
		if(took_over)
		{
			return;
		}

		assert(::initscr() != nullptr);
		assert(::noecho() != ERR);
		assert(::nodelay(stdscr, TRUE) != ERR);
		assert(::cbreak() != ERR);

		took_over = true;
	}

	void jtag_uart::release() noexcept
	{
		if(took_over)
		{
			::endwin();
			putchar('\n');
		}
	}
}
