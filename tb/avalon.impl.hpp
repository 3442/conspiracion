#ifndef TALLER_AVALON_IMPL_HPP
#define TALLER_AVALON_IMPL_HPP

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
	void interconnect<Platform>::attach_intc(interrupt_controller &intc)
	{
		assert(root_intc == nullptr);

		attach(intc.as_slave());
		root_intc = &intc;
	}

	template<class Platform>
	bool interconnect<Platform>::tick(bool clk) noexcept
	{
		if(!plat.reset_reset_n)
		{
			active = nullptr;
			plat.avl_irq = 0;

			avl_read = false;
			avl_write = false;
			avl_address = 0;
			avl_writedata = 0;
			avl_byteenable = 0;

			return true;
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
			tick_falling();
			return true;
		} else if(!active)
		{
			assert(!avl_read || !avl_write);
		}

		try
		{
			tick_rising();
			return true;
		} catch(const avl_bus_error&)
		{
			return false;
		}
	}

	template<class Platform>
	void interconnect<Platform>::tick_rising()
	{
		for(auto &binding : devices)
		{
			binding.dev.tick();
		}

		if(root_intc)
		{
			plat.avl_irq = root_intc->irq();
		}

		if(!active)
		{
			avl_address = plat.avl_address;
			avl_read = plat.avl_read;
			avl_write = plat.avl_write;
			avl_writedata = plat.avl_writedata;
			avl_byteenable = plat.avl_byteenable;

			if(!avl_read && !avl_write)
			{
				return;
			}

			for(auto &binding : devices)
			{
				if((avl_address & binding.mask) == binding.base)
				{
					active = &binding.dev;
					break;
				}
			}

			if(!active) [[unlikely]]
			{
				bail();

				const char *op = avl_read ? "read" : "write";
				fprintf(stderr, "[avl] attempt to %s memory hole at 0x%08x\n", op, avl_address);

				throw avl_bus_error{"memory hole addressed"};
			} else if(avl_address & active->word_mask()) [[unlikely]]
			{
				bail();
				fprintf(stderr, "[avl] unaligned address: 0x%08x\n", avl_address);

				throw avl_bus_error{"unaligned address"};
			}
		}

		auto pos = (avl_address & ~active->address_mask()) >> active->word_bits();

		if(avl_read)
		{
			std::uint32_t readdata;
			plat.avl_waitrequest = !active->read(pos, readdata);
			plat.avl_readdata = readdata;
		} else if(avl_write)
		{
			plat.avl_waitrequest = !active->write(pos, avl_writedata, avl_byteenable);
		}
	}

	template<class Platform>
	void interconnect<Platform>::tick_falling() noexcept
	{
		if(!plat.avl_waitrequest)
		{
			active = nullptr;
		}
	}

	template<class Platform>
	void interconnect<Platform>::bail() noexcept
	{
		for(auto &binding : devices)
		{
			binding.dev.bail();
		}
	}

	template<class Platform>
	bool interconnect<Platform>::dump(std::uint32_t addr, std::uint32_t &word)
	{
		std::uint32_t avl_address = addr << 2;

		auto *dev = resolve_external(avl_address);
		if(!dev)
		{
			return false;
		}

		auto pos = (avl_address & ~dev->address_mask()) >> dev->word_bits();

		while(!dev->read(pos, word))
		{
			continue;
		}

		return true;
	}

	template<class Platform>
	bool interconnect<Platform>::patch(std::uint32_t addr, std::uint32_t writedata)
	{
		std::uint32_t avl_address = addr << 2;

		auto *dev = resolve_external(avl_address);
		if(!dev)
		{
			return false;
		}

		auto pos = (avl_address & ~dev->address_mask()) >> dev->word_bits();

		while(!dev->write(pos, writedata, 0b1111))
		{
			continue;
		}

		return true;
	}

	template<class Platform>
	slave* interconnect<Platform>::resolve_external(std::uint32_t avl_address)
	{
		for(auto &binding : devices)
		{
			if((avl_address & binding.mask) == binding.base)
			{
				return &binding.dev;
			}
		}

		fprintf(stderr, "[avl] attempt to access hole at 0x%08x\n", avl_address);
		return nullptr;
	}
}

#endif
