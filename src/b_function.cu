#include "../inc/b_function.h"


__global__ void initialize(float *eta, int *cnt, int *queue, int *outbox, int *L, int n, int e, curandState *state, int rand){
        int index = threadIdx.x + blockIdx.x * blockDim.x;
	// for (int i=0;i<n;i++){
	// 	L[n*(index)+i]=0;
	// }    
        
        curand_init(rand, index, 0, &state[index]);
        float randd = curand_uniform(state+index);
        // queue[index]= 0;
        queue[index]= int((3)*randd);
        outbox[index]=-1;
        cnt[index]=0;
        eta[index]=0;
        //define N and E in const memory
        //define beta globaly to 1

}

__global__ void convert_b_to_J(float *b,   int n, float *sink_b){
        int index = threadIdx.x + blockIdx.x * blockDim.x;
        //normalization of b 
        //b[index]=b[index]/(-b[n-1]);
        b[index] = b[index]/(-sink_b[0]); 
}
__global__ void convert_J_to_2betaJ(float *J,   int n, float *beta){
        int index = threadIdx.x + blockIdx.x * blockDim.x;
        //normalization of b 
        //b[index]=b[index]/(-b[n-1]);
        J[index] = 2*J[index]*beta[0]; //multiplied by 2 as we are reducing by 2 in each iter
}

__global__ void update_b( float *b){
        //put beta in const memory
        int index = threadIdx.x + blockIdx.x * blockDim.x;
        b[index] = b[index]/2;
}

// __global__ void calculate_DJ(int *row_ptr, float *J, float *normalized_b ){
// 	int index = threadIdx.x + blockIdx.x * blockDim.x; 
// 	J[index] = normalized_b[index] *(row_ptr[index+1]-row_ptr[index]);
// 	// printf("%d \t %f \n", index, normalized_b[index]);
// }

// this could be done by finding min using atomic max
__global__ void get_b_sink( float *b, float *b_sink, int n, int *sink_index){

        int index = threadIdx.x + blockIdx.x * blockDim.x;
        // b_sink[0]=0.0;
        // __syncthreads();
        if (b[index] < 0.0){
                b_sink[0] = b[index];
                sink_index[0] = index;
                // printf("%d", index);
        }
}