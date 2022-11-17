import sys
import math
from itertools import cycle

source, target, key = sys.argv[1:]

# key = [int(x) for x in key]

k = int(key, 2)

target = open(target,"ab")

with open(source, 'rb') as source:
    image_bytes = source.read()
    i = 0
    x = 0
    for n in image_bytes:
        if not (i == 3):
            x = n ^ k
            i += 1
        else:
            x = n
            i = 0
        target.write(bytes([x]))

target.close()
