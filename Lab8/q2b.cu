#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void kernelcol(int * A,int * B,int * C,int m,int n)
{
    int col = threadIdx.x;
    int q = blockDim.x;

    for(int i=0;i<m;i++)
    {
        int sum = 0;
        for(int j=0;j<n;j++)
            sum += A[i*n+j] * B[j*q+col];
        C[i*q+col] = sum;
    }
        
}

int main()
{
    printf("Enter matrix dimensions of A(m and n): ");
    int m,n;
    scanf("%d %d",&m,&n);
    int A[m*n];
    int k=0;
    printf("Enter matrix A: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<n;j++)
        {
            scanf("%d",&A[k++]); //directly reading as 1D array
        }    
    }

    printf("Enter matrix dimensions of B(p and q): ");
    int p,q;
    scanf("%d %d",&p,&q);
    if(n!=p)
    {
        printf("Matrix multiplication not possible\n");
        exit(-1);
    }
    int B[p*q];
    k=0;
    printf("Enter matrix B: \n");
    for(int i=0;i<p;i++)
    {
        for(int j=0;j<q;j++)
        {
            scanf("%d",&B[k++]);
        }   
    }

    int C[m*q];
    int *d_A,*d_B,*d_C;
    cudaMalloc((void**)&d_A,m*n*sizeof(int));
    cudaMalloc((void**)&d_B,p*q*sizeof(int));
    cudaMalloc((void**)&d_C,m*q*sizeof(int));

    cudaMemcpy(d_A,A,m*n*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_B,B,p*q*sizeof(int),cudaMemcpyHostToDevice);

    kernelcol<<<1,q>>>(d_A,d_B,d_C,m,n);

    cudaMemcpy(C,d_C,m*q*sizeof(int),cudaMemcpyDeviceToHost);

    k=0;
    printf("Final matrix C: \n");
    for(int i=0;i<m;i++)
    {
        for(int j=0;j<q;j++)
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