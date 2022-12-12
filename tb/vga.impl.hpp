#ifndef TALLER_VGA_IMPL_HPP
#define TALLER_VGA_IMPL_HPP

#include <array>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstdio>

#include <SDL2/SDL.h>
#include <SDL2/SDL_surface.h>
#include <SDL2/SDL_video.h>

#include "avalon.hpp"

namespace
{
	// https://web.mit.edu/6.111/www/s2004/NEWKIT/vga.shtml
	constexpr std::array<taller::vga::video_mode, 13> MODES
	{{
		{25'175'000, { 640, 16,  96,  48}, {480, 11, 2, 31}},
		{31'500'000, { 640, 24,  40, 128}, {480,  9, 3, 28}},
		{31'500'000, { 640, 16,  96,  48}, {480, 11, 2, 32}},
		{36'000'000, { 640, 32,  48, 112}, {480,  1, 3, 25}},
		{38'100'000, { 800, 32, 128, 128}, {600,  1, 4, 14}},
		{40'000'000, { 800, 40, 128,  88}, {600,  1, 4, 23}},
		{50'000'000, { 800, 56, 120,  64}, {600, 37, 6, 23}},
		{49'500'000, { 800, 16,  80, 160}, {600,  1, 2, 21}},
		{56'250'000, { 800, 32,  64, 152}, {600,  1, 3, 27}},
		{65'000'000, {1024, 24, 136, 160}, {768,  3, 6, 29}},
		{75'000'000, {1024, 24, 136, 144}, {768,  3, 6, 29}},
		{78'750'000, {1024, 16,  96, 176}, {768,  1, 3, 28}},
		{94'500'000, {1024, 48,  96, 208}, {768,  1, 3, 36}}
	}};
}

namespace taller::vga
{
	template<class Crtc>
	display<Crtc>::display(Crtc &crtc, std::uint32_t base, std::uint32_t clock_hz, std::uint32_t bus_hz) noexcept
	: avalon::slave(base, 64 << 20, 4),
	  crtc(crtc),
	  clock_hz(clock_hz)
	{
		if(bus_hz > 0)
		{
			mode = &MODES[0];
			max_addr = mode->h.active * mode->v.active;

			refresh_ticks =
				static_cast<float>(bus_hz)
				/ mode->pixel_clk
				* (mode->h.active + mode->h.front_porch + mode->h.sync + mode->h.back_porch)
				* (mode->v.active + mode->v.front_porch + mode->v.sync + mode->v.back_porch);

			ticks = refresh_ticks - 1;
			update_window();
		}
	}

	template<class Crtc>
	display<Crtc>::~display() noexcept
	{
		mode = nullptr;
		update_window();
	}

	template<class Crtc>
	void display<Crtc>::tick() noexcept
	{
		if(++ticks == refresh_ticks)
		{
			ticks = 0;
			if(!window)
			{
				update_window();
			}

			if(window)
			{
				::SDL_UpdateWindowSurface(window);
			}
		}
	}

	template<class Crtc>
	bool display<Crtc>::read(std::uint32_t addr, std::uint32_t &data) noexcept
	{
		return true;
	}

	template<class Crtc>
	bool display<Crtc>::write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept
	{
		if(!window || !mode)
		{
			return true;
		}

		auto *surface = ::SDL_GetWindowSurface(window);
		if(!surface)
		{
			return true;
		}

		auto *pixels = static_cast<std::uint32_t*>(surface->pixels);
		if(addr < max_addr)
		{
			pixels[addr] = data;
		}

		return true;
	}

	template<class Crtc>
	void display<Crtc>::signal_tick(bool clk) noexcept
	{
		if(!clk)
		{
			return;
		}

		put_pixel();
		move_pos();
		scan_syncs();

		last_hsync = crtc.vga_hsync;
		last_vsync = crtc.vga_vsync;

		::SDL_Event event;
		while(::SDL_PollEvent(&event))
		{
			bool value;
			switch(event.type)
			{
				case SDL_KEYDOWN:
					value = false;
					break;

				case SDL_KEYUP:
					value = true;
					break;

				default:
					continue;
			}

			std::size_t index;
			switch(event.key.keysym.sym)
			{
				case SDLK_1:
					index = 0;
					break;

				case SDLK_2:
					index = 1;
					break;

				case SDLK_3:
					index = 2;
					break;

				case SDLK_4:
					index = 3;
					break;

				default:
					continue;
			}

			keys[index] = value;
		}
	}

	template<class Crtc>
	void display<Crtc>::move_pos() noexcept
	{
		if(!mode)
		{
			if(found_line && ++col >= hsync_lo + hsync_hi)
			{
				col = 0;
			}

			return;
		}

		auto dots = mode->h.active + mode->h.front_porch + mode->h.sync + mode->h.back_porch;
		auto lines = mode->v.active + mode->v.front_porch + mode->v.sync + mode->v.back_porch;

		if((col + 1 != mode->h.sync || (!last_hsync && crtc.vga_hsync)) && ++col >= dots)
		{
			col = 0;
			if(row + 1 != mode->v.sync && ++row >= lines)
			{
				row = 0;
			}
		}

		if(!last_vsync && crtc.vga_vsync)
		{
			++row;
			if(window)
			{
				::SDL_UpdateWindowSurface(window);
			}
		}
	}

