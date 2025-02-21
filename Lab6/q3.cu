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

__global__ void odd_kernel(int *A,int m)
{
    int gtid = get_gtid();
    if(gtid < m && gtid % 2 == 1)
    {
        int temp;
        if(gtid + 1 <= m-1 && A[gtid] > A[gtid+1])
        {
            temp = A[gtid];
            A[gtid] = A[gtid + 1];                
            A[gtid + 1] = temp;
        }
    }
}


__global__ void even_kernel(int *A,int m)
{
    int gtid = get_gtid();
    if(gtid < m && gtid % 2 == 0)
    {
        int temp;
        if(gtid + 1 <= m-1 && A[gtid] > A[gtid+1])
        {
            temp = A[gtid];
            A[gtid] = A[gtid + 1];                
            A[gtid + 1] = temp;
        }
    }    
}



int main()
{
    int n;
    printf("Enter no. of elements: ");
    scanf("%d",&n);

    int size =  n * sizeof(int);
    int A[n];
    int *d_A;

    printf("Enter elements in A: ");
    for(int i=0; i< n; i++)
        scanf("%d",&A[i]);

    cudaMalloc((void**)&d_A , size);

    cudaMemcpy(d_A,A,size,cudaMemcpyHostToDevice);
    dim3 blk(1,3,2); //i.e 6 threads per block

    for(int i=0; i <= n/2; i++) // <= is kinda like ceil value in case of odd n
    {
        odd_kernel<<<ceil(n/6.0),blk>>>(d_A,n);
        even_kernel<<<ceil(n/6.0),blk>>>(d_A,n);
    }

    cudaMemcpy(A,d_A,size,cudaMemcpyDeviceToHost);

    printf("Sorted array: ");
	for(int i=0; i<n; i++)
	{
		printf("%d ",A[i]);
	}
	printf("\n");

	cudaFree(d_A);
}
