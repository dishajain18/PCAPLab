#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char*argv[])
{
	int rank,size,num;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Status status;
	if(rank==0)
	{
		num=atoi(argv[1]);
		MPI_Ssend(&num,1,MPI_INT,1,0,MPI_COMM_WORLD);
		MPI_Recv(&num,1,MPI_INT,size-1,size-1,MPI_COMM_WORLD,&status);
		printf("P0 received %d from P%d\n",num,size-1);
	}
	else{
		MPI_Recv(&num,1,MPI_INT,rank-1,rank-1,MPI_COMM_WORLD,&status);
		printf("P%d received %d from P%d\n",rank,num,rank-1);
		num++;
		MPI_Ssend(&num,1,MPI_INT,(rank+1)%size,rank,MPI_COMM_WORLD);
	}
	MPI_Finalize();
	return 0;
}