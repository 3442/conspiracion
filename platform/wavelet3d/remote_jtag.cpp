// https://github.com/pulp-platform/riscv-dbg/blob/master/tb/remote_bitbang/remote_bitbang.c
// See LICENSE.Berkeley for license details.

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "remote_jtag.hpp"

remote_jtag::remote_jtag(uint16_t port)
{
	this->socket_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (socket_fd < 0) {
		fprintf(stderr, "remote_bitbang failed to make socket: %m\n");
		abort();
	}

	int reuseaddr = 1;
	if (setsockopt(this->socket_fd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof reuseaddr) < 0) {
		fprintf(stderr, "remote_bitbang failed setsockopt: %m\n");
		abort();
	}

	struct sockaddr_in addr;
	memset(&addr, 0, sizeof addr);
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(0x7f000001);
	addr.sin_port = htons(port);

	if (bind(this->socket_fd, (struct sockaddr *)&addr, sizeof addr) < 0) {
		fprintf(stderr, "remote_bitbang failed to bind socket: %m\n");
		abort();
	}

	if (listen(this->socket_fd, 1) < -1) {
		fprintf(stderr, "remote_bitbang failed to listen on socket: %m\n");
		abort();
	}

	fprintf(stderr, "JTAG remote bitbang server is ready\n");
	fprintf(stderr, "Listening on port %d\n", ntohs(addr.sin_port));

	this->poll_thread = std::thread([this]() { this->poll_main(); });
}

remote_jtag::~remote_jtag()
{
	if (this->poll_thread.joinable())
		this->poll_thread.join();

	if (this->socket_fd >= 0) {
		close(this->socket_fd);
		this->socket_fd = -1;
	}
}

void remote_jtag::poll_main()
{
	fprintf(stderr, "Attempting to accept client socket\n");

	int client_fd = accept(this->socket_fd, NULL, NULL);
	if (client_fd < 0) {
		fprintf(stderr, "failed to accept on socket: %m\n");
		this->dead.store(true, std::memory_order_relaxed);
		return;
	} else
		fprintf(stderr, "Accepted successfully.\n");

	std::unique_lock<std::mutex> lock(this->buffer_lock);
	while (true) {
		this->read_bytes = read(client_fd, this->in_buffer, sizeof this->in_buffer);
		this->readable.store(true, std::memory_order_relaxed);

		this->processed_cond.wait
		(
			lock, [&] { return !this->readable.load(std::memory_order_relaxed); }
		);

		if (this->read_bytes <= 0 || this->dead.load(std::memory_order_relaxed))
			break;

		unsigned write_size = this->write_bytes;
		unsigned write_start = 0;

		while (write_size > 0) {
			auto written = write(client_fd, &this->out_buffer[write_start], write_size);
			if (written <= 0) {
				fprintf(stderr, "jtag write() failed: %m\n");
				break;
			}

			write_size -= written;
			write_start += written;
		}
	}

	close(client_fd);
	this->dead.store(true, std::memory_order_relaxed);
}
