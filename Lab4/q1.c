#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>

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
	int rank,size,factsum;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Errhandler_set(MPI_COMM_WORLD,MPI_ERRORS_RETURN);
	int errorcode;
	int sendbuf = rank +1;
	int fact;
	
	errorcode = MPI_Scan(&sendbuf,&fact,1,MPI_INT,MPI_PROD,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	printf("P%d: Factorial of %d is %d\n",rank,rank+1,fact);
	errorcode = MPI_Scan(&fact,&factsum,1,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
	if(errorcode!=MPI_SUCCESS)
	{
		error_handle(errorcode);
	}

	if(rank==size-1)
		printf("Fact sum= %d\n",factsum);
	
	MPI_Finalize();
	return 0;
}