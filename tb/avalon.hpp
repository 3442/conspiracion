#ifndef TALLER_AVALON_HPP
#define TALLER_AVALON_HPP

#include <cassert>
#include <cstdint>
#include <cstdio>
#include <vector>

namespace taller::avalon
{
	class slave
	{
		public:
			inline slave(std::uint32_t base, std::uint32_t size, std::size_t word_size)
			: base(base),
			  mask(~(size - 1)),
			  word(log2i(word_size))
			{
				assert(!((word_size - 1) & word_size));
				assert(!(base & word_mask()) && !(size & word_mask()) && !((size - 1) & size));
			}

			inline std::uint32_t base_address() noexcept
			{
				return base;
			}

			inline std::uint32_t address_mask() noexcept
			{
				return mask;
			}

			inline std::uint32_t word_mask() noexcept
			{
				return (1 << word) - 1;
			}

			inline std::size_t word_size() noexcept
			{
				return 1 << word;
			}

			inline unsigned word_bits() noexcept
			{
				return word;
			}

			inline std::uint32_t address_span() noexcept
			{
				return ~mask + 1;
			}

			inline virtual void tick() noexcept
			{}

			inline virtual void bail() noexcept
			{}

			virtual bool read(std::uint32_t addr, std::uint32_t &data) = 0;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) = 0;

		private:
			std::uint32_t base;
			std::uint32_t mask;
			unsigned      word;

			static inline int log2i(int i)
			{
		    	return sizeof(int) * 8 - __builtin_clz(i) - 1;
			}
	};

	template<class Platform>
	class interconnect
	{
		public:
			interconnect(Platform &plat) noexcept;

			bool tick(bool clk);
			void attach(slave &dev);
			void bail() noexcept;

			std::uint32_t dump(std::uint32_t addr);
			void patch(std::uint32_t addr, std::uint32_t readdata);

		private:
			struct binding
			{
				std::uint32_t base;
				std::uint32_t mask;
				slave         &dev;
			};

			Platform            &plat;
			slave*               active = nullptr;
			std::vector<binding> devices;
			std::uint32_t        avl_address    = 0;
			std::uint32_t        avl_writedata  = 0;
			unsigned             avl_byteenable = 0;
			bool                 avl_read       = false;
			bool                 avl_write      = false;

			slave &resolve_external(std::uint32_t avl_address);
	};
}

#include "avalon.impl.hpp"

#endif
