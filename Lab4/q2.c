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
	int rank,size,ele,errorcode,occurrance=0;
	int final;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Errhandler_set(MPI_COMM_WORLD,MPI_ERRORS_RETURN);
	if(size!=3)
	{
		if(rank==0)
			printf("No. of processes not equal to 3\n");
		MPI_Finalize();
		exit(0);
	}
	int matrix[3][3];
	int recv[3];
	if(rank==0)
	{
		printf("Enter 3x3 matrix:\n");
		for(int i=0;i<3;i++)
		{
			for(int j=0;j<3;j++)
				scanf("%d",&matrix[i][j]);
		}
		printf("Enter element to be found: ");
		scanf("%d",&ele);
	}
	errorcode = MPI_Scatter(matrix,3,MPI_INT,recv,3,MPI_INT,0,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	errorcode = MPI_Bcast(&ele,1,MPI_INT,0,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	for(int i=0;i<3;i++)
	{
		if(recv[i]==ele)
			occurrance++;
	}
	printf("P%d: found %d occurrances of %d\n",rank,occurrance,ele);
	errorcode = MPI_Reduce(&occurrance,&final,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	if(rank==0)
	{
		sleep(1);
		printf("No. of occurrances of %d are: %d\n",ele,final);
	}

	MPI_Finalize();
	return 0;
}