#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<cuda_runtime.h>
#include<device_function.h>

#define INT_MAX 2147483647

#define Num 1024

using namespace std;
  
  
__device__ void swap(int &a, int &b){
    int t = a;
    a = b;
    b = t;
}

 
//for > 1024
__global__ void bigBinoticSort(int *arr, int len, int lenMax) {
	unsigned tid = threadIdx.x;
    if (tid >= lenMax) return;
    
	unsigned iter = blockDim.x;
	for (unsigned i = tid; i < lenMax; i += iter) {
		if (i >= len) {
			arr[i] = INT_MAX;
		}
	}
	
	__syncthreads();
	
	int count = 0;
	for (unsigned i = 2; i <= lenMax; i<<=2) {
		for (unsigned j = i >> 1; j > 0; j >>= 1) {
			for (unsigned k = tid; k < lenMax; k += iter) {
                unsigned swapIdx = k ^ j;
                
                if(swapIdx > k){
                    if(((k & i) == 0)){
                        if(arr[k] > arr[swapIdx]){
                            swap(arr[k], arr[swapIdx]);
                        }
                    }
                    else{
                        if(arr[k] < arr[swapIdx]){
                            swap(arr[k], arr[swapIdx]);
                        }
                    }
                }
			}
			__syncthreads();
		}
	}
}


// for <=1024
__global__ void littleBinoticSort(int* arr,int num, int numMax){
    unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if(tid >= num) arr[tid] = INT_MAX;

    __syncthreads();

    for(unsigned int i=2; i<=numMax; i<<=1){
        for(unsigned int j=i>>1; j>0; j>>=1){
            unsigned int swapIdx = tid ^ j;

            if(swapIdx > tid){
                if((tid & i)==0){
                    if(arr[tid] > arr[swapIdx]){
                        swap(arr[tid], arr[swapIdx]);
                    }
                }
                else{
                    if(arr[tid] < arr[swapIdx]){
                        swap(arr[tid], arr[swapIdx]);
                    }
                }
            }

            __syncthreads();
        }
    }
}


int greatestPowerOfTwoLargerThan(int n)
{
    int k=1;
    while (k<n)
        k=k<<1;
    return k;
}


int main(){
    int* arr= (int*) malloc(Num*sizeof(int));

    time_t t;
    srand((unsigned)time(&t));
    for(int i=0;i<Num;i++){
        arr[i] = rand() % 1000; 
    }


    int* ptr;
    cudaError_t err;

    if (Num<=1024){
        int numMax = greatestPowerOfTwoLargerThan(num);

        err = cudaMalloc((void**)&ptr, numMax*sizeof(int));
        if (cudaSuccess != err){
            cout<<"cudaError "<<err<<endl;
            return err;
        }

        err = cudaMemcpy(ptr, arr, Num*sizeof(int), cudaMemcpyHostToDevice);
        if (cudaSuccess != err){
            cout<<"cudaError "<<err<<endl;
            return err;
        }

        littleBinoticSort<<<1, numMax>>>(ptr, Num, numMax);
    }
    else{
        int numMax = greatestPowerOfTwoLargerThan(num);

        err = cudaMalloc((void**)&ptr, numMax*sizeof(int));
        if (cudaSuccess != err){
            cout<<"cudaError "<<err<<endl;
            return err;
        }

        err = cudaMemcpy(ptr, arr, Num*sizeof(int), cudaMemcpyHostToDevice);
        if (cudaSuccess != err){
            cout<<"cudaError "<<err<<endl;
            return err;
        }

        bigBinoticSort<<<1, 1024>>>(ptr, Num, numMax);
    }


    err = cudaMemcpy(arr, ptr, Num*sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaSuccess != err){
        cout<<"cudaError "<<err<<endl;
        return err;
    }

    for(int i=0;i<Num;i++){
        cout<<arr[i]<<" ";
    }
    cout<<endl;

    err = cudaFree(ptr);
    if (cudaSuccess != err){
        cout<<"cudaError "<<err<<endl;
        return err;
    }

    return 0;
}