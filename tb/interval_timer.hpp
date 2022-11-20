#ifndef TALLER_INTERVAL_TIMER_HPP
#define TALLER_INTERVAL_TIMER_HPP

#include <cstdint>

#include "avalon.hpp"

namespace taller::avalon
{
	class interval_timer : public slave
	{
		public:
			interval_timer(std::uint32_t base) noexcept;

			virtual void tick() noexcept final override;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) noexcept final override;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept final override;

		private:
			std::uint32_t count;
			std::uint32_t period;
			std::uint32_t snap;
			bool          status_to = false;
			bool          status_run = false;
			bool          control_ito = false;
			bool          control_cont = false;
	};
}

#endif
