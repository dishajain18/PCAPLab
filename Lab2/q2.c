#include "mpi.h"
#include <stdio.h>

int main(int argc, char*argv[])
{
	int rank,size;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Status status;
	int num;
	if(rank==0)
	{	
		for(int i=1;i<size;i++)
		{
			num=i+30;
			MPI_Send(&num,1,MPI_INT,i,i,MPI_COMM_WORLD);
			printf("P0 Sent %d to P%d\n",num,i);
		}
	}
	else{

		MPI_Recv(&num,1,MPI_INT,0,rank,MPI_COMM_WORLD,&status);
		printf("P%d Recieved %d from P0\n",rank,num);
	}
	MPI_Finalize();
	return 0;
}