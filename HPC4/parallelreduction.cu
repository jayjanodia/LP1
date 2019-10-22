#include <iostream>
#include <cmath>
#include <cuda.h>
#include <chrono>

using namespace std;
using namespace std::chrono;
__global__ void sum(int *arr, int *sumArr, int n){
	int start = blockIdx.x * 256;

	int sum = 0;
	for(int i = start; i < min(start+256,n); i++){
		sum += arr[i];
	}

	sumArr[blockIdx.x] = sum;
}

__global__ void pMin(int *arr, int *minArr, int n){
	int start = blockIdx.x * 256;
	int minVal = 9999999;
	for(int i = start; i < min(start+256,n); i++){
		if(arr[i] < minVal){minVal = arr[i];}
	}
	minArr[blockIdx.x] = minVal;
}

//These 2 functions are for standard deviation

__global__ void standardDeviation(float *arr, float* calcArr, float mean, int n){
	int start = blockIdx.x * 256;

	float aggregate = 0;
	for(int i = start; i < min(start + 256, n); i++){
		aggregate = aggregate + ((arr[i] - mean) *(arr[i] - mean));
	}

	calcArr[blockIdx.x] = aggregate;
}

__global__ void addAll(float *arr, float *calcArr, int n){
	int start = blockIdx.x * 256;

	float sum = 0;
	for(int i = start; i < min(start + 256, n); i++){
		sum += arr[i];
	}

	calcArr[blockIdx.x] = sum;
}

__global__ void pMax(float *arr, float *maxArr, int n){
	int start = blockIdx.x * 256;

	int maxm = -9999999;
	for(int i = start; i < min(start+256,n); i++){
		if(arr[i] > maxm){
			maxm = arr[i];
		}
	}
	maxArr[blockIdx.x] = maxm;
}



int main(){

	int n;
	cout << "Enter number of elements: ";
	cin >> n;

	int *hostArr,*devArr,*devSumArr, *devMinArr;

	hostArr = new int[n];
	for(int i = 0; i < n; i++){
		hostArr[i] = i+1;
	}

	cudaMalloc(&devArr, n * 4);
	int blocks = ceil(n * 1.0f/256.0f);

	cudaMalloc(&devSumArr, blocks * 4);
	
	
	cudaMemcpy(devArr, hostArr, n*4, cudaMemcpyHostToDevice);
	//Sum
	int curr = n;
  auto start = high_resolution_clock::now();
	while(curr > 1){
		sum<<<blocks, 1>>>(devArr, devSumArr, curr);
		cudaMemcpy(devArr,devSumArr,blocks*4,cudaMemcpyDeviceToDevice);
		curr = ceil(curr* 1.0f/256.0f);
		blocks = ceil(curr*1.0f/256.0f);
				
	}
  auto stop = high_resolution_clock::now();
  
  cout << "parallel: " << duration_cast<microseconds>(stop - start).count() << endl;
  
  start = high_resolution_clock::now();
  long myVal = 0;
  for(int i = 0; i < n; i++){
    myVal = myVal + hostArr[i];
  }
  stop = high_resolution_clock::now();
  cout << "serial: " << duration_cast<microseconds>(stop - start).count() << endl;
	int sum;
	cudaMemcpy(&sum,devArr,4,cudaMemcpyDeviceToHost);
	cout << "Sum: " << sum << endl;
	
	//Min value i
	cudaMalloc(&devMinArr, blocks * 4);
	//Refill device array with values of host array
	cudaMemcpy(devArr,hostArr,n*4,cudaMemcpyHostToDevice);
	
	curr = n;
	blocks = ceil(n * 1.0f/256.0f);
	while(curr > 1){
		pMin<<<blocks, 1>>>(devArr, devMinArr, curr);
		cudaMemcpy(devArr, devMinArr, blocks*4, cudaMemcpyDeviceToDevice);
		curr = blocks;
		blocks = ceil(curr*1.0f/256.0f);
	
	}
	int minVal;
	cudaMemcpy(&minVal, devArr, 4, cudaMemcpyDeviceToHost);
	cout << "min val: " << minVal << endl;

	float mean = (float)sum/n;

	//Standard deviation
	float *fDevArr, *fStdSum;
	blocks = ceil(n * 1.0f/ 256.0f);

	//Create an aggregate array
	cudaMalloc(&fStdSum, sizeof(float) * blocks);
	//Copy mean's value to gpu mean
	
	float *floatHost = new float[n];

	for(int i = 0; i < n; i++){
		floatHost[i] = (float)hostArr[i];
	}
	//Allocate device array space in gpu
	cudaMalloc(&fDevArr, sizeof(float) * n);
	//Refill device array with values of host array
	cudaMemcpy(fDevArr,floatHost, 4 * n, cudaMemcpyHostToDevice);
	
	standardDeviation<<<blocks, 1>>>(fDevArr, fStdSum, mean, n);

  float *myArr = new float[blocks];
  cudaMemcpy(myArr, fStdSum, sizeof(float) * blocks, cudaMemcpyDeviceToHost);
  
  float total = 0;
  for(int i = 0; i < blocks; i++){
    total += myArr[i];
  }
  
  total /= n;
  total = sqrt(total);
  cout << "validation standard deviation: " << total << endl;
	curr = blocks;
	while(curr > 1){
		cudaMemcpy(fDevArr, fStdSum, curr * sizeof(float), cudaMemcpyDeviceToDevice);
		blocks = ceil(curr * 1.0f/256.0f);
    cout << "blocks for aggregation: " << blocks << endl;
		addAll<<<blocks, 1>>>(fDevArr,fStdSum, curr);
		curr = blocks;
	}
	
	float stdDeviation;
	cudaMemcpy(&stdDeviation, fStdSum, sizeof(float), cudaMemcpyDeviceToHost);

	stdDeviation /= n;
	stdDeviation = sqrt(stdDeviation);

	cout << "Standard deviation: " << stdDeviation << endl;

	float *intermediateMax;
	blocks = ceil(n * 1.0f/256.0f);
	cudaMalloc(&intermediateMax, blocks * sizeof(float));

	
	cudaMemcpy(fDevArr,floatHost, 4 * n, cudaMemcpyHostToDevice);
	curr = n;
	while(curr > 1){
		pMax<<<blocks, 1>>>(fDevArr, intermediateMax, curr);
		cudaMemcpy(fDevArr, intermediateMax, blocks*sizeof(float), cudaMemcpyDeviceToDevice);
		float *tempArr = new float[blocks];
		cudaMemcpy(tempArr, intermediateMax, blocks*sizeof(float), cudaMemcpyDeviceToHost);
		cout << "Intermediate maximum values: ";
		for(int i = 0; i < blocks; i++){
			cout << tempArr[i] << " ";
		}
		cout << endl;
		
		curr = blocks;
		blocks = ceil(curr * 1.0f/256.0f);
	}

	float maxm = 0;
	cudaMemcpy(&maxm, intermediateMax, sizeof(float), cudaMemcpyDeviceToHost);

	cout << "Maximum: " << maxm << endl;	
}	
