//References:
//https://computing.llnl.gov/tutorials/mpi/
//https://www.tutorialspoint.com/parallel_algorithm/parallel_search_algorithm.htm


#include<stdio.h>
#include<stdlib.h>
#include<mpi.h>

void binary_search(int *a, int start, int stop, int key, int rank) {
	while(start <= stop) {
		int m = (start + stop) / 2;
		if (a[m] == key) {
			printf("The element is found in process number %d\n", rank + 1);
			return;
		}
		else if(a[m] < key) {
			start = m + 1;
		}
		else if (a[m] > key) {
			start = m - 1;
		}
	}
	printf("Not found by process number: %d\n", rank + 1);
}

int main(int argc, char **argv) {
	int n;
	int key;
	printf("Enter range: ");
	scanf("%d", &n);
	printf("Enter value between 1 to %d to be found: \t", n);
	scanf("%d", &key);	
	double c[4];
	int *a = (int *)malloc(n * sizeof(int));
	for(int i = 1; i <= n; i++) {
		a[i] = i;
	}
	int rank, blocksize;
	//Initialize MPI execution environment
	MPI_Init(&argc,&argv);
	//Returns the total number of MPI processes in the specified communicator, in this case the MPI_COMM_WORLD
	//MPI_COMM_WORLD is a communicator that represents the number of MPI tasks available to the application
	MPI_Comm_size(MPI_COMM_WORLD, &blocksize);
	printf("%d\n", blocksize);
	//Returns the rank to the calling MPI process within the specified communicator
	//Initially each process is assigned a unique integer rank between 0 and number_of_tasks - 1 within the communicator
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	printf("%d\n", rank);
	blocksize = n/4;
	
	if (rank == 0) {
		//Returns an elapsed wall clock time in seconds on the calling processor
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		printf("The time for process 1 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 1) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		printf("The time for process 2 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 2) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		printf("The time for process 3 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 3) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		printf("The time for process 4 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop;
	}
	//Terminate the MPI execution environment
	MPI_Finalize();
}
