#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void kernelcol(int * A,int * B,int * C,int m)
{
    int col = threadIdx.x;
    int n = blockDim.x; // could have passed as an argument to function also but why not

    for(int i=0;i<m;i++)
        C[i*n+col] = A[i*n+col] + B[i*n+col];
}

int main()
{
    printf("Enter matrix dimensions(m and n): ");
    int m,n;
    scanf("%d %d",&m,&n);
    int A[m*n],B[m*n],C[m*n];
    int k=0;
    printf("Enter matrix A: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            scanf("%d",&A[k++]); //directly reading as 1D array
        }    
    }

    k=0;
    printf("Enter matrix B: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            scanf("%d",&B[k++]);
        }   
    }

    int *d_A,*d_B,*d_C;
    cudaMalloc((void**)&d_A,m*n*sizeof(int));
    cudaMalloc((void**)&d_B,m*n*sizeof(int));
    cudaMalloc((void**)&d_C,m*n*sizeof(int));

    cudaMemcpy(d_A,A,m*n*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,B,m*n*sizeof(int),cudaMemcpyHostToDevice);

    kernelcol<<<1,n>>>(d_A,d_B,d_C,m);

    cudaMemcpy(C,d_C,m*n*sizeof(int),cudaMemcpyDeviceToHost);

    k=0;
    printf("Final matrix C: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            printf("%d ",C[k++]);
        }
        printf("\n");   
    }

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    return 0;
}