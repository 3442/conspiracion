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

			virtual bool read(std::uint32_t addr, std::uint32_t &data) noexcept final override;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept final override;

		private:
			bool ctrl_re = false;
			bool ctrl_we = false;
			bool ctrl_ac = true;
	};
}

#endif
