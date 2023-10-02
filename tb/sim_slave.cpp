#include <cstdint>

#include "avalon.hpp"
#include "sim_slave.hpp"

namespace taller::avalon
{
	sim_slave::sim_slave(verilated_slave &dev, std::uint32_t base, std::uint32_t size)
	: slave(base, size, 4),
	  dev(dev)
	{
		dev.avl_read = 0;
		dev.avl_write = 0;
	}

	void sim_slave::tick() noexcept
	{
		if (latch) {
			dev.avl_read = 0;
			dev.avl_write = 0;
		}
	}

	void sim_slave::tick_falling() noexcept
	{
		if ((dev.avl_read || dev.avl_write) && !dev.avl_waitrequest) {
			latch = true;
			latch_readdata = dev.avl_readdata;
		}
	}

	bool sim_slave::read(std::uint32_t addr, std::uint32_t &data)
	{
		if (latch) {
			data = latch_readdata;

			latch = false;
			return true;
		} else if (!dev.avl_read && !dev.avl_write) {
			dev.avl_read = 1;
			dev.avl_address = addr;
		}

		return false;
	}

	bool sim_slave::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable)
	{
		if (latch) {
			latch = false;
			return true;
		} else if (!dev.avl_read && !dev.avl_write) {
			dev.avl_write = 1;
			dev.avl_address = addr;
			dev.avl_writedata = data;
		}

		return false;
	}
}
