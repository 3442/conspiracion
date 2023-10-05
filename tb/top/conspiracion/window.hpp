#ifndef TALLER_wINDOW_HPP
#define TALLER_wINDOW_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	class window : public slave
	{
		public:
			inline window(slave &downstream, std::uint32_t base)
			: slave(base, downstream.address_span(), downstream.word_size()),
			  downstream(downstream)
			{}

			inline virtual bool read(std::uint32_t addr, std::uint32_t &data) final override
			{
				return downstream.read(addr, data);
			}

			inline virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override
			{
				return downstream.write(addr, data, byte_enable);
			}

		private:
			slave &downstream;
	};
}

#endif
