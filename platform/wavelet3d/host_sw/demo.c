#define MOD_NAME "demo"

#include <math.h>
#include <string.h>

#include "log.h"

#define W 640
#define H 480

#define FB_BASE ((void *)0x1d000000)

typedef float mat4[4][4];
typedef float vec4[4];

typedef struct vec2i
{
	int x, y;
} vec2i;

typedef struct vertex
{
	vec4  pos;
	vec2i grid;
	vec4  color;
} vertex;

static mat4 mvp;
static unsigned short z_buff[1024 * H];

static inline int min(int x, int y)
{
	return x < y ? x : y;
}

static inline int max(int x, int y)
{
	return x > y ? x : y;
}

void mat_vec(mat4 *a, vec4 *b, vec4 *out)
{
	vec4 v;
	for (int i = 0; i < 4; ++i) {
		v[i] = 0.0;
		for (int k = 0; k < 4; ++k)
			v[i] += (*a)[i][k] * (*b)[k];
	}

	memcpy(out, v, sizeof v);
}

void mat_mat(mat4 *a, mat4 *b, mat4 *out)
{
	mat4 c;
	for (int i = 0; i < 4; ++i)
		for (int j = 0; j < 4; ++j) {
			c[i][j] = 0.0;
			for (int k = 0; k < 4; ++k)
				c[i][j] += (*a)[i][k] * (*b)[k][j];
		}

	memcpy(out, c, sizeof c);
}

void mat_translate(float x, float y, float z, mat4 *out)
{
	mat4 m =
	{
		{1, 0, 0, x},
		{0, 1, 0, y},
		{0, 0, 1, z},
		{0, 0, 0, 1},
	};

	memcpy(out, m, sizeof m);
};

void mat_scale(float x, float y, float z, mat4 *out)
{
	mat4 m =
	{
		{x, 0, 0, 0},
		{0, y, 0, 0},
		{0, 0, z, 0},
		{0, 0, 0, 1},
	};

	memcpy(out, m, sizeof m);
}

void mat_rotate(float x, float y, float z, float angle, mat4 *out)
{
	float xx = x * x, yy = y * y, zz = z * z;
	float mag = sqrt(xx + yy + zz);
	x /= mag;
	y /= mag;
	z /= mag;

	angle = angle * M_PI / 180;
	float c = cosf(angle), s = sinf(angle);

	mat4 m =
	{
		{x * x * (1 - c) + c,     x * y * (1 - c) - z * s, x * z * (1 - c) + y * s, 0},
		{y * x * (1 - c) + z * s, y * y * (1 - c) + c,     y * z * (1 - c) - x * s, 0},
		{x * z * (1 - c) - y * s, y * z * (1 - c) + x * s, z * z * (1 - c) + c,     0},
		{0,                       0,                       0,                       1},
	};

	memcpy(out, m, sizeof m);
}

void mat_frustum(float left, float right, float bottom, float top, float near, float far, mat4 *out)
{
	// https://docs.gl/gl3/glFrustum

	float l = left, r = right, b = bottom, t = top, n = near, f = far;

	mat4 m =
	{
		{2 * n / (r - l), 0,               (r + l) / (r - l),  0},
		{0,               2 * n / (t - b), (t + b) / (t - b),  0},
		{0,               0,               -(f + n) / (f - n), -2 * f * n / (f - n)},
		{0,               0,               -1                , 0},
	};

	memcpy(out, m, sizeof m);
}

void fixed(vec4 *p, vec2i *out)
{
	out->x = (int)ldexpf((*p)[0] / (*p)[3], 13);
	out->y = (int)ldexpf((*p)[1] / (*p)[3], 13);
}

void edge_fn(vec2i *p, vec2i *q, int sx, int sy, int *base_x, int *base_y, int *add_x, int *add_y)
{
	// https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage.html
	int a = p->y - q->y, b = -(p->x - q->x);
	int r = (sx - q->x) * a + (sy - q->y) * b;

	*base_x = r;
	*base_y = r;
	*add_x = a;
	*add_y = b;
}

void bounding(vec2i *p0, vec2i *p1, vec2i *p2, int *minx, int *miny, int *maxx, int *maxy)
{
	*minx = max(min(p0->x, min(p1->x, p2->x)), (-W / 2) << 4);
	*maxx = min(max(p0->x, max(p1->x, p2->x)), ( W / 2) << 4);
	*miny = max(min(p0->y, min(p1->y, p2->y)), (-H / 2) << 4);
	*maxy = min(max(p0->y, max(p1->y, p2->y)), ( H / 2) << 4);
}

