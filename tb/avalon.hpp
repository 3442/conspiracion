#ifndef AVALON_HPP
#define AVALON_HPP

#include <cstdint>
#include <vector>

namespace taller::avalon
{
	class slave
	{
		public:
			virtual std::uint32_t base_address() noexcept = 0;
			virtual std::uint32_t address_mask() noexcept = 0;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) = 0;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) = 0;
	};

	template<class Platform>
	class interconnect
	{
		public:
			interconnect(Platform &plat) noexcept;

			void tick(bool clk);
			void attach(slave &dev);

			std::uint32_t dump(std::uint32_t addr);

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
	};
}

#include "avalon.impl.hpp"

#endif
