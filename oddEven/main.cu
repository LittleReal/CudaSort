#include<iostream>
#include <cuda_runtime.h>

using namespace std;

__global__ void exchangeMin(int* arr, int start){
    int tID = blockDim.x*blockIdx.x + threadIdx.x;
    if (arr[start + tID*2] <= arr[start + tID*2 + 1]){
        return
    }

    int temp = arr[start + tID*2];
    arr[start + tID*2] = arr[start + tID*2 + 1];
    arr[start + tID*2 + 1] = temp;
}

void cudaOddEvenSort(int* arr, int length){
    for (int i = 0; i<length,; i++){
        if (0 == i%2){
            exchangeMin<<<1, length/2, 0, 0>>>(arr, 0);
        }
        else{
            exchangeMin<<<1, (length-1)/2, 0, 0>>>(arr, 1);
        }
    }
}

int main(){
    int length = 9;
    int arr[9]={1, 4, 7, 3, 5, 0, 15, 9, 12};

    int* cudaArr;
    cudaError_t err = cudaMalloc(&cudaArr, length*sizeof(int));
    if (cudaSuccess != err){
        cout<<"cudaMalloc err "<<err<<endl;
        return err;
    }

    err = cudaMemcpy(cudaArr, arr, length*sizeof(int), cudaMemcpyHostToDevice);
    if (cudaSuccess != err){
        cout<<"cudaMemcpy err "<<err<<endl;
        return err;
    }

    cudaOddEvenSort(cudaArr, length);

    err = cudaMemcpy(arr, cudaArr, length*sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaSuccess != err){
        cout<<"cudaMemcpy err "<<err<<endl;
        return err;
    }

    for (int i = 0; i<length; i++){
        cout<<arr[i]<<endl;
    }


    return 0;
}