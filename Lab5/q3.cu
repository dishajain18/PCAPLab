#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <math.h>

__global__ void mykernel(float * A,float * B)
{
	int bng = blockIdx.x; //block no. in grid
	int ntpd = blockDim.x; //no.of threads per block
	int tnb = threadIdx.x; //thread no. in block or local thread id
	int gtid = bng * ntpd + tnb;  
	B[gtid] = sinf(A[gtid]);
}

int main()
{
	float* A, *B;
	float *d_A, *d_B;
	int blks,thrds;
	printf("Enter no. of blocks in 1D grid: ");
	scanf("%d",&blks);
	printf("Enter no. of threads in 1D block: ");
	scanf("%d",&thrds);
	int  N = blks*thrds;
	int S = N * sizeof(float);
	A = (float*)malloc(S);
	B = (float*)malloc(S);

    	cudaMalloc((void**)&d_A , S);
	cudaMalloc((void**)&d_B , S);

	printf("Enter %d angles (in degrees) in A: ",N);
	for(int i=0; i<N; i++)
	{
		scanf("%f",&A[i]);
		A[i] *= 22.0/(7.0*180); //convert to radian
	}

	cudaMemcpy(d_A,A,S,cudaMemcpyHostToDevice);

	mykernel<<<blks,thrds>>>(d_A,d_B);

	cudaMemcpy(B,d_B,S,cudaMemcpyDeviceToHost);

	printf("Result: ");
	for(int i=0; i<N; i++)
	{
		printf("%.2f ",B[i]);
	}
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	free(A);
	free(B);
	return 0;
}
