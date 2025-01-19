#include "mpi.h"
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
	int rank,size;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);
	float averages[size]; // P0 collects averages of all processes here
	float * sendbuf; //sendbuf of P0 with m*n elements
	int m;
	if(rank==0)
	{
		printf("Enter value of m: ");
		scanf("%d",&m);	
		sendbuf=(float*)calloc(m*size,sizeof(float));
		printf("Enter %d values: ",m*size);
		for(int i=0;i<m*size;i++)
			scanf("%f",&sendbuf[i]);
	}

	MPI_Bcast(&m,1,MPI_INT,0,MPI_COMM_WORLD);	
	float mvalues[m]; // All processes receive m elements here
	MPI_Scatter(sendbuf,m,MPI_FLOAT,mvalues,m,MPI_FLOAT,0,MPI_COMM_WORLD);
	float avg=0;
	for(int i=0;i<m;i++)
		avg+=mvalues[i];
	avg/=m;
	printf("P%d: Average of is %.2f\n",rank,avg);
	MPI_Gather(&avg,1,MPI_FLOAT,averages,1,MPI_FLOAT,0,MPI_COMM_WORLD);//can use reduce also
	if(rank==0)
	{
		float totavg=0;
		for(int i=0;i<size;i++)
			totavg+=averages[i];
		totavg/=size;
		sleep(1);
		printf("Total average is: %.2f\n",totavg);
	}
	MPI_Finalize();
	return 0;
}
