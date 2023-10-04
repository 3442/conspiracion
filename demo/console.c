#include <stdarg.h>
#include <stddef.h>

#include "demo.h"

#define JTAG_UART_BASE           0x30000000
#define JTAG_UART_DATA           (*(volatile unsigned *)(JTAG_UART_BASE + 0))
#define JTAG_UART_DATA_RVALID    (1 << 15)
#define JTAG_UART_DATA_RAVAIL    0xffff0000
#define JTAG_UART_CONTROL        (*(volatile unsigned *)(JTAG_UART_BASE + 4))
#define JTAG_UART_CONTROL_RE     (1 << 0)
#define JTAG_UART_CONTROL_AC     (1 << 10)
#define JTAG_UART_CONTROL_WSPACE 0xffff0000

#define INTC_BASE       0x30070000
#define INTC_MASK       (*(volatile unsigned *)(INTC_BASE + 4))
#define INTC_MASK_TIMER (1 << 0)
#define INTC_MASK_UART  (1 << 1)

static struct lock console_lock;

static int input_run = 0;
static unsigned input_len = 0;
static unsigned input_max;
static char *input_buf;

static void print_char(char c)
{
	while (!(JTAG_UART_CONTROL & JTAG_UART_CONTROL_WSPACE));
	JTAG_UART_DATA = (unsigned char)c;
}

static void print_str(const char *s)
{
	while (*s)
		print_char(*s++);
}

static void print_hex(unsigned val, unsigned bits)
{
	static const char hex_digits[16] = "0123456789abcdef";

	print_str("0x");

	if (bits < 4)
		bits = 4;

	if (bits > 32)
		bits = 32;

	bits = (bits + 3) & ~3;

	do
		print_char(hex_digits[(val >> (bits -= 4)) & 0xf]);
	while (bits);
}

static void print_dec(unsigned val)
{
	char dec[11] = {'\0'};
	char *next = dec;

	do {
		*next++ = '0' + val % 10;
		val /= 10;
	} while (val && next < dec + sizeof dec); 

	const char *c = next;
	while (c > dec)
		print_char(*--c);
}

void console_init(void)
{
	spin_init(&console_lock);

	input_buf = NULL;
	input_max = 0;

	// Habilitar irqs de entrada uart
	JTAG_UART_CONTROL = JTAG_UART_CONTROL_RE;

	// Habilitar irqs en controlador de interrupciones
	INTC_MASK = INTC_MASK_UART;

	// Habilitar irqs en core
	asm volatile("msr cpsr_c, #0x53");
}

void print(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);

	unsigned irq_save;
	spin_lock(&console_lock, &irq_save);

	while (!(JTAG_UART_CONTROL & JTAG_UART_CONTROL_AC));

	print_str("\r  ");
	for (unsigned i = 0; i < input_len; ++i)
		print_char(' ');

	print_str("\rcpu");
	print_dec(this_cpu->num);
	print_str(": ");

	char c;
	while ((c = *fmt++)) {
		if (c != '%') {
			print_char(c);
			continue;
		}

		unsigned val;
		switch ((c = *fmt++)) {
			case 'c':
				print_char((char)va_arg(args, int));
				break;

			case 'd':
			case 'i':
				print_dec((unsigned)va_arg(args, int));
				break;

			case 'p':
				print_hex((unsigned)va_arg(args, const void *), 32);
				break;

			case 'r':
				val = va_arg(args, unsigned);
				print_hex(val, va_arg(args, unsigned));
				break;

			case 'u':
				print_dec(va_arg(args, unsigned));
				break;

			case 's':
				print_str(va_arg(args, const char *));
				break;

			case 'x':
				print_hex(va_arg(args, unsigned), 32);
				break;

			default:
				print_char('%');
				if (c)
					print_char(c);

				break;
		}
	}

	print_str("\r\n> ");
	if (!input_run && input_buf)
		print_str(input_buf);

	JTAG_UART_CONTROL = JTAG_UART_CONTROL_RE | JTAG_UART_CONTROL_AC;

	spin_unlock(&console_lock, irq_save);
	va_end(args);
}

void read_line(char *buf, unsigned size)
{
	if (!size)
		return;

	buf[0] = '\0';

	unsigned irq_save;
	spin_lock(&console_lock, &irq_save);
	input_buf = buf;
	input_max = size;
	input_len = 0;
	spin_unlock(&console_lock, irq_save);

	while (1) {
		spin_lock(&console_lock, &irq_save);
		if (input_run)
			break;

		spin_unlock(&console_lock, irq_save);
	}

	input_buf = NULL;
	input_len = 0;
	input_max = 0;
	input_run = 0;
	spin_unlock(&console_lock, irq_save);
}

void irq(void)
{
	unsigned irq_save;
	spin_lock(&console_lock, &irq_save);

	unsigned data;
	do {
		data = JTAG_UART_DATA;
		if (!(data & JTAG_UART_DATA_RVALID))
			break;
		else if (input_run || !input_buf)
			continue;

		char c = (char)data;

		switch (c) {
			case 0x7f: // DEL
				if (input_len > 0) {
					--input_len;
					print_str("\b \b");
				}

				break;

			case '\n':
				input_run = 1;
				input_len = 0;
				print_str("\r\n> ");
				break;

			default:
				if (input_len < input_max - 1 && c >= ' ' && c <= '~') {
					print_char(c);
					input_buf[input_len++] = c;
					input_buf[input_len] = '\0';
				}

				break;
		}
	} while (data & JTAG_UART_DATA_RAVAIL);

	spin_unlock(&console_lock, irq_save);
}
