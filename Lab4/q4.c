#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

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
	int rank,size,errorcode,final_len;
	char *final;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	MPI_Errhandler_set(MPI_COMM_WORLD,MPI_ERRORS_RETURN);
	MPI_Status status;
	char word[size];
	char letter;
	if(rank==0)
	{
		printf("Input String of length %d: ",size);
		scanf("%[^\n]c",word);
		if(strlen(word)!=size)
		{
			printf("Length not equal to %d\n",size);
			MPI_Finalize();
			exit(-1);
		}
		final_len= size*(size+1)/2;
		final=(char*)calloc(final_len,sizeof(char));
	}

	MPI_Scatter(word,1,MPI_CHAR,&letter,1,MPI_CHAR,0,MPI_COMM_WORLD);
	printf("P%d: %c\n",rank,letter);
	char str[rank+1];
	for(int i=0;i<=rank;i++)
	{
		str[i]=letter;
	}
	printf("P%d: %s\n",rank,str);

	MPI_Send(str,rank+1,MPI_CHAR,0,rank,MPI_COMM_WORLD);
	if(rank==0)
	{
		int cur=0;
		for(int i=0;i<size;i++)
		{
			cur=i*(i+1)/2;
			MPI_Recv(final+cur,i+1,MPI_CHAR,i,i,MPI_COMM_WORLD,&status);
		}
		final[final_len]='\0';
		printf("Output: %s\n",final);
	}
	MPI_Finalize();
	return 0;
}