#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>
#include <unistd.h>

void error_handle(int errorcode)
{
	char string[100];
	int resultlen;
	MPI_Error_string(errorcode,string,&resultlen);
	string[resultlen] = '\0';
	printf("%s\n",string);
	MPI_Finalize();
	exit(-1);
}

int main(int argc, char* argv[])
{
	int rank,size,errorcode;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Errhandler_set(MPI_COMM_WORLD,MPI_ERRORS_RETURN);
	if(size!=4)
	{
		if(rank==0)
			printf("No. of processes not equal to 4\n");
		MPI_Finalize();
		exit(0);
	}
	int matrix[4][4];
	int recv[4];
	if(rank==0)
	{
		printf("Enter 4x4 matrix:\n");
		for(int i=0;i<4;i++)
		{
			for(int j=0;j<4;j++)
				scanf("%d",&matrix[i][j]);
		}
		printf("\n");
	}
	errorcode = MPI_Scatter(matrix,4,MPI_INT,recv,4,MPI_INT,0,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	int sum[4];
	errorcode = MPI_Scan(recv,sum,4,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	for(int i=0;i<4;i++)
	{
		printf("%d ",sum[i]);
	}
	printf("\n");
	MPI_Finalize();
	return 0;
}