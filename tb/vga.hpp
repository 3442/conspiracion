#ifndef LIBTALLER_VGA_HPP
#define LIBTALLER_VGA_HPP

#include <array>
#include <cstddef>
#include <cstdint>

#include <SDL2/SDL_surface.h>
#include <SDL2/SDL_video.h>

namespace taller::vga
{
	struct timings
	{
		unsigned active;
		unsigned front_porch;
		unsigned sync;
		unsigned back_porch;
	};

	struct video_mode
	{
		std::uint32_t pixel_clk;
		timings       h;
		timings       v;
	};

	template<class Crtc>
	class display
	{
		public:
			display(Crtc &crtc, std::uint32_t clock_hz) noexcept;

			~display() noexcept;

			void tick(bool clk) noexcept;

			inline bool key(std::size_t index)
			{
				return keys.at(index);
			}

		private:
			Crtc&               crtc;
			SDL_Window         *window     = nullptr;
			const video_mode   *mode       = nullptr;
			unsigned            row        = 0;
			unsigned            col        = 0;
			unsigned            hsync_lo   = 0;
			unsigned            hsync_hi   = 0;
			unsigned            vsync_hi   = 0;
			unsigned            vsync_lo   = 0;
			bool                last_hsync = false;
			bool                last_vsync = false;
			bool                found_line = false;
			const std::uint32_t clock_hz;

			std::array<bool, 4> keys = {};

			void move_pos()      noexcept;
			void scan_syncs()    noexcept;
			void scan_vsync()    noexcept;
			void put_pixel()     noexcept;
			void guess_mode()    noexcept;
			void signal_lost()   noexcept;
			void update_window() noexcept;
	};
}

#include "vga.impl.hpp"

#endif
