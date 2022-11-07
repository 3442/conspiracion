long long __attribute__((noinline)) mla(long long a, long long b, long long c)
{
	return a * b + c;
}

long long reset(int a, int b, int c)
{
	long long la = a, lb = b;
	return mla(la * la, la + 2 * lb, c);
}
