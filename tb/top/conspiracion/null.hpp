#ifndef TALLER_NULL_HPP
#define TALLER_NULL_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	class null : public slave
	{
		public:
			using slave::slave;

			inline virtual bool read(std::uint32_t addr, std::uint32_t &data) final override
			{
				return true;
			}

			inline virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override
			{
				return true;
			}
	};
}

#endif
