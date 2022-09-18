#ifndef AVALON_IMPL_HPP
#define AVALON_IMPL_HPP

#include <cassert>
#include <cstdio>

namespace taller::avalon
{
	template<class Platform>
	void interconnect<Platform>::attach(slave &dev)
	{
		devices.push_back(binding { dev.base_address(), dev.address_mask(), dev });
	}

	template<class Platform>
	void interconnect<Platform>::tick()
	{
		auto addr = plat.avl_address;
		if(!active)
		{
			if(addr & 0b11)
			{
				fprintf(stderr, "[avl] unaligned address: 0x%08x\n", addr);
				assert(false);
			}

			for(auto &binding : devices)
			{
				if((addr & binding.mask) == binding.base)
				{
					active = &binding.dev;
					break;
				}
			}

			if(!active)
			{
				const char *op = plat.avl_read ? "read" : "write";
				fprintf(stderr, "[avl] attempt to %s memory hole at 0x%08x\n", op, addr);
				assert(false);
			}
		}

		assert(!plat.avl_read || !plat.avl_write);
		auto pos = addr >> 2;

		if(plat.avl_read)
		{
			plat.avl_waitrequest = !active->read(pos, plat.avl_readdata);
		} else if(plat.avl_write)
		{
			plat.avl_waitrequest = !active->write(pos, plat.avl_writedata, plat.avl_byteenable);
		}

		if(!plat.avl_waitrequest)
		{
			active = nullptr;
		}
	}
}

#endif
