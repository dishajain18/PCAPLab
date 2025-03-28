#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void kernelele(int * A,int * B)
{
    int col = threadIdx.x;
    int row = threadIdx.y;
    int n = blockDim.x; 
    int m = blockDim.y;
    if(row != 0 && row != m-1 && col != 0 && col != n-1)
    {
        int ele = A[row*n+col];
        int ones = 0;
        int pos = 1;
        if(ele==0)
         ones = 1;
        while(ele != 0)
        {
            int bit = ele % 2;
            bit = bit ^ 1; //XOR with 1 flips the bit
            ones += bit*pos;
            pos *= 10;
        }

        B[row*n+col]=ones;
    }

}

int main()
{
    printf("Enter matrix dimensions(m and n): ");
    int m,n;
    scanf("%d %d",&m,&n);

    int A[m*n],B[m*n];
    int k=0;
    printf("Enter matrix A: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            scanf("%d",&A[k++]); //directly reading as 1D array
        }  
    }

    int *d_A,*d_B;
    cudaMalloc((void**)&d_A,m*n*sizeof(int));
    cudaMalloc((void**)&d_B,m*n*sizeof(int));

    cudaMemcpy(d_A,A,m*n*sizeof(int),cudaMemcpyHostToDevice);

    dim3 blk(n,m,1);
    kernelele<<<1,blk>>>(d_A,d_B);

    cudaMemcpy(B,d_B,m*n*sizeof(int),cudaMemcpyDeviceToHost);

    k=0;
    printf("Final matrix: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            printf("%d ",B[k++]);
        }
        printf("\n");   
    }

    cudaFree(d_A);
    cudaFree(d_B);
    return 0;
}