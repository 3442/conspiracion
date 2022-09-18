#ifndef MEM_HPP
#define MEM_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	class mem : public slave
	{
		public:
			mem(std::uint32_t base, std::uint32_t size);

			virtual inline std::uint32_t base_address() noexcept final override
			{
				return base;
			}

			virtual inline std::uint32_t address_mask() noexcept final override
			{
				return mask;
			}

			virtual bool read(std::uint32_t addr, std::uint32_t &data);
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable);

		private:
			std::unique_ptr<std::uint32_t[]> block;
			std::uint32_t                    base;
			std::uint32_t                    mask;
	};
}

#endif
