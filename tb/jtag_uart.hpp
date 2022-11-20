#ifndef TALLER_JTAG_UART_HPP
#define TALLER_JTAG_UART_HPP

#include <cstdint>

#include "avalon.hpp"

namespace taller::avalon
{
	class jtag_uart : public slave
	{
		public:
			jtag_uart(std::uint32_t base) noexcept;
			~jtag_uart() noexcept;

			virtual void tick() noexcept final override;

			inline virtual void bail() noexcept final override
			{
				release();
			}

			virtual bool read(std::uint32_t addr, std::uint32_t &data) noexcept final override;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept final override;

			void takeover() noexcept;
			void release() noexcept;

		private:
			unsigned     countdown = 0;
			unsigned     rx_avail  = 0;
			unsigned     rx_next   = 0;
			bool         ctrl_re   = false;
			bool         ctrl_we   = false;
			bool         ctrl_ac   = true;
			bool         took_over = false;
			std::uint8_t rx[64];
	};
}

#endif
