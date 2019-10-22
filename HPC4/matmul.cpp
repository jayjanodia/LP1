#include <iostream>
#include <chrono>

using namespace std;

using namespace std::chrono;

#define BLOCK_SIZE 16

__global__ void gpuMatMul(int *a, int *b, int *c, int n){
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	if(row < n && col < n){
		int sum = 0;
		for(int i = 0; i < n; i++){
			sum += a[row * n + i] * b[i * n + col];
		}
		c[row * n + col] = sum;
	}
}



int main(){
	int n;
	cout << "Enter the size of array: " << endl;
	cin >> n;
	int **a = new int*[n];
	for(int i = 0; i < n; i++){
		a[i] = new int[n];
	}

	int **b = new int*[n];
	for(int i = 0; i < n; i++){
		b[i] = new int[n];
	}

	int **c = new int*[n];

	for(int i = 0; i < n; i++){
		c[i] = new int[n];
	}

	for(int i = 0; i < n; i++){
		for(int j = 0; j < n; j++){
			a[i][j] = i + j;
			b[i][j] = i + j;
		}
	}


	int *hostA = new int[n*n];
	int *hostB = new int[n*n];
	int *hostC = new int[n*n];
	for(int i = 0; i < n; i++){
		for(int j = 0; j < n; j++){
			hostA[i*n + j] = a[i][j];
			hostB[i*n + j] = b[i][j];
		}
	}

	int *devA, *devB, *devC;

	cudaMalloc(&devA, n*n*sizeof(int));
	cudaMalloc(&devB, n*n*sizeof(int));
	cudaMalloc(&devC, n*n*sizeof(int));

	cudaMemcpy(devA, hostA, n*n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(devB, hostB, n*n*sizeof(int), cudaMemcpyHostToDevice);

	int val = (n + BLOCK_SIZE - 1)/BLOCK_SIZE;
	dim3 grid(val,val);
	dim3 block(BLOCK_SIZE, BLOCK_SIZE);

	auto start = high_resolution_clock::now();
	gpuMatMul<<<grid, block>>>(devA, devB, devC, n);
	auto stop = high_resolution_clock::now();
  
  
  cout << "Parallel Running time: " << duration_cast<microseconds>(stop-start).count() << endl;
	cudaMemcpy(hostC, devC, n * n *sizeof(int), cudaMemcpyDeviceToHost);

  
	int value;

	start = high_resolution_clock::now();
	for(int i = 0; i < n; i++){
		for(int j = 0; j < n; j++){
			value = 0;
			for(int k = 0; k < n; k++){
				value += a[i][k] * b[k][j]; 
			}
			c[i][j] = value;
		}
	}
	stop = high_resolution_clock::now();
	cout << "Serial running time: " << duration_cast<microseconds>(stop-start).count() << endl;

	for(int i = 0; i < n; i++){
		for(int j = 0; j < n; j++){
			if(c[i][j] != hostC[i * n + j]){
				cout <<" WA at " << i << " " << j << endl;
		        }
		}
    		cout << endl;
	}

	cout << "AC" << endl;
	return 0;
}
