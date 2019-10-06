#include<iostream>
#include<chrono>
#include<omp.h>
#include<stdio.h>

using namespace std;
using namespace std::chrono;

//initialize input variables
void init(int *a, int *b, int n) {
	for(int i = 0; i < n; i++) {
		a[i] = b[i] = n - i;
	}
}

//function for serial computing (without openmp)
void serial(int *a, int n) {
	time_point <system_clock> start, stop;
	start = system_clock::now();
	
	for(int i = 0; i < n; i++) {
		for(int j = 0; j < n; j++) {
			if(a[j] > a[j+1]) {
				int temp = a[j];
				a[j] = a[j+1];
				a[j+1] = temp;
			}
		}
	}
	stop = system_clock::now();
	duration <double> elapsed_time = stop - start;
	//time_t end_time = system_clock::to_time_t(stop);
	cout<<"The serial time is: "<<elapsed_time.count()<<endl;
}

//function for parallel computing (with openmp)
void parallel(int *b, int n) {
	time_point <system_clock> start, stop;
	start = system_clock::now();
	//no of threads created by default = number of cores your processor has.
	//One can manually input number of threads they want. Just uncomment the below line and change the values, then run the program
	//omp_set_num_threads = 2;
	int first = 0;
	for(int i = 0; i < n; i++) {
		first = i%2;
		int j;
		//#"pragma omp parallel" is used to specify the parallel region. "for" is used for parallelizing loops
		//two types of variables available: private and shared. Shared data can be accessed by all threads simultaneously
		//Default for loops is private, for the rest it's shared.  
		#pragma omp parallel for default(none) shared(b, first, n) private (i, j)
		for(j = first; j < n - 1; j +=2) {
			if(b[j] > b[j+1]) {
				int temp = b[j];
				b[j] = b[j+1];
				b[j+1] = temp;
			}
		}
	}
	stop = system_clock::now();
	duration <double> elapsed_time = stop - start;
	//time_t end_time = system_clock::to_time_t(stop);
	cout<<"The parallel time is: "<<elapsed_time.count()<<endl;
}

int main() {
	int n, *a, *b;
	cout<<"Enter array size: "<<endl;
	cin>>n;
	a = new int[n];
	b = new int[n];
	init(a, b, n);
	serial(a, n);
	parallel(b, n);
}

//For output,for small numbers output is getting calculated really fast for serial computation. However, for larger numbers output is faster for parallel computation
//input array size as 100000. Parallel computation will be much faster than serial computation
