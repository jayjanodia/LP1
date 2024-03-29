#include<iostream>
using namespace std;

__global__ void minimum(int *a, int *b, int n) {
    int tid = threadIdx.x;
    int min_limit = 99999;

    for(int i = tid; i < min(tid + 256, n); i++) {
    //for(int i = 0; i < n; i++) will work just fine
        if (min_limit > a[i]) {
            min_limit = a[i];
        }
        //printf("Min limit in %d = %d\n", i,min_limit); //debugging purpose
    }
    b[tid] = min_limit;
}

int main() {
    cout << "Enter the size of the array" << endl;
    int n;
    cin >> n;
    //int a[n]; //does not work in some cuda versions
    int *a = (int *)malloc(n * sizeof(int));
    for(int i = 0; i < n; i++) {
        //a[i] = i;
        a[i] = rand();
    }
    //checking the values of a[i] to see what has been given in the input
    cout<<"The input values given are:"<<endl;
    for(int i = 0; i < n; i++) {
        cout<<a[i]<<"\t";
    }
    cout<<endl;
    int *dev_a, *dev_b;
    int size = n * sizeof(int);

    cudaMalloc(&dev_a, size);
    cudaMalloc(&dev_b, sizeof(int));

    cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);
    minimum<<<1, n>>>(dev_a, dev_b, n);

    int *ans = (int *)malloc(sizeof(int));
    cudaMemcpy(ans, dev_b, sizeof(int), cudaMemcpyDeviceToHost);
    cout<<"The minimum element is: "<<ans[0]<<endl;
}