#ifndef TALLER_MEM_HPP
#define TALLER_MEM_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	class mem : public slave
	{
		public:
			mem(std::uint32_t base, std::uint32_t size);

			virtual bool read_line(std::uint32_t addr, line &data) final override;

			virtual bool write_line
			(
				std::uint32_t addr, const line &data, unsigned byte_enable
			) final override;

			template<typename F>
			void load(F loader, std::size_t offset = 0);

		private:
			std::unique_ptr<line[]> block;
			unsigned                count = 0;

			bool ready() noexcept;
	};

	template<typename F>
	void mem::load(F loader, std::size_t offset)
	{
		const auto base = base_address();
		const auto bits = 4;

		std::size_t size = address_span();
		std::size_t addr = base_address() + offset;

		while (addr >= base && addr < base + size) {
			std::size_t read = loader(&block[(addr - base) >> bits], (base + size - addr) >> bits);
			if (!read)
				break;

			addr += read << bits;
		}
	}
}

#endif
