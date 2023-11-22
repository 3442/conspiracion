#ifndef TALLER_VERILATOR_HPP
#define TALLER_VERILATOR_HPP

#include <cmath>
#include <cstdint>

namespace taller
{
	union fp16_bits
	{
		std::uint16_t u16;
		_Float16      fp16;
	};

	static inline std::uint16_t fp_add(std::uint16_t a, std::uint16_t b) noexcept
	{
		fp16_bits a_bits, b_bits, q_bits;
		a_bits.u16 = a;
		b_bits.u16 = b;

		q_bits.fp16 = a_bits.fp16 + b_bits.fp16;
		return q_bits.u16;
	}

	static inline std::uint16_t fp_mul(std::uint16_t a, std::uint16_t b) noexcept
	{
		fp16_bits a_bits, b_bits, q_bits;
		a_bits.u16 = a;
		b_bits.u16 = b;

		q_bits.fp16 = a_bits.fp16 * b_bits.fp16;
		return q_bits.u16;
	}

	static inline std::uint32_t fp_fix(std::uint16_t fp) noexcept
	{
		fp16_bits fp_bits;
		fp_bits.u16 = fp;

		auto as_double = std::ldexp(static_cast<double>(fp_bits.fp16), 16);
		return static_cast<std::uint32_t>(static_cast<std::int32_t>(as_double));
	}
}

#endif
