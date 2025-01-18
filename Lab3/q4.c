#include "mpi.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
	int rank,size;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	char string1[100];
	char string2[100];
	char * final;
	int m;
	if(rank==0)
	{
		printf("Enter string 1: ");
		scanf("%[^\n]c",string1);
		if(strlen(string1)%size)
		{
			printf("String length not divisible by size\n");
			exit(0);
		}
		printf("Enter string 2: ");
		scanf(" %[^\n]c",string2);
		if(strlen(string2)!=strlen(string1))
		{
			printf("String length not equal\n");
			exit(0);
		}
		final=(char*)calloc(strlen(string1)*2+1,sizeof(char));
		m=strlen(string1)/size;
	}
	MPI_Bcast(&m,1,MPI_INT,0,MPI_COMM_WORLD);
	char recvbuf[2];
	for(int i=0;i<m;i++)
	{
		MPI_Scatter(string1+size*i,1,MPI_CHAR,recvbuf,1,MPI_CHAR,0,MPI_COMM_WORLD);
		MPI_Scatter(string2+size*i,1,MPI_CHAR,recvbuf+1,1,MPI_CHAR,0,MPI_COMM_WORLD);
		sleep(1);
		MPI_Gather(recvbuf,2,MPI_CHAR,final+2*size*i,2,MPI_CHAR,0,MPI_COMM_WORLD);
	}

	if(rank==0)
	{
	        sleep(1);
		final[strlen(string1)*2]='\0';
		printf("Resultant String: %s\n",final);
	}
	MPI_Finalize();
	return 0;
}
