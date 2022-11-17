#ifndef TALLER_CONST_HPP
#define TALLER_CONST_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	class const_map : public slave
	{
		public:
			inline const_map(std::uint32_t addr, std::uint32_t value, std::uint32_t size = 4) noexcept
			: slave(addr, size, 4),
			  value(value)
			{}

			inline virtual bool read(std::uint32_t addr, std::uint32_t &data) final override
			{
				data = value;
				return true;
			}

			inline virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override
			{
				return true;
			}

		private:
			std::uint32_t value;
	};
}

#endif
