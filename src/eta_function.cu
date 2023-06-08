#include "../inc/eta_function.h"

__global__ void make_cnt_0(int *cnt){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	cnt[index] = 0;
}
__global__ void copy_eta(float *eta, float *eta_mins){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	eta_mins[index]=eta[index];
} 

__global__ void calculate_eta(float *eta, int *cnt, float T){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	eta[index]=(cnt[index])*(1/T);
	//printf("%d \t %d \t %fd \t %f\n", index, cnt[index], T,eta[index]);
} 

__global__ void calculate_etaQ(float *eta, int *Q, float t){
	int index = threadIdx.x + blockIdx.x * blockDim.x;

	float eta_prev = eta[index];

	eta[index] =  (((t-1)*eta_prev) + Q[index])/t; 

	// eta[index]=(cnt[index])*(1/T);
	//printf("%d \t %d \t %fd \t %f\n", index, cnt[index], T,eta[index]);
} 

__global__ void get_eta_max(float *eta,float *eta_max, int n){
	
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	
	if (index==0){
		*eta_max=0.0;
		for(int i=0; i<n;i++){
			if(eta[i]>*eta_max)
				*eta_max=eta[i];
		}
	}
	__syncthreads();
}

__global__ void calculate_eta_del(float *eta_del, float *eta, float *eta_tminus){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	eta_del[index]= eta[index]-eta_tminus[index]; 
}


__global__ void one_norm(float *eta_del, float *one_norm, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	*one_norm=0.0;
	// printf("*****-------------------*******");
	if (index==0){
		for(int i=0; i<n;i++){
			if(eta_del[i]<0){
				*one_norm= *one_norm-eta_del[i];
			}else{
				*one_norm= *one_norm+eta_del[i];
			}	
		}
	 }
}
__global__ void one_norm(int *eta_del, int *one_norm, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	*one_norm=0.0;
	if (index==0){
		for(int i=0; i<n;i++){
			if(eta_del[i]<0){
				*one_norm= *one_norm-eta_del[i];
			}else{
				*one_norm= *one_norm+eta_del[i];
			}	
		}
	 }
}

__global__ void two_norm(float *eta_del,float *two_norm, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	// *two_norm=0.0;
	// printf("%d \t %f \n", n, eta_del[index]);

	eta_del[index] = eta_del[index]*eta_del[index];
	__syncthreads();
	// if (index==0){
	// 	*two_norm = 0.1;
	// 	for(int i=0; i<n;i++){
	// 		*two_norm = *two_norm + eta_del[i];
	// 		// printf("%f", *two_norm); // DONT KNOW WHY REMOVING THIS LINE MAKES EVERYTHING ZERO !!!!!!!!
	// 	}
	// printf(" \n");
	// *two_norm = sqrt(*two_norm);
	// // printf("%f -- \n", two_norm[0]);
	// }

}

__global__ void infinity_norm(float *eta_del,float *infi_norm, int n){
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	*infi_norm=0.0;
	if (index==0){
		for(int i=0; i<n;i++){
			if(abs(eta_del[i])>(*infi_norm)){
				*infi_norm= eta_del[i];
			}		
		}
	 }
}


