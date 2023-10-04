int strcmp(const char *s1, const char *s2)
{
    while (*s1 && *s1 == *s2)
        s1++, s2++;

    return (int)*(const unsigned char *)s1 - (int)*(const unsigned char *)s2;
}
