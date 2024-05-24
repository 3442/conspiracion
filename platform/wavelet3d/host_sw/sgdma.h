#ifndef SGDMA_H
#define SGDMA_H

int  sgdma_done(void);
void sgdma_memcpy(void *dest, const void *src, size_t len);
void sgdma_barrier(void);

#endif
