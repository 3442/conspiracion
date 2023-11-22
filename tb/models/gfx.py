import math, sys
from PIL import Image

W, H = 640, 480
FILL = (0, 0, 0)

fb = None

def fixed_color(color):
    for c in color[:3]:
        c = abs(int(c * (1 << 8)))
        yield (c & 255) | (255 if (c & (1 << 8)) else 0)

def fixed(p):
    pos, color = p
    w = pos
    pos = tuple(int(c / pos[3] * (1 << 13)) for c in pos[:3])
    return (pos, tuple(fixed_color(color)))

def bounding(p0, p1, p2):
    minx = max(min(p0[0][0], p1[0][0], p2[0][0]), (-W // 2) << 4)
    maxx = min(max(p0[0][0], p1[0][0], p2[0][0]), (W // 2) << 4)
    miny = max(min(p0[0][1], p1[0][1], p2[0][1]), (-H // 2) << 4)
    maxy = min(max(p0[0][1], p1[0][1], p2[0][1]), (H // 2) << 4)
    return (minx, miny, maxx, maxy)

def edge_fn(p, q, sx, sy):
    p, q = p[0], q[0]

    # https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage.html
    a, b = p[1] - q[1], -(p[0] - q[0])
    r = (sx - q[0]) * a + (sy - q[1]) * b
    return r, r, a, b

def raster(p0, p1, p2, msaa=False):
    global fb

    minx, miny, maxx, maxy = bounding(p0, p1, p2)

    sx, sy = minx // 16 * 16, miny // 16 * 16

    base_x_a, base_y_a, add_x_a, add_y_a = edge_fn(p0, p1, sx, sy)
    base_x_b, base_y_b, add_x_b, add_y_b = edge_fn(p1, p2, sx, sy)
    base_x_c, base_y_c, add_x_c, add_y_c = edge_fn(p2, p0, sx, sy)

    int_x_a = add_x_a << 4
    int_x_b = add_x_b << 4
    int_x_c = add_x_c << 4
    int_y_a = add_y_a << 4
    int_y_b = add_y_b << 4
    int_y_c = add_y_c << 4

    if msaa:
        samples = ((-5, 10), (11, 2), (-7, -4))
    else:
        samples = ((0, 0),)

    samples_a = tuple(add_x_a * sx + add_y_a * sy for sx, sy in samples)
    samples_b = tuple(add_x_b * sx + add_y_b * sy for sx, sy in samples)
    samples_c = tuple(add_x_c * sx + add_y_c * sy for sx, sy in samples)

    for x in range(minx // 16 * 16, maxx + 16, 16):
        for y in range(miny // 16 * 16, maxy + 16, 16):
            count = 0

            for a, b, c in zip(samples_a, samples_b, samples_c):
                b0 = base_y_a + a
                b1 = base_y_b + b
                b2 = base_y_c + c
                if b0 >= 0 and b1 >= 0 and b2 >= 0:
                    count += 1

            if count > 0:
                s = b0 + b1 + b2
                b0 /= s
                b1 /= s
                b2 /= s
                yield (x >> 4, y >> 4, b0, b1, b2)

            base_y_a += int_y_a
            base_y_b += int_y_b
            base_y_c += int_y_c

        base_x_a += int_x_a
        base_x_b += int_x_b
        base_x_c += int_x_c

        base_y_a = base_x_a
        base_y_b = base_x_b
        base_y_c = base_x_c

def backend():
    tri = (((-5 / 320, -5 / 240, 1.0, 1.0), (0.0, 0.0, 0.0, 1.0)),
           ((-50/320, -5/240, 1.0, 1.0), (0.0, 1.0, 0.0, 0.0)),
           ((-20/320,  -70/240, 1.0, 1.0), (0.0, 0.0, 1.0, 0.0)))

    t = tri

    tri = tuple(fixed(p) for p in tri)
    for x, y, b0, b1, b2 in raster(*tri):
        if -W // 2 <= x < W // 2 and -H // 2 <= y < H // 2:
            r = b0 * t[0][1][1] + b1 * t[1][1][1] + b2 * t[2][1][1]
            g = b0 * t[0][1][2] + b1 * t[1][1][2] + b2 * t[2][1][2]
            b = b0 * t[0][1][3] + b1 * t[1][1][3] + b2 * t[2][1][3]

            x += W // 2
            y = H // 2 - y - 1
            fb[y * W + x] = (int(r * 255), int(g * 255), int(b * 255))

imgs = []

def do_frame():
    global fb, imgs
    fb = [FILL] * W * H
    backend()

    image = Image.new('RGB', (W, H))
    image.putdata(fb)
    imgs.append(image)

for n in range(1):
    do_frame()

imgs[0].save('out.gif',
             save_all=True,
             append_images=imgs[1:],
             duration=100,
             loop=0)
