#include <stdio.h>
#include <cuda_runtime.h>
#include "stb_image.h"
#include "stb_image_write.h"

#define BLOCK_SIZE 16  // Define CUDA block size

__device__ int device_min(int a, int b) {
    return (a < b) ? a : b;
}

__device__ int device_max(int a, int b) {
    return (a > b) ? a : b;
}

__global__ void sobelEdgeDetection(unsigned char* d_input, unsigned char* d_output, int width, int height, int channels) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= width || y >= height) return;  // Prevent out-of-bounds memory access

    int Gx[3][3] = {{-1, 0, 1},
                    {-2, 0, 2},
                    {-1, 0, 1}};

    int Gy[3][3] = {{-1, -2, -1},
                    { 0,  0,  0},
                    { 1,  2,  1}};
    
    int sumX = 0, sumY = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            int px = device_min(device_max(x + i, 0), width - 1);
            int py = device_min(device_max(y + j, 0), height - 1);
            int pixel = d_input[py * width + px];
            sumX += pixel * Gx[i + 1][j + 1];
            sumY += pixel * Gy[i + 1][j + 1];
        }
    }

    int edgeValue = device_min(device_max(abs(sumX) + abs(sumY), 0), 255);
    d_output[y * width + x] = edgeValue;
}

void processImage(const char* inputFile, const char* outputFile) {
    int width, height, channels;
    unsigned char* h_input = stbi_load(inputFile, &width, &height, &channels, 1);
    if (!h_input) {
        printf("Error loading image!\n");
        return;
    }
    
    unsigned char *d_input, *d_output;
    cudaMalloc((void**)&d_input, width * height);
    cudaMalloc((void**)&d_output, width * height);
    cudaMemcpy(d_input, h_input, width * height, cudaMemcpyHostToDevice);
    
    dim3 grid((width + BLOCK_SIZE - 1) / BLOCK_SIZE, (height + BLOCK_SIZE - 1) / BLOCK_SIZE);
    dim3 blk(BLOCK_SIZE, BLOCK_SIZE);
    
    sobelEdgeDetection<<<grid, blk>>>(d_input, d_output, width, height, channels);
    cudaDeviceSynchronize();
    
    unsigned char* h_output = (unsigned char*)malloc(width * height);
    cudaMemcpy(h_output, d_output, width * height, cudaMemcpyDeviceToHost);
    
    stbi_write_jpg(outputFile, width, height, 1, h_output, 100);
    
    cudaFree(d_input);
    cudaFree(d_output);
    stbi_image_free(h_input);
    free(h_output);
}

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: %s <input image> <output image>\n", argv[0]);
        return -1;
    }
    processImage(argv[1], argv[2]);
    return 0;
}
