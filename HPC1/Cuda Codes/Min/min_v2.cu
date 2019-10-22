#include<iostream>
#include<stdio.h>
#include<chrono>
using namespace std;
using namespace std::chrono;

__global__ void minimum(int *a, int *b, int n) {
    int min_limit = 999999;
    int large_id = threadIdx.x + blockIdx.x * blockDim.x;
    for(int i = large_id; i < min(large_id + 256, n); i++) {
        if (min_limit > a[i]) {
            min_limit = a[i];
        }
        //printf("Min limit for %d is %d\n", i, min_limit);
    }
    b[0] = min_limit;
}
    
void minimum_cpu(int *a, int *b, int n) {
    int min_limit = 9999999;
    for(int i = 0; i < n; i++) {
        if(min_limit > a[i]) {
            min_limit = a[i];
        }
    }
    b[0] = min_limit;
}

int main(void) {
    int *a, *b, n;
    int *dev_a, *dev_b;

    cout<<"Enter the number of elements in the array:"<<endl;
    cin>>n;

    a = (int *) malloc(n * sizeof(int));
    b = (int *) malloc(sizeof(int));

    for(int i = 0; i < n; i++) {
        a[i] = rand();
    }
    for(int i = 0; i < n; i++) {
        cout<< a[i] <<endl;
    }
    cudaMalloc(&dev_a, n * sizeof(int));
    cudaMalloc(&dev_b, sizeof(int));

    cudaMemcpy(dev_a, a, n * sizeof(int), cudaMemcpyHostToDevice);
    
    int blocks, threads;
    blocks = threads = ceil(n * 1.0f/256.0f);

    auto start = high_resolution_clock::now();
    minimum <<<blocks, threads>>> (dev_a, dev_b, n);
    auto stop = high_resolution_clock::now();

    cudaMemcpy(b, dev_b, sizeof(int), cudaMemcpyDeviceToHost);
    cout<<"For GPU: "<<endl;
    cout<<"Minimum value is: "<<b[0] << "\nTime taken for parallel execution: "<< duration_cast <microseconds> (stop - start).count() <<endl;

    b[0] = 0;
    start = high_resolution_clock::now();
    minimum_cpu(a, b, n);
    stop = high_resolution_clock::now();

    cout<<"For CPU: "<<endl;
    cout<<"Minimum value is: "<<b[0] << "\nTime taken for serial execution: "<< duration_cast <microseconds> (stop - start).count() << endl;
}