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

			virtual bool read(std::uint32_t addr, std::uint32_t &data) final override;
			virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override;

			template<typename F>
			void load(F loader, std::size_t addr = 0);

		private:
			std::unique_ptr<std::uint32_t[]> block;
			std::uint32_t                    base;
			std::uint32_t                    mask;
			unsigned                         count = 0;

			bool ready() noexcept;
	};

	template<typename F>
	void mem::load(F loader, std::size_t addr)
	{
		std::size_t size = mask + 1;
		while(addr < size)
		{
			std::size_t read = loader(&block[base + addr], size - addr);
			if(read == 0)
			{
				break;
			}

			addr += read;
		}
	}
}

#endif
