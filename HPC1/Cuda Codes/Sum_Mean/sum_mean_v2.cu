#include<iostream>
#include<chrono>
using namespace std;
using namespace std::chrono;

__global__ void sum_mean(int *a, int *b, int n) {
	int large_id = blockIdx.x * blockDim.x + threadIdx.x;
	int sum = 0;
	for(int i = large_id; i < min(large_id+ 256, n); i++) {
		sum += a[i];
	}
	b[large_id] = sum;
}

void sum_mean_cpu(int *a, int *b, int n) {
	int sum = 0;
	for(int i = 0; i < n; i++) {
		sum += a[i];
	}
	b[0] = sum;
}

int main(void) {
	int *a, *b, n;
	int *dev_a, *dev_b;
	cout<<"Enter number of elements in array: "<<endl;
	cin>>n;

	//a = new int[n];
	//b = new int[1];
	a = (int *)malloc(n * sizeof(int));
	b = (int *)malloc(sizeof(int));

	for(int i = 0; i < n; i++) {
		a[i] = i + 1;
	}
	/*cout<<"The numbers stored in the array are: "<<endl;
	for(int i = 0; i < n; i++) {
		cout<<a[i] << " ";
	}
	cout<<endl;*/

	cudaMalloc(&dev_a, n * sizeof(int));
	cudaMalloc(&dev_b, sizeof(int));

	cudaMemcpy(dev_a, a, n * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, sizeof(int), cudaMemcpyHostToDevice);

	int blocks, threads;
	blocks = threads = ceil(n * 1.0f/256.0f);
	
	auto start = high_resolution_clock::now();
	sum_mean <<<blocks, threads>>> (dev_a, dev_b, n);
	auto stop = high_resolution_clock::now();
	cout<<"For GPU: "<<endl;
	cudaMemcpy(b, dev_b, sizeof(int), cudaMemcpyDeviceToHost);
	cout<<"The sum is: " << b[0] << "\nThe mean is: " << b[0] / n << "\nThe time taken for parallel execution is: " << duration_cast<microseconds>(stop-start).count() << endl;

	b[0] = 0;
	start = high_resolution_clock::now();
	sum_mean_cpu (a, b, n);
	stop = high_resolution_clock::now();
	cout<<"For CPU: "<<endl;
	cout<<"The sum is: " << b[0] << "\nThe mean is: " << b[0] / n << "\nThe time taken for serial execution is: " << duration_cast<microseconds>(stop-start).count() << endl;
}