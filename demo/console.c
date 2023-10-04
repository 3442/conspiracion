#include <stdarg.h>

#include "demo.h"

struct lock console_lock;

#define JTAG_UART_BASE           0x30000000
#define JTAG_UART_DATA           (*(volatile unsigned *)(JTAG_UART_BASE + 0))
#define JTAG_UART_CONTROL        (*(volatile unsigned *)(JTAG_UART_BASE + 4))
#define JTAG_UART_CONTROL_RE     (1 << 0)
#define JTAG_UART_CONTROL_AC     (1 << 10)
#define JTAG_UART_CONTROL_WSPACE 0xffff0000

#define INTC_BASE       0x30070000
#define INTC_MASK       (*(volatile unsigned *)(INTC_BASE + 4))
#define INTC_MASK_TIMER (1 << 0)
#define INTC_MASK_UART  (1 << 1)

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

	bits = bits & ~3;
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

	print_str("cpu");
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

	print_str("\r\n");
	JTAG_UART_CONTROL = JTAG_UART_CONTROL_RE | JTAG_UART_CONTROL_AC;

	spin_unlock(&console_lock, irq_save);
	va_end(args);
}
