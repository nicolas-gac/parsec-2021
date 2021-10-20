#ifndef MYLIB_CUH
#define MYLIB_CUH

#include "mylib.h"


#include <cuda_runtime.h>


Mat seuillageGPU( Mat in);

// GPU

__global__ void kernel_seuillageGPU(unsigned char *d_image_in, unsigned char *d_image_out,int size_j)
{
	float Csum;
	int i, j, k, iFirst, jFirst;

	iFirst = blockIdx.x*BLOCK_SIZE; // num de block dans la grille de block
	jFirst = blockIdx.y*BLOCK_SIZE;

	i = iFirst + threadIdx.x;// recuperer l'identifiant d'un thread dans les blocs
	j = jFirst + threadIdx.y;

	float nr = 0;

nr=d_image_in[2+j*3+i*3*size_j]/sqrtf(d_image_in[0+j*3+i*3*size_j]*d_image_in[0+j*3+i*3*size_j]+d_image_in[1+j*3+i*3*size_j]*d_image_in[1+j*3+i*3*size_j]+d_image_in[2+j*3+i*3*size_j]*d_image_in[2+j*3+i*3*size_j]);

	if(nr > 0.7)
		d_image_out[1+j*3+i*3*size_j] = d_image_in[2+j*3+i*3*size_j];
	else
		d_image_out[1+j*3+i*3*size_j] = d_image_in[1+j*3+i*3*size_j]; 

	d_image_out[0+j*3+i*3*size_j] = d_image_in[0+j*3+i*3*size_j];
	d_image_out[2+j*3+i*3*size_j] = d_image_in[2+j*3+i*3*size_j];


}

#endif
