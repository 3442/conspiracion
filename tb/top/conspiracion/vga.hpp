#ifndef LIBTALLER_VGA_HPP
#define LIBTALLER_VGA_HPP

#include <array>
#include <cstddef>
#include <cstdint>

#include <SDL2/SDL_surface.h>
#include <SDL2/SDL_video.h>

#include "avalon.hpp"

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
	class display : public avalon::slave
	{
		public:
			display(Crtc &crtc, std::uint32_t base, std::uint32_t clock_hz, std::uint32_t bus_hz = 0) noexcept;

			~display() noexcept;

			virtual void tick() noexcept final override;

			virtual bool read(std::uint32_t addr, std::uint32_t &data) noexcept final override;
			virtual bool write(std::uint32_t addr, std::uint32_t data, unsigned byte_enable) noexcept final override;

			void signal_tick(bool clk) noexcept;

			inline bool key(std::size_t index)
			{
				return keys.at(index);
			}

		private:
			unsigned            ticks         = 0;
			unsigned            refresh_ticks = 0;
			unsigned            max_addr      = 0;
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
