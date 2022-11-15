#ifndef TALLER_MEM_HPP
#define TALLER_MEM_HPP

#include <cstdint>
#include <memory>

#include "avalon.hpp"

namespace taller::avalon
{
	template<typename Cell>
	class mem : public slave
	{
		public:
			mem(std::uint32_t base, std::uint32_t size);

			virtual bool read(std::uint32_t addr, std::uint32_t &data) final override;

			virtual bool write
			(
				std::uint32_t addr, std::uint32_t data, unsigned byte_enable = 0b1111
			) final override;

			template<typename F>
			void load(F loader, std::size_t offset = 0);

		private:
			std::unique_ptr<Cell[]> block;
			unsigned                count = 0;

			bool ready() noexcept;
	};
}

#include "mem.impl.hpp"

#endif
