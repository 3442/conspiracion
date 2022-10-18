int __attribute__((noinline)) sgn(int x)
{
	return x > 0 ? 1 : x < 0 ? -1 : 0;
}

int reset(int a, int b)
{
	int c;
	do
	{
		c = sgn(a) + sgn(b);
		if(!c)
		{
			goto l1;
		}

		switch(c)
		{
			case -1:
				a = b;
				__attribute__((fallthrough));

			case 0:
				b = a;
				break;

			case 1:
				goto l2;

			default:
				a = (a >> 7) ^ ((unsigned)a << 10);
				b = b + (b << 12 | (unsigned)b >> 17);
				continue;
		}

		if(sgn(b) <= 0)
		{
			a = ~b;
		}

		if(sgn(a) > 0)
		{
			b = 1 - a;
		}
	} while(a > b);

	c = a + b;
	return c;

l1:
	a = (b << 16 | (unsigned)a >> 16) ^ c;

l2:
	a = a << 2 | (unsigned)a >> 30;
	return a;
}