unsigned char clamp_color(float color)
{
	color = ldexpf(color, 8);
	if (color < 0.0)
		return 0;
	else if (color >= 256.0)
		return 255;

	return (unsigned char)(int)color;
}

float area(vec2i *a, vec2i *b, vec2i *c)
{
	float a_x = a->x;
	float a_y = a->y;
	float b_x = b->x;
	float b_y = b->y;
	float c_x = c->x;
	float c_y = c->y;


	return (a_x * (b_y - c_y) + b_x * (c_y - a_y) + c_x * (a_y - b_y)) / 2;
}

void raster(vertex *v0, vertex *v1, vertex *v2)
{
	// https://math.stackexchange.com/questions/1324179/how-to-tell-if-3-connected-points-are-connected-clockwise-or-counter-clockwise

	int A = v1->grid.x * v0->grid.y + v2->grid.x * v1->grid.y + v0->grid.x * v2->grid.y;
	int B = v0->grid.x * v1->grid.y + v1->grid.x * v2->grid.y + v2->grid.x * v0->grid.y;

	if (A > B) {
		vertex *tmp = v2;
		v2 = v1;
		v1 = tmp;
	}

	vec2i *p0 = &v0->grid;
	vec2i *p1 = &v1->grid;
	vec2i *p2 = &v2->grid;

	int msaa = 0; //TODO

	int minx, miny, maxx, maxy;
	bounding(p0, p1, p2, &minx, &miny, &maxx, &maxy);

	int sx = minx / 16 * 16, sy = miny / 16 * 16;

	int base_x_a, base_y_a, add_x_a, add_y_a;
	edge_fn(p0, p1, sx, sy, &base_x_a, &base_y_a, &add_x_a, &add_y_a);

	int base_x_b, base_y_b, add_x_b, add_y_b;
	edge_fn(p1, p2, sx, sy, &base_x_b, &base_y_b, &add_x_b, &add_y_b);

	int base_x_c, base_y_c, add_x_c, add_y_c;
	edge_fn(p2, p0, sx, sy, &base_x_c, &base_y_c, &add_x_c, &add_y_c);

	int int_x_a = add_x_a << 4;
	int int_x_b = add_x_b << 4;
	int int_x_c = add_x_c << 4;
	int int_y_a = add_y_a << 4;
	int int_y_b = add_y_b << 4;
	int int_y_c = add_y_c << 4;

	for (int x = minx / 16 * 16; x < maxx + 16; x += 16) {
		for (int y = miny / 16 * 16; y < maxy + 16; y += 16) {
			int count = 0;

			if (base_y_a >= 0 && base_y_b >= 0 && base_y_c >= 0)
				++count;

			base_y_a += int_y_a;
			base_y_b += int_y_b;
			base_y_c += int_y_c;

			if (!count > 0)
				continue;

			int yield_x = x >> 4, yield_y = y >> 4, yield_c = msaa ? count : 3;
			if (!(-W / 2 <= yield_x && yield_x < W / 2 && -H / 2 <= yield_y && yield_y < H / 2))
				continue;

			yield_x += W / 2;
			yield_y = H / 2 - yield_y - 1;

			vec2i p = {.x = x, .y = y};
			// https://stackoverflow.com/questions/24441631/how-exactly-does-opengl-do-perspectively-correct-linear-interpolation
			float b0 = area(&p, p1, p2) / v0->pos[3];
			float b1 = area(p0, &p, p2) / v1->pos[3];
			float b2 = area(p0, p1, &p) / v2->pos[3];

			float b_sum = b0 + b1 + b2;
			b0 /= b_sum;
			b1 /= b_sum;
			b2 /= b_sum;

			float z = v0->pos[2] * b0 + v1->pos[2] * b1 + v2->pos[2] * b2;
			if (z < -1.0 || z >= 1.0)
				continue;

			unsigned short z_int = (unsigned short)(int)ldexpf(1.0 + z, 16 - 1);
			unsigned short *z_cell = &z_buff[yield_y * 1024 + yield_x];

			if (*z_cell > z_int)
				continue;

			*z_cell = z_int;

			unsigned char r = clamp_color(v0->color[0] * b0 + v1->color[0] * b1 + v2->color[0] * b2);
			unsigned char g = clamp_color(v0->color[1] * b0 + v1->color[1] * b1 + v2->color[1] * b2);
			unsigned char b = clamp_color(v0->color[2] * b0 + v1->color[2] * b1 + v2->color[2] * b2);

			volatile unsigned char *ptr =
				(unsigned char *)FB_BASE
				+ yield_y * 2048
				+ yield_x * 3;

			*ptr++ = b;
			*ptr++ = g;
			*ptr++ = r;
		}

		base_x_a += int_x_a;
		base_x_b += int_x_b;
		base_x_c += int_x_c;

		base_y_a = base_x_a;
		base_y_b = base_x_b;
		base_y_c = base_x_c;
	}
}

