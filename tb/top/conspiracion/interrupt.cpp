#include <cstdint>

#include "avalon.hpp"

namespace taller::avalon
{
	interrupt_controller::interrupt_controller(std::uint32_t base) noexcept
	: slave(base, 8, 4)
	{}

	bool interrupt_controller::read(std::uint32_t addr, std::uint32_t &data) noexcept
	{
		switch(addr)
		{
			case 0:
				data = status();
				break;

			case 1:
				data = mask;
				break;
		}

		return true;
	}

	bool interrupt_controller::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept
	{
		switch(addr)
		{
			case 0:
				break;

			case 1:
				mask = data;
				break;
		}

		return true;
	}

	bool interrupt_controller::irq() noexcept
	{
		return status() != 0;
	}

	std::uint32_t interrupt_controller::status() noexcept
	{
		std::uint32_t lines = 0;

		if(irqs.timer)
		{
			lines |= irqs.timer->irq() << 0;
		}

		if(irqs.jtaguart)
		{
			lines |= irqs.jtaguart->irq() << 1;
		}

		return lines & mask;
	}
}
