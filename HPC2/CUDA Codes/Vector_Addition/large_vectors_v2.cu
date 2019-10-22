#include<iostream>
#include<stdio.h>
#include<chrono>
using namespace std;
using namespace std::chrono;

/*__global__ void addition(int *a, int *b, int *c, int n) {
    int large_id = blockIdx.x * blockDim.x + threadIdx.x;
    for (int i = large_id; i < min(large_id + 256, n); i++) {
        c[i] = a[i] + b[i];
        printf("Test 1 2 3");
    }
}*/

__global__ void addition(int *a, int *b, int *c, int n) {
	int large_id = blockIdx.x * blockDim.x + threadIdx.x;
	while (large_id < n) {
	//if(large_id < n) {
		c[large_id] = a[large_id] + b[large_id];
		large_id += blockDim.x*gridDim.x;
	}
}

void addition_cpu(int *a, int *b, int *c, int n) {
    for(int i = 0; i < n; i++) {
        c[i] = a[i] + b[i];
    }
}

int main(void) {
    int *a, *b, *c;
    int *dev_a, *dev_b, *dev_c;
    int n;
    cin>>n;
    cout<<n;
    a = (int *) malloc(n * sizeof(int));
    b = (int *) malloc(n * sizeof(int));
    c = (int *) malloc(n * sizeof(int));

    for(int i = 0; i < n; i++) {
        a[i] = i + 1;
        b[i] = i + 1;
        c[i] = 0;
    }

    int size = n * sizeof(int);
    cudaMalloc(&dev_a, size);
    cudaMalloc(&dev_b, size);
    cudaMalloc(&dev_c, size);

    cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, size, cudaMemcpyHostToDevice);

    int blocks, threads;
    blocks = threads = ceil(n * 1.0f/256.0f);
    auto start = high_resolution_clock::now();
    addition <<<blocks, threads>>> (dev_a, dev_b, dev_c, n);
    auto stop = high_resolution_clock::now();
    cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);
    cout<<"\nFor GPU:"<<endl;
    /*for(int i = 0; i < n; i++) {
		cout<<a[i]<<"+"<<b[i]<<"="<<c[i]<<endl;
    }*/
    //verify that gpu did work
	int count = 0;
	bool success = true;
	for(int i = 0; i < n; i++) {
		if((a[i] + b[i]) != c[i]) {
			cout<<"Error in "<<a[i]<<"+"<<b[i]<<"="<<c[i]<<endl;
			success = false;
			count++;
		}
	}
	if (success) cout<<"We did it"<<endl;
    cout<<"Number of errors: "<<count<<endl;
    cout<<"\nTime taken for parallel processing: "<<duration_cast <microseconds> (stop - start).count()<<endl;
    for(int i =0; i < n; i++) {
        c[i] = 0;
    }
    start = high_resolution_clock::now();
    addition_cpu(a, b, c, n);
    stop = high_resolution_clock::now();
    cout<<"For CPU: "<<endl;
    cout<<"\nTime taken for serial processing"<<duration_cast <microseconds> (stop - start).count() <<endl;
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
}