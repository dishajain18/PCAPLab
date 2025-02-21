#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__device__ int get_gtid()
{
    int bng = blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y;
    int ntpb = blockDim.x * blockDim.y * blockDim.z;
    int tnb = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * blockDim.x * blockDim.y;
    int gtid = bng * ntpb + tnb;
    return gtid;
}

__global__ void ssort(int*A,int*B,int n)
{
    int gtid = get_gtid();
    if(gtid < n)
    {
        int pos = 0;
        int i;
        int data = A[gtid];
        for(i=0;i<n;i++)
        {
            if(A[i] < data || (A[i]==data && i < gtid))
                pos++;
        }
        B[pos]=data;
    }
}

int main()
{
    int n;
    printf("Enter no. of elements: ");
    scanf("%d",&n);

    int size =  n * sizeof(int);
    int A[n],B[n];
    int *d_A,*d_B;

    printf("Enter elements in A: ");
    for(int i=0; i< n; i++)
        scanf("%d",&A[i]);

    cudaMalloc((void**)&d_A , size);
    cudaMalloc((void**)&d_B , size);

    cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice);
    dim3 blk(3,1,2); //i.e 6 threads per block

    ssort<<<ceil(n/6.0),blk>>>(d_A,d_B,n);

    cudaMemcpy(B,d_B,size,cudaMemcpyDeviceToHost);

    printf("Sorted array: ");
	for(int i=0; i<n; i++)
	{
		printf("%d ",B[i]);
	}
	printf("\n");

	cudaFree(d_A);
	cudaFree(d_B);
	return 0;

}
