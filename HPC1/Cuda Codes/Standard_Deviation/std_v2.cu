#include<iostream>
#include<stdio.h>
#include<chrono>

using namespace std;
using namespace std::chrono;

//standard deviation formula: (sqrt(summation(x - mean)^2)/n)

__global__ void standard_deviation(int *a, float *b, float mean, int n) {
    int large_id = blockIdx.x * blockDim.x + threadIdx.x;
    float sum = 0.0;
    for(int i = large_id; i < min(large_id + 256, n); i++) {
        sum += (a[i] - mean) * (a[i] - mean);
        //printf("Sum: %f\t a[%d]: %d\n", sum, i, a[i]);
    }
    b[large_id] = sum/n;
}

void standard_deviation_cpu(int *a, float *b, float mean, int n) {
    for(int i = 0; i < n; i++) {
        b[0] += (a[i] - mean) * (a[i] - mean);
    }
    b[0] /=n;
}

int main(void) {
    int *a, *dev_a, n;
    float *b, *dev_b, mean;
    cout<<"Enter number of elements in array: "<<endl;
    cin>>n;
    a = (int *)malloc(n * sizeof(int)); //a = new int[n];
    b = (float *) malloc (sizeof(int)); // b = new float[n];
    //cout<<"The input numbers are: "<<endl;
    for(int i = 0; i < n; i++) {
        a[i] = i + 1;
        //cout<<a[i]<<"\t";
    }
    cout<<endl;

    mean = (n + 1)/2;
    cout<<"Mean: "<<mean<<endl;

    cudaMalloc(&dev_a, n * sizeof(int));
    cudaMalloc(&dev_b, sizeof(float));
    
    int blocks, threads;
    blocks = threads = ceil(n * 1.0f/256.0f);
    cudaMemcpy(dev_a, a, n * sizeof(int), cudaMemcpyHostToDevice);
    auto start = high_resolution_clock::now();
    standard_deviation <<<blocks, threads>>> (dev_a, dev_b, mean, n);
    auto stop = high_resolution_clock::now();

    cout<<"For GPU: "<<endl;
    cudaMemcpy(b, dev_b, sizeof(float), cudaMemcpyDeviceToHost);
    cout<<"Standard deviation is: "<< sqrt(b[0]) <<"\nTime taken for parallel execution is: "<<duration_cast <microseconds> (stop - start).count() <<endl;

    b[0] = 0.0;
    cout<<"For CPU:" <<endl;
    start = high_resolution_clock::now();
    standard_deviation_cpu(a, b, mean, n);
    stop = high_resolution_clock::now();
    cout<<"Standard deviation is  "<<sqrt(b[0]) <<"\nTime taken for serial execution is: "<< duration_cast <microseconds> (stop - start).count()<<endl;
}