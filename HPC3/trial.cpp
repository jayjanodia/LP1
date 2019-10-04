//Source: http://www.bowdoin.edu/~ltoma/teaching/cs3225-GIS/fall16/Lectures/openmp.html

//Openmp is a library that supports shared memory multiprocessing
//All threads share memory and data

//We have a master thread(main thread) and slave threads which run in parallel and run the same code
//When a thread finishes, it joins the master

/*OpenMP has directives that allow the programmer to:
	specify the parallel region (create threads)
	specify how to parallelize loops
	specify the scope of the variables in the parallel section(private and shared)
	specify if the threads are to be synchronized
	specify how the works is divided between threads(scheduling) */
	
//Example
/*#include<iostream>
#include<omp.h>
using namespace std;

int main() {
	//specify number of threads. if not specified, then number of cores on PC will be created as threads
	//omp_set_num_threads(8);
	#pragma omp parallel
	{
		cout<<"Hello world\n";
	}
	return 0;
}*/

//In the parallel section, variables can be private(Each thread owns a copy of the variable) or shared among all threads
//Shared threads cause race conditions
//By default all variables are shared except for the loop iteration counter which are private
//Private variables are not initialized and the value is temporary. It's only maintained for use inside the parallel region

/*#include<iostream>
#include<stdio.h>
#include<omp.h>
using namespace std;

int main() {
	int tid, nthreads;
	#pragma omp parallel private(tid) 
	{
		//each thread will have their own copy of tid
		tid = omp_get_thread_num();	//number of threads is stored in tid 
		printf("Hello world from thread %d\n", tid);
		//cout<<"Hello world from thread "<<tid<<endl;
	}
}
*/

//Threads can be synchronized using OpenMP. Available commands are:
//critical: one thread executed at a time, unlike simultaneous execution of multiple threads. Protects against race
//atomic: 

