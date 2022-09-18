#ifndef AVALON_HPP
#define AVALON_HPP

#include <cstdint>
#include <vector>

namespace taller::avalon
{
	class slave
	{
		public:
			virtual std::uint32_t base_address() = 0;
			virtual std::uint32_t address_mask() = 0;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) = 0;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) = 0;
	};

	template<class Platform>
	class interconnect
	{
		public:
			inline interconnect(Platform &plat) noexcept
			: plat(plat)
			{}

			void tick();
			void attach(slave &dev);

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
	};
}

#include "avalon.impl.hpp"

#endif
