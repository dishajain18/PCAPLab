#include "mpi.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int isvowel(char c)
{
	if(c>=65 && c<=90)
		c+=32; //making lowercase
	return (c=='a'||c=='e'||c=='i'||c=='o'||c=='u');
}

int main(int argc, char* argv[])
{
	int rank,size;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	char sendbuf[100];
	int m;
	int results[size]; //gathers nonvowel number into P0 from all processes
	if(rank==0)
	{
		printf("Enter a string: ");
		scanf("%[^\n]c",sendbuf);
		if(strlen(sendbuf)%size)
		{
			printf("String length not divisible by size\n");
			exit(0);
		}
		m=strlen(sendbuf)/size;
	}

	MPI_Bcast(&m,1,MPI_INT,0,MPI_COMM_WORLD);
	char recvbuf[m];
	MPI_Scatter(sendbuf,m,MPI_CHAR,recvbuf,m,MPI_CHAR,0,MPI_COMM_WORLD);
	int nonvowels=0;
	for(int i=0;i<m;i++)
	{
		if(!isvowel(recvbuf[i]))
			nonvowels++;
	}
	MPI_Gather(&nonvowels,1,MPI_INT,results,1,MPI_INT,0,MPI_COMM_WORLD);
	if(rank==0)
	{
		int total=0;
		for(int i=0;i<size;i++)
		{
			printf("P%d: %d Non-vowels\n",i,results[i]);
			total+=results[i];
		}
		sleep(1);
		printf("Total %d Non-vowels\n",total);
	}
	MPI_Finalize();
	return 0;
}
