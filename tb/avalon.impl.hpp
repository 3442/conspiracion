#ifndef AVALON_IMPL_HPP
#define AVALON_IMPL_HPP

#include <cassert>
#include <cstdio>

namespace taller::avalon
{
	template<class Platform>
	inline interconnect<Platform>::interconnect(Platform &plat) noexcept
	: plat(plat)
	{}

	template<class Platform>
	void interconnect<Platform>::attach(slave &dev)
	{
		auto base = dev.base_address();
		auto mask = dev.address_mask();
		assert((base & mask) == base);

		devices.push_back(binding { base, mask, dev });
	}

	template<class Platform>
	void interconnect<Platform>::tick(bool clk)
	{
		if(!clk)
		{
			avl_address = plat.avl_address;
			avl_read = plat.avl_read;
			avl_write = plat.avl_write;
			avl_writedata = plat.avl_writedata;
			avl_byteenable = plat.avl_byteenable;
			return;
		}

		if(!active)
		{
			if(avl_address & 0b11)
			{
				fprintf(stderr, "[avl] unaligned address: 0x%08x\n", avl_address);
				assert(false);
			}

			for(auto &binding : devices)
			{
				if((avl_address & binding.mask) == binding.base)
				{
					active = &binding.dev;
					break;
				}
			}

			if(!active)
			{
				const char *op = avl_read ? "read" : "write";
				fprintf(stderr, "[avl] attempt to %s memory hole at 0x%08x\n", op, avl_address);
				assert(false);
			}
		}

		assert(!avl_read || !avl_write);
		auto pos = (avl_address & ~active->address_mask()) >> 2;

		if(avl_read)
		{
			plat.avl_waitrequest = !active->read(pos, plat.avl_readdata);
		} else if(avl_write)
		{
			plat.avl_waitrequest = !active->write(pos, avl_writedata, avl_byteenable);
		}

		if(!plat.avl_waitrequest)
		{
			active = nullptr;
		}
	}
}

#endif
