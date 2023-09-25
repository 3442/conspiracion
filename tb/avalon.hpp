#ifndef TALLER_AVALON_HPP
#define TALLER_AVALON_HPP

#include <cassert>
#include <cstdint>
#include <cstdio>
#include <stdexcept>
#include <vector>

namespace taller::avalon
{
	union line
	{
		__int128 qword;

		struct
		{
			std::uint64_t lo, hi;
		};

		struct
		{
			std::uint32_t words[4];
		};
	};

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

			virtual bool read(std::uint32_t addr, std::uint32_t &data)
			{
				line line_data;
				if (!this->read_line(addr >> 2, line_data))
					return false;

				data = line_data.words[addr & 0b11];
				return true;
			}

			virtual bool read_line(std::uint32_t addr, line &data)
			{
				data.hi = 0;
				data.lo = 0;

				return this->read(addr << 2, data.words[0]);
			}

			virtual bool write
			(
			 	std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) {
				line line_data;
				line_data.words[addr & 0b11] = data;

				return this->write_line(addr >> 2, line_data, byte_enable << ((addr & 0b11) * 4));
			}

			virtual bool write_line(std::uint32_t addr, const line &data, unsigned byte_enable) {
				unsigned offset = 0;
				if (byte_enable & 0x00f0)
					offset = 1;
				else if (byte_enable & 0x0f00)
					offset = 2;
				else if (byte_enable & 0xf000)
					offset = 3;

				return this->write
				(
					(addr << 2) + offset,
					data.words[offset],
					(byte_enable >> (offset * 4)) & 0b1111
				);
			}

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

			virtual bool irq() noexcept final override;

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

	class avl_bus_error : public std::runtime_error
	{
		public:
			using std::runtime_error::runtime_error;
	};

	template<class Platform>
	class interconnect
	{
		public:
			interconnect(Platform &plat) noexcept;

			bool tick(bool clk) noexcept;
			void tick_rising();
			void tick_falling() noexcept;

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
