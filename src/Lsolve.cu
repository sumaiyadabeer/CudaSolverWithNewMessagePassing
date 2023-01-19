#include<stdio.h>
#include <string>
#include <stdlib.h>
#include<time.h>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>

#include <algorithm>
#include <iterator>

#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include <assert.h>
#include <chrono>

#include "../inc/b_function.h"
#include "../inc/communication.h"
#include "../inc/eta_function.h"
#include "../inc/helper.h"
#include "../inc/calculate_error.h"

// #define N 16
// #define E 48
#define THREADS_PER_BLOCK 32

#include <cuda_runtime.h>
#include "cublas_v2.h"
#include "device_launch_parameters.h"

using namespace std::chrono;

#define CUDA_CALL(x) do { if((x) != cudaSuccess) { \
    printf("Error at %s:%d\n",__FILE__,__LINE__); \
    printf("%s\n",cudaGetErrorString(x)); \
    system("pause"); \
    return EXIT_FAILURE;}} while(0)


__global__ void solve(int *row_ptr, float *b_sink, float *eta, float *beta, float kappa, float *x ){
	int index = threadIdx.x + blockIdx.x * blockDim.x; 
	//printf("%f \n", eta[index]/(row_ptr[index+1]-row_ptr[index]));	
	//chk kappa
	// x[index]=(-b_sink[0]/beta[0])*(eta[index]/(row_ptr[index+1]-row_ptr[index]));
	x[index]=(eta[index]/(row_ptr[index+1]-row_ptr[index])); 
}



__global__ void solve_scale(int *row_ptr, float *b, float *b_sink, float *eta, float *beta, float kappa, float *x ){
	int index = threadIdx.x + blockIdx.x * blockDim.x; 
	float multiplier=0.0;

	if(abs(b[index]*(-b_sink[0]/beta[0]))>0.0){
		multiplier=(b[index]*(-b_sink[0]/beta[0]));
		printf("%d\t %f \t %f\n",index, b[index], multiplier);
	}
	x[index]=x[index]*multiplier;
	//printf("%f \n", eta[index]/(row_ptr[index+1]-row_ptr[index]));	
	//chk kappa
	//x[index]= (-b_sink/beta)*(eta[index]/(row_ptr[index+1]-row_ptr[index]));
	//x[index]=(-b_sink[0]/beta[0])*(eta[index]/(row_ptr[index+1]-row_ptr[index]));
}

__global__ void solve_shift(int *row_ptr, float *b_sink, float *eta, float *beta, float kappa, float *x ){
	// int index = threadIdx.x + blockIdx.x * blockDim.x; 
	//printf("%f \n", eta[index]/(row_ptr[index+1]-row_ptr[index]));	
	//chk kappa
	//x[index]= (-b_sink/beta)*(eta[index]/(row_ptr[index+1]-row_ptr[index]));
	//x[index]=(-b_sink[0]/beta[0])*(eta[index]/(row_ptr[index+1]-row_ptr[index]));
}

int cublas_two_norm(int N, float *vector, float *norm){
	cublasStatus_t stat;
    cublasHandle_t handle;
    stat = cublasCreate(&handle);
    if (stat != CUBLAS_STATUS_SUCCESS) {
		printf("%d \n", stat);
        printf ("CUBLAS initialization failed\n");
        return EXIT_FAILURE;
    }
    // calculate_DJ<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr, d_J, d_b); 
    stat = cublasSnrm2(handle, N , vector, 1, norm);
    if(stat != CUBLAS_STATUS_SUCCESS) {
        printf ("norm is not calculated using Cublas\n");
        cudaFree (vector);
        cublasDestroy(handle);
        return EXIT_FAILURE;
    }
   
	return EXIT_SUCCESS;
}



