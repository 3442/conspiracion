void reset()
{
	int a = 1, b = 1, *p = (int*)0x00010000;

	for(int i = 0; i < 20; ++i)
	{
		int c = a + b;

		*p++ = a;
		a = b;
		b = c;
	}
}
