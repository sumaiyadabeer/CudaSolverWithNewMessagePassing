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
	float rand;
	//move queue length to register for each thread
	int Q; //define that in Shared mem
	// if(b[index]>=0.0)
	Q = queue[index];
	outbox[index] = -1; //remove this in simplest recv
	

//printf("%f \t", b[index]);


//generate packet according b

curand_init(seed, index, 0, &my_curandstate[index]);
rand = curand_uniform(my_curandstate+index);
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
	int degree = row_ptr[index+1]-row_ptr[index];
	curand_init(seed2, index, 0, &my_curandstate[index]);
	rand = curand_uniform(my_curandstate);
	rand = rand*degree;
	rand = int(floorf(rand));
	if ( rand >= degree ){
		rand = degree - 1;
	}


	ASSERT_EX( int(row_ptr[index]+(int(rand))) < row_ptr[index+1], 
	printf("index %d: neighbour number = %d with col_off index %d \t degree is  = %d \t current row_ptr is = %d \t next row_ptr is = %d\n",
	index,  int(rand) , int(row_ptr[index]+(floorf(rand))), degree, row_ptr[index],  row_ptr[index+1])
	);
	
	//ASSERT_EX(int(row_ptr[index]+(floor(rand))) < row_ptr[index+1], printf("index %d: neighbour number = %d with col_off index %d \t degree is  = %d \t next row_ptr is = %d\n",index,  int(rand) , int(row_ptr[index]+(floor(rand))), (row_ptr[index+1]-row_ptr[index]), row_ptr[index+1]));
	// assert( (row_ptr[index]+(floor(rand))) < row_ptr[index+1] ); // to chk actual neighbour is selected
	neighbour = col_off[row_ptr[index]+int((floorf(rand)))];
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
	//this might be creating the problem
	// outbox[index] = -1;
	
	//set here the index of sink to whatever now setting as n-1
	// if(b[index]<0){
	// 	queue[index]=0;
	// }
	// //copy the queue to shared mem/reg
	//define shared memory and do looping to get one out box and increment the associated packet to shared mem
	//update the queue value to reg by shared mem 
	//chk eta_t - eta_t-1<epsilon or not

} 

// Thrust Recv
__global__ void thrust_recv(int *outbox_count, int *queue, int *outbox_index, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	
	if (outbox_index[index] != -1){
		// printf("%d: copying %d packets to %d\n", index, outbox_count[index], outbox_index[index]);
		queue[outbox_index[index]] = queue[outbox_index[index]] + outbox_count[index];
	}
// outbox[index] = -1;
// outbox_index[index] = -1;

} 

