#include "../inc/calculate_error.h"
#include "../inc/eta_function.h"


__global__ void Lx_b(int *row_ptr,  int *col_off, int *values, float *b, float *b_sink, float *beta, int *L, float *x, float *ans, int n){
    int index = threadIdx.x + blockIdx.x * blockDim.x;

	//construction of L matrix : use construction of 2d matrix in 1D using macros

	//why not initilizing L to 0s

	//diagonal element D
	int degree = row_ptr[index+1]-row_ptr[index];
	L[(index*n)+index] = degree;

	//admat elelemts -A
	for(int i = row_ptr[index]; i<row_ptr[index+1]; i++){
		L[(col_off[i])+n*(index)]= -values[i];
	//	L[(col_off[i])*n+index]=values[i]; Be careful for undirected graph here
	}

	//calculation of  as ans
	ans[index]=0;
	// if (index == 1)
	// {
		for(int i = n*index;i<n*(index+1);i++){ 
			// printf(" ********** %d \t %d\t %f\n",i,L[i],x[i%n]);
			ans[index] += L[i]*x[(i%n)];//(b[index]/beta[0]*(-b_sink[0]));
			/*if(index==1){`
				printf("%d \t %d\t %f\n",i,L[i],x[i%n]);
			}*/
		}
	// }

	
	// printf("...%d\t%f \t %f\n",index, (b[index]*(-b_sink[0]/beta[0])), b[index]);
	//calculation of Lx-b
	ans[index] = ans[index] - (b[index]); //// because b = \beta*J (b[index]*degree);  (b[index])*((-b_sink[0]/beta[0]));
	//calculate norm of that lx-b //can call eta_norm functions here


}