void persp_div(vec4 *pos)
{
	float w_inv = 1.0f / (*pos)[3];
	(*pos)[0] = (*pos)[0] * w_inv;
	(*pos)[1] = (*pos)[1] * w_inv;
	(*pos)[2] = (*pos)[2] * w_inv;
	(*pos)[3] = w_inv;
}

void tri
(
	float x1, float y1, float z1,
	float x2, float y2, float z2,
	float x3, float y3, float z3
)
{
	vertex v0 = {.pos = {x1, y1, z1, 1.0}, .color = {1.0, 0.0, 0.0, 0.0}};
	vertex v1 = {.pos = {x2, y2, z2, 1.0}, .color = {0.0, 1.0, 0.0, 0.0}};
	vertex v2 = {.pos = {x3, y3, z3, 1.0}, .color = {0.0, 0.0, 1.0, 0.0}};

	mat_vec(&mvp, &v0.pos, &v0.pos);
	mat_vec(&mvp, &v1.pos, &v1.pos);
	mat_vec(&mvp, &v2.pos, &v2.pos);

	persp_div(&v0.pos);
	persp_div(&v1.pos);
	persp_div(&v2.pos);

	fixed(&v0.pos, &v0.grid);
	fixed(&v1.pos, &v1.grid);
	fixed(&v2.pos, &v2.grid);

	raster(&v0, &v1, &v2);
}

// v2-v3 debe ser una diagonal, sino no sirve
void quad
(
	float x1, float y1, float z1,
	float x2, float y2, float z2,
	float x3, float y3, float z3,
	float x4, float y4, float z4
)
{
	tri(x2, y2, z2, x1, y1, z1, x3, y3, z3);
	tri(x2, y2, z2, x4, y4, z4, x3, y3, z3);
}

void demo(void)
{
	//memset(FB_BASE, 0, 2048 * H);
	//memset(z_buff, 0, sizeof z_buff);

	float a = -50;
	float f = 1;
	float w = 1;

	mat4 trans_z, trans_center, rot, scal;
	mat_translate(0, 0, -5, &trans_z);
	mat_rotate(1, 1, 1, a, &rot);
	mat_translate(-0.5, -0.5, -0.5, &trans_center);
	mat_scale(f, f, f, &scal);

	// https://stackoverflow.com/questions/16398463/getting-coordinates-for-glfrustum
	float fov = 120;
	float back = 1000.0;
	float front = 1.0;
	float aspect = 1.0;

	// transform from horizontal fov to vertical fov
	fov = ldexpf(atanf(tanf(fov * M_PI_2 / 180) / aspect), 1);

	float tangent = tanf(fov / 2.0f);               // tangent of half vertical fov
	float height = front * tangent;                 // half height of near plane
	float width = height * aspect;                  // half width of near plane

	// Escalar, luego rotar, luego frustum
	mat_frustum(-width, width, -height, height, front, back, &mvp);
	mat_mat(&mvp, &trans_z, &mvp);
	mat_mat(&mvp, &rot, &mvp);
	mat_mat(&mvp, &trans_center, &mvp);
	mat_mat(&mvp, &scal, &mvp);

	for (int i = 0; i < 4; ++i)
		for (int j = 0; j < 4; ++j)
			log("mvp[%d][%d] = %f", i, j, mvp[i][j]);

	quad
	(
		0.0, 0.0, 0.0,
		0.0, 1.0, 0.0,
		1.0, 0.0, 0.0,
		1.0, 1.0, 0.0
	);

	quad
	(
		0.0, 0.0, 1.0,
		0.0, 1.0, 1.0,
		1.0, 0.0, 1.0,
		1.0, 1.0, 1.0
	);

	quad
	(
		0.0, 0.0, 1.0,
		0.0, 1.0, 1.0,
		0.0, 0.0, 0.0,
		0.0, 1.0, 0.0
	);

	quad
	(
		1.0, 0.0, 1.0,
		1.0, 1.0, 1.0,
		1.0, 0.0, 0.0,
		1.0, 1.0, 0.0
	);

	quad
	(
		0.0, 0.0, 0.0,
		0.0, 0.0, 1.0,
		1.0, 0.0, 0.0,
		1.0, 0.0, 1.0
	);

	quad
	(
		0.0, 1.0, 0.0,
		0.0, 1.0, 1.0,
		1.0, 1.0, 0.0,
		1.0, 1.0, 1.0
	);
}
