// https://github.com/pulp-platform/riscv-dbg/blob/master/tb/remote_bitbang/remote_bitbang.h
// See LICENSE.Berkeley for license details.

#ifndef REMOTE_JTAG_HPP
#define REMOTE_JTAG_HPP

#include <atomic>
#include <cstdint>
#include <condition_variable>
#include <mutex>
#include <thread>

class remote_jtag
{
	public:
		remote_jtag(std::uint16_t port);
		~remote_jtag();

		inline bool pending() noexcept
		{
			return this->readable.load(std::memory_order_relaxed);
		}

		inline bool alive() noexcept
		{
			return !this->dead.load(std::memory_order_relaxed);
		}

		template<typename F>
		void process
		(
			unsigned char *tck,
			unsigned char *tms,
        	unsigned char *tdi,
			unsigned char *trstn,
        	unsigned char *tdo,
			F            &&cycle
		);

	private:
		int                     socket_fd  = -1;
		std::atomic<bool>       readable   = false;
		std::atomic<bool>       dead       = false;
		char                    in_buffer[512];
		char                    out_buffer[512];
		ssize_t                 read_bytes = 0;
		unsigned                write_bytes = 0;
		std::mutex              buffer_lock;
		std::condition_variable processed_cond;
		std::thread             poll_thread;

		void poll_main();
};

template<typename F>
void remote_jtag::process
(
	unsigned char *tck,
	unsigned char *tms,
	unsigned char *tdi,
	unsigned char *trstn,
	unsigned char *tdo,
	F            &&cycle
)
{
	std::unique_lock<std::mutex> lock(this->buffer_lock);

	char command;

	if (this->read_bytes > 0) {
		this->write_bytes = 0;
		for (ssize_t i = 0; i < this->read_bytes; ++i) {
			char command = this->in_buffer[i];

			int dosend = 0;
			char tosend = '?';

			switch (command) {
				case 'B':
					break;
				case 'b':
					break;
				case 'r':
					*trstn = 1; //r-reset command deasserts TRST. See: openocd/blob/master/doc/manual/jtag/drivers/remote_bitbang.txt
					break; 
				case 's':
					*trstn = 1; //s-reset command deasserts TRST. See: openocd/blob/master/doc/manual/jtag/drivers/remote_bitbang.txt
					break;
				case 't':
					*trstn = 0; //t-reset command asserts TRST. See: openocd/blob/master/doc/manual/jtag/drivers/remote_bitbang.txt
					break;
				case 'u':
					*trstn = 0; //u-reset command asserts TRST. See: openocd/blob/master/doc/manual/jtag/drivers/remote_bitbang.txt
					break;
				case '0':
					*tck = 0;
					*tms = 0;
					*tdi = 0;
					break;
				case '1':
					*tck = 0;
					*tms = 0;
					*tdi = 1;
					break;
				case '2':
					*tck = 0;
					*tms = 1;
					*tdi = 0;
					break;
				case '3':
					*tck = 0;
					*tms = 1;
					*tdi = 1;
					break;
				case '4':
					*tck = 1;
					*tms = 0;
					*tdi = 0;
					break;
				case '5':
					*tck = 1;
					*tms = 0;
					*tdi = 1;
					break;
				case '6':
					*tck = 1;
					*tms = 1;
					*tdi = 0;
					break;
				case '7':
					*tck = 1;
					*tms = 1;
					*tdi = 1;
					break;
				case 'R':
					dosend = 1;
					tosend = *tdo ? '1' : '0';
					break;
				case 'Q':
					fprintf(stderr, "Remote end disconnected\n");
					this->dead.store(true, std::memory_order_relaxed);
					break;
				default:
					fprintf(stderr, "remote_bitbang got unsupported command '%c'\n", command);
					break;
			}

			if (dosend)
				this->out_buffer[this->write_bytes++] = tosend;

			cycle();
		}
	} else if (this->read_bytes < 0)
		fprintf(stderr, "jtag read() failed\n");

	this->readable.store(false, std::memory_order_relaxed);
	lock.unlock();

	this->processed_cond.notify_one();
}

#endif