	template<class Crtc>
	void display<Crtc>::scan_syncs() noexcept
	{
		if(hsync_lo == 0)
		{
			hsync_lo += last_hsync && !crtc.vga_hsync;
		} else if(hsync_hi == 0)
		{
			if(crtc.vga_hsync)
			{
				scan_vsync();
			} else
			{
				++hsync_lo;
			}
		} else
		{
			scan_vsync();
		}
	}

	template<class Crtc>
	void display<Crtc>::scan_vsync() noexcept
	{
		if(found_line && crtc.vga_hsync != (col >= hsync_lo))
		{
			signal_lost();
		} else if(!found_line)
		{
			if(crtc.vga_hsync)
			{
				++hsync_hi;
			} else
			{
				found_line = true;
			}
		} else if(vsync_lo == 0)
		{
			vsync_lo += last_vsync && !crtc.vga_vsync;
		} else if(last_hsync && !crtc.vga_hsync)
		{
			if(crtc.vga_vsync)
			{
				++vsync_hi;
			} else if(vsync_hi == 0)
			{
				++vsync_lo;
			} else
			{
				guess_mode();

				hsync_lo = hsync_hi = vsync_lo = vsync_hi = 0;
				found_line = false;

				scan_syncs();
			}
		}
	}

	template<class Crtc>
	void display<Crtc>::put_pixel() noexcept
	{
		if(!mode)
		{
			return;
		}

		auto start_h = mode->h.sync + mode->h.back_porch;
		auto start_v = mode->v.sync + mode->v.back_porch;

		if(col < start_h
		|| col >= start_h + mode->h.active
		|| row < start_v
		|| row >= start_v + mode->v.active)
		{
			return;
		}

		auto *surface = window ? ::SDL_GetWindowSurface(window) : nullptr;
		if(!window || !surface)
		{
			return;
		}

		assert(surface->format->format == SDL_PIXELFORMAT_RGB888);

		auto *pixels = static_cast<std::uint32_t*>(surface->pixels);
		auto *pixel = pixels + (row - start_v) * mode->h.active + (col - start_h);
		*pixel = (crtc.vga_r & 0xff) << 16 | (crtc.vga_g & 0xff) << 8 | (crtc.vga_b & 0xff);
	}

	template<class Crtc>
	void display<Crtc>::guess_mode() noexcept
	{
		auto timings_match = [this](const video_mode &candidate)
		{
			int dots = candidate.h.active + candidate.h.front_porch + candidate.h.back_porch;
			int lines = candidate.v.active + candidate.v.front_porch + candidate.v.back_porch;

			return std::abs(dots - static_cast<int>(hsync_hi)) <= 2
			    && std::abs(lines - static_cast<int>(vsync_hi)) <= 2
			    && std::abs(static_cast<int>(hsync_lo) - static_cast<int>(candidate.h.sync)) <= 2
			    && std::abs(static_cast<int>(vsync_lo) - static_cast<int>(candidate.v.sync)) <= 2;
		};

		if(mode != nullptr && timings_match(*mode))
		{
			return;
		}

		std::fprintf
		(
			stderr,
			"[vga] hsync_duty: %u/%u, vsync_duty: %u/%u, pixel_clk: %.2fMHz\n",
			hsync_lo,
			hsync_lo + hsync_hi,
			vsync_lo,
			vsync_lo + vsync_hi,
			clock_hz / 1e6
		);

		mode = nullptr;
		for(const auto &candidate : MODES)
		{
			if(!timings_match(candidate))
			{
				continue;
			}

			float actual_clk_f = clock_hz;
			float expected_clk_f = candidate.pixel_clk;

			if(std::fabs((expected_clk_f - actual_clk_f) / expected_clk_f) < 0.02)
			{
				mode = &candidate;
				break;
			}
		}

		if(mode)
		{
			auto width = mode->h.active + mode->h.front_porch + mode->h.sync + mode->h.back_porch;
			auto height = mode->v.active + mode->v.front_porch + mode->v.sync + mode->v.back_porch;
			auto rate = static_cast<float>(clock_hz) / (width * height);

			std::fprintf
			(
				stderr,
				"[vga] %ux%u @ %.2fHz\n",
				mode->h.active,
				mode->v.active,
				rate
			);
		} else
		{
			std::fputs("[vga] failed to guess mode from timings\n", stderr);
		}

		update_window();
		if(mode && window)
		{
			::SDL_SetWindowSize(window, mode->h.active, mode->v.active);
		}
	}

	template<class Crtc>
	void display<Crtc>::signal_lost() noexcept
	{
		if(mode)
		{
			std::fputs("[vga] no signal\n", stderr);
			mode = nullptr;
		}

		row = col = 0;
		hsync_lo = hsync_hi = vsync_lo = vsync_hi = 0;
		found_line = false;

		update_window();
	}

	template<class Crtc>
	void display<Crtc>::update_window() noexcept
	{
		if(!mode && window)
		{
			::SDL_DestroyWindow(window);
			window = nullptr;
		} else if(mode && !window)
		{
			if(!SDL_WasInit(SDL_INIT_VIDEO))
			{
				::SDL_SetHint(SDL_HINT_NO_SIGNAL_HANDLERS, "1");
				assert(::SDL_Init(SDL_INIT_VIDEO) >= 0);
			}

			window = ::SDL_CreateWindow
			(
				"VGA Display",
				SDL_WINDOWPOS_CENTERED,
				SDL_WINDOWPOS_CENTERED,
				mode->h.active,
				mode->v.active,
				0
			);

			assert(window);
		}
	}
}

#endif
