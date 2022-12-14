#include <cstdint>

#include "avalon.hpp"
#include "interval_timer.hpp"

namespace taller::avalon
{
	interval_timer::interval_timer(std::uint32_t base) noexcept
	: slave(base, 32, 4)
	{}

	void interval_timer::tick() noexcept
	{
		if(!status_run)
		{
			return;
		} else if(count > 0)
		{
			--count;
		} else
		{
			count = period;
			status_to = 1;
			status_run = control_cont;
		}
	}

	bool interval_timer::read(std::uint32_t addr, std::uint32_t &data) noexcept
	{
		switch(addr)
		{
			case 0:
				data
					= status_run << 1
					| status_to  << 0;

				break;

			case 1:
				data
					= control_cont << 1
					| control_ito  << 0;

				break;

			case 2:
				data = period & 0xffff;
				break;

			case 3:
				data = period >> 16;
				break;

			case 4:
				data = snap & 0xffff;
				break;

			case 5:
				data = snap >> 16;
				break;
		}

		return true;
	}

	bool interval_timer::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept
	{
		switch(addr)
		{
			case 0:
				status_to = 0;
				break;

			case 1:
				control_ito = !!(data & (1 << 0));
				control_cont = !!(data & (1 << 1));

				status_run = (status_run && !!(data << (1 << 3))) || !!(data << (1 << 2));
				break;

			case 2:
				period = (period & 0xffff'0000) | (data & 0xffff);
				count = period;
				break;

			case 3:
				period = (period & 0xffff) | (data & 0xffff) << 16;
				count = period;
				break;

			case 4:
			case 5:
				snap = count;
				break;
		}

		return true;
	}

	bool interval_timer::irq() noexcept
	{
		return control_ito && status_to;
	}
}
