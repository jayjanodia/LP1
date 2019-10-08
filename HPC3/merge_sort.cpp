#include<iostream>
#include<chrono>
#include<stdio.h>
#include<omp.h>

using namespace std;
using namespace std::chrono;

//initialize the input variables
void init(int *a, int *b, int n) {
	for(int i = 0; i < n; i++) {
		a[i] = b[i] = n - i;
	}
}

void merge (int *a, int s1, int e1, int s2, int e2) {
	//e2 is the last index of the array, s1 is the first index of the array
	int *temp = new int[e2 - s1 + 1];
	int i1 = s1;
	int i2 = s2;
	int k = 0;
	while (i1 <= e1 && i2 <= e2) {
		if(a[i1] < a[i2]) {
			temp[k++] = a[i1++];
		}
		else
			temp[k++] = a[i2++];
	}
	
	while (i1 <= e1) {
		temp[k++] = a[i1++];
	}
	while (i2 <= e2)
		temp[k++] = a[i2++];
		
	for (i1 = s1, i2 = 0; i1 <= e2; i1++, i2++) 
		a[i1] = temp[i2];
}

void serial(int *a, int low, int high) {
	if(low < high) {
		int middle = (low + high)/2;
		serial(a, low, middle);
		serial(a, middle+1, high);
		merge(a, low, middle, middle + 1, high);
	}
}

void parallel(int *b, int low, int high) {
	if (low < high) {
		int middle = (low + high)/2;
		//execute multiple sections for low to middle and middle to high
		#pragma omp parallel sections
		{
			#pragma omp section
			{
				serial(b, low, middle);
			}
			#pragma omp section
			{
				serial(b, middle + 1, high);
			}
		}
		merge(b, low, middle, middle + 1, high);
	}
}

int main() {
	int n, *a, *b;
	cout<<"Enter the number of elements"<< endl;
	cin >> n;
	a = new int[n];
	b = new int[n];
	init(a, b, n);
	time_point <system_clock> start, stop;
	start = system_clock::now();
	serial(a, 0, n-1);
	stop = system_clock::now();
	duration <double> time = stop - start;
	cout<<"The serial time is: "<<time.count()<<endl;
	
	start = system_clock::now();
	parallel(b, 0, n-1);
	stop = system_clock::now();
	duration <double> time1 = stop - start;
	cout<<"The parallel time is: "<<time1.count()<<endl;
}