int main(void) {
	
	int devNum = -1;
    CUDA_CALL(cudaGetDevice(&devNum));
    CUDA_CALL(cudaSetDevice(devNum));
	printf("Code is executing on device %d \n",devNum );
	// return 0;


	// device copies 
	int *d_row_ptr, *d_col_off, *d_values, *d_b_sum, *d_L; 
	int *d_queue, *d_outbox, *d_cnt, *d_stable_cnt, *d_b_sink_index, *d_sum_Q ;
	float  *d_eta, *d_eta_tminusone, *d_eta_del, *d_eta_max, *d_eta_sum, *d_eta_del_norm;
	float *d_b, *d_J, *d_b_norm, *d_b_sink,  *d_x, *d_Lx_b, *d_Lx_b_norm, *d_beta;
	curandState *d_state;



	std::string file_path="./generated_input.txt";
	std::string answer_file_path="./generated_answer.txt";
	int NE[2];
	read_file_by_line(file_path, NE, 0, 2);
	const unsigned int N = NE[0];
	const unsigned int E = NE[1]; //BECAUSE IN UNDIRECTED GRAPH EVERY EDGE IS COUNTED TWICE
	

// Alloc space for device copies of graph N E and beta epsilon and kappa eta max
	const unsigned int int_size =  sizeof(int);
	const unsigned int float_size = sizeof(float);
	

	CUDA_CALL(cudaMalloc((void **)&d_row_ptr, (N+1)*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_b, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_J, N*float_size));  
	CUDA_CALL(cudaMalloc((void **)&d_b_norm, float_size));
	CUDA_CALL(cudaMalloc((void **)&d_x, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_Lx_b, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_Lx_b_norm, float_size));

	CUDA_CALL(cudaMalloc((void **)&d_eta_sum, float_size));
	CUDA_CALL(cudaMalloc((void **)&d_eta_max, float_size));
	CUDA_CALL(cudaMalloc((void **)&d_eta_del_norm, float_size));
	CUDA_CALL(cudaMalloc((void **)&d_eta, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_eta_del, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_eta_tminusone, N*float_size));
	CUDA_CALL(cudaMalloc((void **)&d_b_sink, float_size));
	CUDA_CALL(cudaMalloc((void **)&d_b_sink_index, int_size));
	CUDA_CALL(cudaMalloc((void **)&d_sum_Q, int_size));
	CUDA_CALL(cudaMalloc((void **)&d_beta, float_size));

	CUDA_CALL(cudaMalloc((void **)&d_col_off, E*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_values, E*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_b_sum, int_size));

	CUDA_CALL(cudaMalloc((void **)&d_queue, N*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_outbox, N*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_cnt, N*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_stable_cnt, N*int_size));
	CUDA_CALL(cudaMalloc((void **)&d_L, N*N*int_size));

	CUDA_CALL(cudaMalloc(&d_state, N*sizeof(curandState)));
	

	//read the graph and b from input file

	int *row_ptr = (int*)malloc((N+1)*int_size);
	read_file_by_line(file_path, row_ptr, 1, N+1);
	
	int *col_off = (int*)malloc(E*int_size);
	read_file_by_line(file_path, col_off, 2, E);

	int *values = (int*)malloc(E*int_size);
	read_file_by_line(file_path, values, 3, E);

	float *b = (float*)malloc(N*float_size);
	read_file_by_line(file_path, b, 4, N);

	// float *jacobi = (float*)malloc((N)*float_size);
	// read_file_by_line(answer_file_path, jacobi, 1, N);

	//assert in function "read_file_by_line" if input is less than N+1/N/E not working 

	

	// // this loop is for printing purpose of input values
	// for (int i=0;i<N;i++){
	// 	std :: cout<<i<<"\t"<< jacobi[i]<<std :: endl;
	// }
	// return -1;
	

// Copy inputs to device
	CUDA_CALL(cudaMemcpy(d_row_ptr, row_ptr, (N+1)*int_size, cudaMemcpyHostToDevice));
	CUDA_CALL(cudaMemcpy(d_col_off, col_off, E*int_size, cudaMemcpyHostToDevice));
	CUDA_CALL(cudaMemcpy(d_values, values, E*int_size, cudaMemcpyHostToDevice));

	CUDA_CALL(cudaMemcpy(d_b, b, N*float_size, cudaMemcpyHostToDevice));
	// CUDA_CALL(cudaMemcpy(d_DJ, b, N*float_size, cudaMemcpyHostToDevice));
 
	printf("input and copy to device done \n");
// Host space allocation
	float *eta = (float*)malloc(N*float_size);
	int *queue = (int*)malloc(N*int_size);
	float *rhs_norm = (float*)malloc(float_size);
	float *Lx_b_norm = (float*)malloc(N*float_size);
	float *beta = (float*)malloc(float_size);
	float *result = (float*)malloc(N*sizeof(float));
	float *eta_del_norm = (float*)malloc(float_size); 
	float *eta_sum = (float*)malloc(float_size);
	float *eta_max = (float*)malloc(float_size);
	
	
//Initial_setup
	
	const double EPS =  1.19209e-07; //1.0/(N*N*N);
	double eta_max_threshold = 0.9; //(0.75)*(1-EPS);	see the logic in paper
	float frac_of_packet_sunk_threshold = 0.9;

	int num_of_blocks =  (N+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK;  
	unsigned int max_epoch	= 100000; //100000; //should depend on graph size and topology
	unsigned int epoch, stable_epoch;
	int sink_index;
	int Q_sink_index;
	int sum_Q;
	float frac_of_packet_sunk;
	int eta_gt_chk_more_thn_i;
	int eta_del_lt_eps_more_thn_i;
	int frac_of_packet_sunk_more_thn_i;
	float send_recv_rounds;
	bool flag_frac_of_packet = false;

	

	*beta = 1.0;
	CUDA_CALL(cudaMemcpy(d_beta, beta, float_size, cudaMemcpyHostToDevice));

	
	get_b_sink<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_b, d_b_sink, N, d_b_sink_index); // return min vale of sink (-9)
	CUDA_CALL(cudaDeviceSynchronize());
	CUDA_CALL(cudaMemcpy(&sink_index, d_b_sink_index, int_size, cudaMemcpyDeviceToHost));
	

	convert_b_to_J<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_b, N, d_b_sink);
	CUDA_CALL(cudaDeviceSynchronize());
	CUDA_CALL(cudaMemcpy(b, d_b, N*float_size, cudaMemcpyDeviceToHost));
	convert_J_to_2betaJ<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_b, N, d_beta); //bcz this will get halved after entering the loop
	CUDA_CALL(cudaDeviceSynchronize());

	//this is calculation of 2 norm of ||DJ||_2 using cublas

    // cublasStatus_t stat;
    // cublasHandle_t handle;
    // stat = cublasCreate(&handle);
    // if (stat != CUBLAS_STATUS_SUCCESS) {
    //     printf ("CUBLAS initialization failed\n");
    //     return EXIT_FAILURE;
    // }
    // // calculate_DJ<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr, d_J, d_b); 
    // stat = cublasSnrm2(handle, N , d_b, 1, rhs_norm);
    // if(stat != CUBLAS_STATUS_SUCCESS) {
    //     printf ("b norm is not calculated using Cublas");
    //     cudaFree (d_b);
    //     cublasDestroy(handle);
    //     return EXIT_FAILURE;
    // }
	// printf("%f \n", *rhs_norm);
	// *rhs_norm = 0.0;

	// printf("%d", cublas_two_norm( N, d_b, rhs_norm));
	// printf("%f \n", *rhs_norm);

	
	do{
		high_resolution_clock::time_point t1 = high_resolution_clock::now();
  		// *beta = *beta/2;
		send_recv_rounds = *beta;
		eta_gt_chk_more_thn_i = 0;
		frac_of_packet_sunk_more_thn_i = 0;
		eta_del_lt_eps_more_thn_i = 0;
		epoch = 0;
		stable_epoch = 0;

		while (send_recv_rounds < 10.0) //this loop is to make sure to generate packet in group of epoch.. waz ctraeting problem inn visualization
			send_recv_rounds *= 10.0;
				
		CUDA_CALL(cudaMemcpy(d_beta, beta, sizeof(float), cudaMemcpyHostToDevice));
		update_b<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_b);
		// CUDA_CALL(cudaMemcpy(b, d_b, N*sizeof(float), cudaMemcpyDeviceToHost));
		// CUDA_CALL(cudaDeviceSynchronize());
		// for (int i=0; i<N; i++)
		// 	printf("%f\t", b[i]);
		// printf("\n");

		initialize<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_cnt, d_queue, d_outbox, d_L, N, E, d_state, 2*rand()); //set eta queue outbox as 0_randomstae
		// initialize<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_stable_cnt, d_queue, d_outbox, d_L, N, E, d_state, 2*rand()); //set eta queue outbox as 0_randomstae
		
		do{
			get_b_sink<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_b, d_b_sink, N, d_b_sink_index);
			CUDA_CALL(cudaMemcpy(beta, d_b_sink, sizeof(float), cudaMemcpyDeviceToHost));
			*beta = -*beta;
			printf("In DRW compute iter: %d beta: %f \n", epoch, *beta);
			copy_eta<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_eta_tminusone);
			CUDA_CALL(cudaDeviceSynchronize());

			for(int i=0; i<(int)send_recv_rounds; i++){
				epoch++;
				stable_epoch++;
				// printf("%d ", epoch);
				send<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr, d_b, d_col_off, d_values, d_queue, d_outbox, d_cnt, d_state,  rand(), rand(), E);
				CUDA_CALL(cudaDeviceSynchronize());
				recv<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_outbox, d_queue, d_b, N);
				CUDA_CALL(cudaDeviceSynchronize());
				
				// CUDA_CALL(cudaMemcpy(queue, d_queue,(N)*sizeof(int), cudaMemcpyDeviceToHost));
				// printf("\nprinting queues: \t");
				// for (int i=0; i<N; i++)
				// 	printf("%d\t", queue[i]);
				// printf("\n");
			}
			// if (flag_frac_of_packet == false){
				calculate_eta<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_cnt, float(epoch));
				CUDA_CALL(cudaDeviceSynchronize());
				CUDA_CALL(cudaMemcpy(eta,d_eta,(N)*sizeof(float), cudaMemcpyDeviceToHost));
			// }else{
			// 	calculate_eta<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_cnt, float(stable_epoch));
			// 	CUDA_CALL(cudaDeviceSynchronize());
			// 	CUDA_CALL(cudaMemcpy(eta,d_eta,(N)*sizeof(float), cudaMemcpyDeviceToHost));
			// }


			printf("\nprinting eta \n");
			for (int i=0; i<N; i++)
				printf("%f\n", eta[i]);
			printf("printing eta ends \n");

			solve<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr, d_b_sink, d_eta,  d_beta, 0.0001 , d_x );//(int *row_ptr, float *b_sink, float *eta, float *beta, float kappa, float *x )
			CUDA_CALL(cudaDeviceSynchronize());			
			CUDA_CALL(cudaMemcpy(eta, d_x, (N)*sizeof(
				float), cudaMemcpyDeviceToHost));

			printf("\nprinting x \n");
			for (int i=0; i<N; i++)
				printf("%f\n", eta[i]);
			printf("printing x ends \n");
			//call kernel for x-x' // later when calculation of x got some speed
			//print x-x' for each coordinate // later when calculation of x got some speed

			Lx_b<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr,  d_col_off, d_values, d_b, d_b_sink, d_beta, d_L, d_x, d_Lx_b, N);
			CUDA_CALL(cudaDeviceSynchronize());
			CUDA_CALL(cudaMemcpy(result, d_Lx_b, N*sizeof(float), cudaMemcpyDeviceToHost));


			printf("printing Lx-b \n");
			for (int i=0;i<N;i++)
				printf("%d \t %f \n",i, result[i]);
			printf("printing Lx-b ends\n");

			
			two_norm<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_Lx_b,d_Lx_b_norm, N);
			one_norm<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_Lx_b,d_Lx_b_norm, N);
			CUDA_CALL(cudaDeviceSynchronize());
			CUDA_CALL(cudaMemcpy(Lx_b_norm, d_Lx_b_norm, sizeof(float), cudaMemcpyDeviceToHost));
			// if (cublas_two_norm( N, d_Lx_b, Lx_b_norm) == EXIT_SUCCESS){
			// 	printf("two norm of Lx-b is calculated using cublas \n");				
			// }else{
			// 	printf("cublas is not calculating norm for Lx-b \n");
			// 	return -1;
			// }
			*Lx_b_norm = sqrt(*Lx_b_norm);
			std::cout<<"Error is " << (*Lx_b_norm)<<std::endl; //<< should be (*Lx_b_norm)/((*beta)*(*rhs_norm)) for actual error
			//call two norm of x-x' here // later when calculation of x got some speed
			//print two norm of x-x' here // later when calculation of x got some speed
			

			// int *LapMat = (int*)malloc(N*N*sizeof(int));
			// cudaMemcpy(LapMat, d_L, N*N*sizeof(int), cudaMemcpyDeviceToHost);                
			// printf("printing LapMat \n");
			// 		for (int i=0; i<N*N; i++){
			// 				printf("%d\t", LapMat[i]);
			// if((i+1)%N==0)
			// 	printf("\n");
			// }
			// printf("printing LapMat ends\n");

			/**************Termination condition prep based on eta del *******************/
			calculate_eta_del<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta_del,d_eta, d_eta_tminusone);
			CUDA_CALL(cudaDeviceSynchronize());
			// if (cublas_two_norm( N, d_eta_del, eta_del_norm) == EXIT_SUCCESS){	
			// 	printf("two norm of eta is calculated using cublas \n");						
			// }else{
			// 	printf("cublas is not calculating norm for eta\n");
			// 	return -1;
			// }
			two_norm<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta_del,d_eta_del_norm, N);
			one_norm<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta_del,d_eta_del_norm, N);
			CUDA_CALL(cudaDeviceSynchronize());
			CUDA_CALL(cudaMemcpy(eta_del_norm, d_eta_del_norm, sizeof(float), cudaMemcpyDeviceToHost));
			*eta_del_norm = sqrt(*eta_del_norm);
			// solve<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_row_ptr, d_b_sink, d_eta,  d_beta, 0.0001 , d_x );
			// cudaDeviceSynchronize();

			/**************Termination condition prep if queues are saturated *******************/
			get_eta_max<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_eta_max, N);
			CUDA_CALL(cudaDeviceSynchronize());
			CUDA_CALL(cudaMemcpy(eta_max, d_eta_max, sizeof(float), cudaMemcpyDeviceToHost));	
			printf("Epoch: %d \t eta_del_norm: %f \t eta_del_norm<=EPS: %s \t eta_del_norm>0: %s \t eta_max_inner: %f\n", epoch, *eta_del_norm, (*(eta_del_norm) <= EPS)?"T":"F", (*(eta_del_norm)>0)?"T":"F", *eta_max);
			/**************Termination condition prep for Q[sink]/(1+sum(Q)) *******************/
	

			CUDA_CALL(cudaMemcpy(&Q_sink_index, d_queue+sink_index, int_size, cudaMemcpyDeviceToHost));
			printf("sink index : %d \n", sink_index );
			one_norm<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_queue, d_sum_Q, N);
			CUDA_CALL(cudaMemcpy(&sum_Q, d_sum_Q, int_size, cudaMemcpyDeviceToHost)); //has some issues
			frac_of_packet_sunk = (float)Q_sink_index/(float)(1+sum_Q);
			printf("**************%f\t %d\t %d\n", frac_of_packet_sunk, Q_sink_index, sum_Q);

			

			// Termination in action	
			if(((*(eta_del_norm) <= EPS) && (*(eta_del_norm)>0))){
				get_eta_max<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_eta_max, N); // these three lines are going to be used after exiting the loop 
				CUDA_CALL(cudaDeviceSynchronize());
				CUDA_CALL(cudaMemcpy(eta_max, d_eta_max, sizeof(float), cudaMemcpyDeviceToHost));

				eta_del_lt_eps_more_thn_i++;
				if (eta_del_lt_eps_more_thn_i >= 10){
					printf("eta_del_norm is lt threshold so breaking\n");
					break;
				}
			}else if((*eta_max > eta_max_threshold)){
				get_eta_max<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_eta_max, N); // these three lines are going to be used after exiting the loop 
				CUDA_CALL(cudaDeviceSynchronize());
				CUDA_CALL(cudaMemcpy(eta_max, d_eta_max, sizeof(float), cudaMemcpyDeviceToHost));
				
				eta_gt_chk_more_thn_i++;
				if (eta_gt_chk_more_thn_i >= 10){
					printf("eta_max is gt threshold so breaking\n");
					break;
				}

			}else if(frac_of_packet_sunk > frac_of_packet_sunk_threshold) {
				get_eta_max<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_eta, d_eta_max, N); // these three lines are going to be used after exiting the loop 
				CUDA_CALL(cudaDeviceSynchronize());
				CUDA_CALL(cudaMemcpy(eta_max, d_eta_max, sizeof(float), cudaMemcpyDeviceToHost));
				
				frac_of_packet_sunk_more_thn_i++;
				if (flag_frac_of_packet != true){
					if (frac_of_packet_sunk_more_thn_i >= 10){ 
						flag_frac_of_packet = true;
						stable_epoch = 0;
						make_cnt_0<<<num_of_blocks,THREADS_PER_BLOCK>>>(d_cnt);
						CUDA_CALL(cudaDeviceSynchronize());
						printf("frac_of_packet_sunk is gt threshold so breaking\n");						
						break; 
					}
				}
					

			}else{
				eta_gt_chk_more_thn_i = 0;
				frac_of_packet_sunk_more_thn_i = 0;
			}

		}while(epoch < max_epoch);
		high_resolution_clock::time_point t2 = high_resolution_clock::now();
  		duration<double> time_span = duration_cast<duration<double>>(t2 - t1);

		printf("epoch: %d \t eta_max: %f \t max_allowed_eta: %f \t duartion: ", epoch, *eta_max, eta_max_threshold);
		
		std::cout<<time_span.count()<<" sec"<<std::endl;
		
		// printf("x_solve.py*beta: ");
		// for(int i=0; i<N; i++)
		// 	printf("%f \t", (jacobi[i])*(*beta));
		// printf("\n");

	}while((*eta_max) > eta_max_threshold && (*eta_max)>0);
	

// Cleanup
	free(row_ptr);    free(b);    free(eta);    free(col_off);    free(values);    free(rhs_norm);	free(Lx_b_norm);	free(beta);    free(result); 	free(eta_del_norm); 	free(eta_sum); 	  free(eta_max);
	cudaFree(d_row_ptr); 	cudaFree(d_b); 	cudaFree(d_J); 	cudaFree(d_b_norm); 	cudaFree(d_x); 	cudaFree(d_Lx_b); 	cudaFree(d_Lx_b_norm);	cudaFree(d_eta_sum);	cudaFree(d_eta_max); 	cudaFree(d_eta_del_norm); 	cudaFree(d_eta); 	cudaFree(d_eta_del);	cudaFree(d_eta_tminusone); 	cudaFree(d_b_sink); 	cudaFree(d_b_sink_index);	cudaFree(d_beta);	cudaFree(d_col_off); 	cudaFree(d_values); 	cudaFree(d_b_sum);	cudaFree(d_queue); 	cudaFree(d_outbox);	cudaFree(d_cnt);	cudaFree(d_L);	cudaFree(&d_state);
	return 0;
}

