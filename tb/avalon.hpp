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
			inline slave(std::uint32_t base, std::uint32_t size, std::size_t word_size) noexcept
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

			inline virtual bool irq() noexcept
			{
				return false;
			}

		private:
			std::uint32_t base;
			std::uint32_t mask;
			unsigned      word;

			static inline int log2i(int i)
			{
		    	return sizeof(int) * 8 - __builtin_clz(i) - 1;
			}
	};

	struct irq_lines
	{
		slave *timer    = nullptr;
		slave *jtaguart = nullptr;
	};

	class interrupt_controller : private slave
	{
		public:
			interrupt_controller(std::uint32_t base) noexcept;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) noexcept final override;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept final override;

			virtual bool irq() noexcept;

			inline slave &as_slave() noexcept
			{
				return *this;
			}

			inline irq_lines &lines() noexcept
			{
				return irqs;
			}

		private:
			irq_lines     irqs;
			std::uint32_t mask = 0;

			std::uint32_t status() noexcept;
	};

	template<class Platform>
	class interconnect
	{
		public:
			interconnect(Platform &plat) noexcept;

			bool tick(bool clk);
			void attach(slave &dev);
			void attach_intc(interrupt_controller &intc);
			void bail() noexcept;

			bool dump(std::uint32_t addr, std::uint32_t &word);
			bool patch(std::uint32_t addr, std::uint32_t readdata);

		private:
			struct binding
			{
				std::uint32_t base;
				std::uint32_t mask;
				slave         &dev;
			};

			Platform             &plat;
			slave*                active = nullptr;
			std::vector<binding>  devices;
			interrupt_controller *root_intc      = nullptr;
			std::uint32_t         avl_address    = 0;
			std::uint32_t         avl_writedata  = 0;
			unsigned              avl_byteenable = 0;
			bool                  avl_read       = false;
			bool                  avl_write      = false;

			slave *resolve_external(std::uint32_t avl_address);
	};
}

#include "avalon.impl.hpp"

#endif
