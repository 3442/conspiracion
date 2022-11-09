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
		if(!plat.reset_reset_n) [[unlikely]]
		{
			active = nullptr;
			avl_read = false;
			avl_write = false;
			avl_address = 0;
			avl_writedata = 0;
			avl_byteenable = 0;
			return;
		}

		if(active)
		{
			assert(avl_address == plat.avl_address);
			assert(avl_read == plat.avl_read);
			assert(avl_write == plat.avl_write);
			assert(avl_writedata == plat.avl_writedata);
			assert(avl_byteenable == plat.avl_byteenable);
		}

		if(!clk)
		{
			if(!plat.avl_waitrequest)
			{
				active = nullptr;
			}

			return;
		} else if(!active)
		{
			avl_address = plat.avl_address;
			avl_read = plat.avl_read;
			avl_write = plat.avl_write;
			avl_writedata = plat.avl_writedata;
			avl_byteenable = plat.avl_byteenable;

			assert(!avl_read || !avl_write);

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

		auto pos = (avl_address & ~active->address_mask()) >> 2;

		if(avl_read)
		{
			plat.avl_waitrequest = !active->read(pos, plat.avl_readdata);
		} else if(avl_write)
		{
			plat.avl_waitrequest = !active->write(pos, avl_writedata, avl_byteenable);
		}
	}

	template<class Platform>
	std::uint32_t interconnect<Platform>::dump(std::uint32_t addr)
	{
		std::uint32_t avl_address = addr << 2;

		for(auto &binding : devices)
		{
			if((avl_address & binding.mask) == binding.base)
			{
				auto &dev = binding.dev;
				auto pos = (avl_address & ~dev.address_mask()) >> 2;

				std::uint32_t readdata;
				while(!dev.read(pos, readdata))
				{
					continue;
				}

				return readdata;
			}
		}

		fprintf(stderr, "[avl] attempt to dump memory hole at 0x%08x\n", addr);
		assert(false);
	}
}

#endif
