#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

//for some reason pow(3,1) is coming 2, works fine for all other numbers so not using pow
__global__ void mykernel(int * A, int * B, int n)
{
    int row = threadIdx.x;
    for(int i=0; i<n;i++)
    {
        B[row*n+i] = 1;
        for(int j=1;j<=row+1;j++)
            B[row*n+i] *= A[row*n+i];
    }
}

int main()
{
    printf("Enter dimensions of input matrix: ");
    int m,n;
    scanf("%d %d",&m,&n);
    int A[m*n],B[m*n];
    printf("Enter the matrix: \n");
    int k=0;
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            scanf("%d",&A[k++]);
        }
    }

    int *d_A, *d_B;
    cudaMalloc((void**)&d_A,k*sizeof(int));
    cudaMalloc((void**)&d_B,k*sizeof(int));

    cudaMemcpy(d_A,A,k*sizeof(int),cudaMemcpyHostToDevice);

    mykernel<<<1,m>>>(d_A,d_B,n); //per thread one type of power i.e. thread 1 = same, thread 2 = square ...

    cudaMemcpy(B,d_B,k*sizeof(int),cudaMemcpyDeviceToHost);

    printf("Result: \n");

    k=0;
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

}
