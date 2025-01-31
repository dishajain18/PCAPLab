#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void mykernel(int * A,int * B,int * C,int * N)
{
	int bng = blockIdx.x; //block no. in grid
	int ntpd = blockDim.x; //no.of threads per block
	int tnb = threadIdx.x; //thread no. in block or local thread id
	int gtid = bng * ntpd + tnb;  
	if(gtid < *N)
		C[gtid] = A[gtid] + B[gtid];
}

int main()
{
	int* A, *B, *C;
	int *d_A, *d_B, *d_C;
	printf("Enter no. of elements: ");
	int  N;
	int *d_N;
	scanf("%d",&N);
	int S = N * sizeof(int);
	A = (int*)malloc(S);
	B = (int*)malloc(S);
	C = (int*)malloc(S);

    cudaMalloc((void**)&d_A , S);
	cudaMalloc((void**)&d_B , S);
	cudaMalloc((void**)&d_C , S);
	cudaMalloc((void**)&d_N , sizeof(int)); //no. of threads

	printf("Enter elements in A: ");
	for(int i=0; i<N; i++)
	{
		scanf("%d",&A[i]);
	}

	printf("Enter elements in B: ");
	for(int i=0; i<N; i++)
	{
		scanf("%d",&B[i]);
	}

	cudaMemcpy(d_A,A,S,cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,B,S,cudaMemcpyHostToDevice);
	cudaMemcpy(d_N,&N,sizeof(int),cudaMemcpyHostToDevice);

	mykernel<<<ceil(N/256.0),256>>>(d_A,d_B,d_C,d_N);

	cudaMemcpy(C,d_C,S,cudaMemcpyDeviceToHost);

	printf("Result: ");
	for(int i=0; i<N; i++)
	{
		printf("%d ",C[i]);
	}
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	free(A);
	free(B);
	free(C);
	return 0;
}