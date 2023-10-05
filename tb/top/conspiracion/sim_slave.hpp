#ifndef TALLER_SIM_SLAVE_HPP
#define TALLER_SIM_SLAVE_HPP

#include <cstdint>

#include "Vtop_sim_slave.h"

#include "avalon.hpp"

namespace taller::avalon
{
	using verilated_slave = Vtop_sim_slave;

	class sim_slave : public slave
	{
		public:
			sim_slave(verilated_slave &dev, std::uint32_t base, std::uint32_t size);

			virtual void tick() noexcept final override;
			virtual void tick_falling() noexcept final override;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) final override;

			virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override;

		private:
			verilated_slave &dev;
			bool             latch;
			std::uint32_t    latch_readdata;
	};
}

#endif
