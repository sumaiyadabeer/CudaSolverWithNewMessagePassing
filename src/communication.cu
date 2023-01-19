#include "../inc/communication.h"

#include <cassert>


//#define NDEBUG

#ifndef NDEBUG
#define ASSERT_EX(condition, statement) \
    do { \
        if (!(condition)) { statement; assert(condition); } \
    } while (false)
#else
#define ASSERT_EX(condition, statement) ((void)0)
#endif

using namespace std;

__global__ void send(int *row_ptr, float *b, int *col_off, int *values, int *queue, int *outbox, int *cnt, curandState *my_curandstate, int seed, int seed2, int E){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	float rand = curand_uniform(my_curandstate+index);
	//move queue length to register for each thread
	int Q = 0; //define that in Shared mem
	// if(b[index]>=0.0)
	Q = queue[index];
	

//printf("%f \t", b[index]);


//generate packet according b

curand_init(seed, index, 0, &my_curandstate[index]);
rand = curand_uniform(my_curandstate);
if(b[index] > 0){
	if(rand <= b[index])
		{
			Q++;
			// printf("[P %d] ", index);				
		}
}	

	

//select random neighbour based on weight 
if (Q>0 && b[index]>=0.0){
	int neighbour;
	curand_init(seed2, index, 0, &my_curandstate[index]);
	rand = curand_uniform(my_curandstate);
	rand = rand*(row_ptr[index+1]-row_ptr[index]);

	
	ASSERT_EX((row_ptr[index]+(floor(rand))) < row_ptr[index+1], printf("neighbour number selected = %d \t degree is  = %d \n", int(rand) ,  (row_ptr[index+1]-row_ptr[index])));
	assert( (row_ptr[index]+(floor(rand))) < row_ptr[index+1] ); // to chk actual neighbour is selected
	neighbour = col_off[row_ptr[index]+int(floor(rand))];
	// printf(" [%d -> %d] ", index, neighbour );
	//write that neighbour to outbox 
	outbox[index] = neighbour;
	//packet sent is subtracted
	Q = Q-1; 
	cnt[index] = cnt[index]+1;
}



//upate the queue value inreg
	queue[index] = Q;
	
	

	//copy reg value to device memory
	
}


//Simplest rcv 
__global__ void recv(int *outbox, int *queue, float *b, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	int Q = 0;
	for(int i=0; i<n; i++){ //every thread is scanning whole outbox
		if(outbox[i] == index){
			Q++;
		}
	}

	queue[index] = queue[index] + Q;
	outbox[index] = -1;
	//set here the index of sink to whatever now setting as n-1
	// if(b[index]<0){
	// 	queue[index]=0;
	// }
	// //copy the queue to shared mem/reg
	//define shared memory and do looping to get one out box and increment the associated packet to shared mem
	//update the queue value to reg by shared mem 
	//chk eta_t - eta_t-1<epsilon or not

} 

