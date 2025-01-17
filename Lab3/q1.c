#include "mpi.h"
#include <stdio.h>
#include <unistd.h>

int factorial(int n)
{
	if(n==0)
		return 1;
	return n*factorial(n-1);
}

int main(int argc, char* argv[])
{
	int rank,size;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	int sendbuf[size];
	int recvbuf[size];//we can use same buf for send and recv but just for clarity make 2
	int num;
	if(rank==0)
	{
		printf("Enter %d values: ",size);
		for(int i=0;i<size;i++)
			scanf("%d",&sendbuf[i]);
	}
	MPI_Scatter(sendbuf,1,MPI_INT,&num,1,MPI_INT,0,MPI_COMM_WORLD);
	int fact = factorial(num);
	printf("P%d: factorial of %d is %d\n",rank,num,fact);
	MPI_Gather(&fact,1,MPI_INT,recvbuf,1,MPI_INT,0,MPI_COMM_WORLD);
	if(rank==0)
	{
		int sum=0;
		for(int i=0;i<size;i++)
			sum+=recvbuf[i];
		sleep(1); //so that result not displayed until all factorials displayed
		printf("Sum of Factorials is: %d\n",sum);
	}
	MPI_Finalize();
	return 0;
}