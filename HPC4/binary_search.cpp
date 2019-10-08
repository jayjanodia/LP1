//References:
//https://computing.llnl.gov/tutorials/mpi/
//https://www.tutorialspoint.com/parallel_algorithm/parallel_search_algorithm.htm

#include<iostream>
#include<mpi.h>
//#include<chrono>
//#include<stdio.h>
using namespace std;
//using namespace std::chrono;

void binary_search(int *a, int start, int stop, int key, int rank) {
	while(start <= stop) {
		int m = (start + stop) / 2;
		if (a[m] == key) {
			cout<<"The element is found in process number "<<rank + 1<<endl;
			return;
		}
		else if(a[m] < key) {
			start = m + 1;
		}
		else if (a[m] > key) {
			start = m - 1;
		}
	}
	cout<<"Not found by process number: "<<rank + 1<<endl;
	//printf("Not found by process number: %d\n", rank + 1);
}

int main(int argc, char **argv) {
	int n;
	int key;
	cout<<"Enter range: "<<endl;
	cin>>n;
	cout<<"Enter value between 1 to "<<n<<" to be found: ";
	cin>>key;
	double c[4];
	int *a = new int[n];
	for(int i = 1; i <= n; i++) {
		a[i] = i;
	}
	int rank, blocksize;
	//Initialize MPI execution environment
	MPI_Init(&argc,&argv);
	//Returns the total number of MPI processes in the specified communicator, in this case the MPI_COMM_WORLD
	//MPI_COMM_WORLD is a communicator that represents the number of MPI tasks available to the application
	MPI_Comm_size(MPI_COMM_WORLD, &blocksize);
	cout<<"Block Size: "<<blocksize<<"\t";
	//Returns the rank to the calling MPI process within the specified communicator
	//Initially each process is assigned a unique integer rank between 0 and number_of_tasks - 1 within the communicator
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	cout<<"Rank Size: "<<rank<<"\n";
	blocksize = n/4;
	
	if (rank == 0) {
		//Returns an elapsed wall clock time in seconds on the calling processor
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		cout<<"The time for process 1 is: "<< (stop - start) * 1000 << "\n\n";
		//printf("The time for process 1 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 1) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		cout<<"The time for process 2 is: "<< (stop - start) * 1000 << "\n\n";
		//printf("The time for process 2 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 2) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		cout<<"The time for process 3 is: "<< (stop - start) * 1000 << "\n\n";
		//printf("The time for process 3 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop; 
	}
	if (rank == 3) {
		double start = MPI_Wtime();
		binary_search(a, rank * blocksize, (rank + 1) * blocksize - 1, key, rank);
		double stop = MPI_Wtime();
		cout<<"The time for process 2 is: "<< (stop - start) * 1000 << "\n\n";
		//printf("The time for process 4 is : %lf\n\n", (stop - start) * 1000);
		c[rank] = stop;
	}
	//Terminate the MPI execution environment
	MPI_Finalize();
}
