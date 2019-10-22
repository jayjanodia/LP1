#include <bits/stdc++.h>
#include <chrono>

using namespace std;
using namespace std::chrono;

__global__ void addVectors(int *a, int *b, int *c, int n){
	int start = blockIdx.x * 256;

	for(int i = start; i < min(start+256, n); i++){
		c[i] = a[i] + b[i];
	}	

}
int main(){
	int n;
	cout << "Enter number of elements: " ;
	cin >> n;

	int *arr1 = new int[n];
	int *arr2 = new int[n];
	int *res = new int[n];

	int *serialAdd = new int[n];
	srand(time(0));

	for(int i = 0; i < n; i++){
		arr1[i] = rand() % 100;
		arr2[i] = rand() % 100;
	}

	int *devA, *devB, *devRes;

	cudaMalloc(&devA, n * sizeof(int));
	cudaMalloc(&devB, n * sizeof(int));
	cudaMalloc(&devRes, n * sizeof(int));

	cudaMemcpy(devA, arr1, n * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(devB, arr2, n * sizeof(int), cudaMemcpyHostToDevice);

	auto start = high_resolution_clock::now();

	int blocks = ceil(n * 1.0f/256.0f);
	
	addVectors<<<blocks,1>>>(devA, devB, devRes,n);
	auto stop = high_resolution_clock::now();

	cout << "Time for parallel execution: " << duration_cast<microseconds>(stop-start).count() << endl;
	
	cudaMemcpy(res, devRes, n * sizeof(int), cudaMemcpyDeviceToHost);
	
	start = high_resolution_clock::now();
	for(int i = 0; i < n; i++){
		serialAdd[i] = arr1[i] + arr2[i];
	}
	stop = high_resolution_clock::now();
	cout << "Time for serial execution: " << duration_cast<microseconds>(stop-start).count() << endl;

	for(int i = 0; i < n; i++){
		if(res[i] != serialAdd[i]){
			cout << "Wrong answer at: " << i << endl;
      return 1;
		}
	}

  cout << "AC" << endl;
	return 0;
}
