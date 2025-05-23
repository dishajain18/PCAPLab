#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>

__global__ void MatrixMul(int * A,int* B,int*C, int n, int m, int q)
{
    int row = threadIdx.y +blockDim.y * blockIdx.y;
    int col = threadIdx.x + blockDim.x * blockIdx.x;

    if(row < m && col < q)
    {
        int sum = 0;
        for(int k=0; k<n; k++)
            sum += A[row * n + k] * B[k * q + col];

        C[row * q + col] = sum;
    }
}


int main()
{
    printf("Enter matrix dimensions of A(m and n): ");
    int m,n;
    scanf("%d %d",&m,&n);
    int A[m*n];
    printf("Enter matrix dimensions of B(p and q): ");
    int p,q;
    scanf("%d %d",&p,&q);
    if(n!=p)
    {
        printf("Matrix multiplication not possible\n");
        exit(-1);
    }
    int B[p*q];

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



    dim3 blk(2,2,1);
    dim3 grid(ceil(q/2.0),ceil(m/2.0),1);


    MatrixMul<<<grid,blk>>>(d_A,d_B,d_C,n,m,q);

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