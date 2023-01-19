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
#include <stdlib.h>


__global__ void initialize(float *eta, int *cnt, int *queue, int *outbox, int *L, int n, int e, curandState *state, int rand);
__global__ void convert_b_to_J(float *b,   int n, float *sink_b);
__global__ void convert_J_to_2betaJ(float *J,   int n, float *beta);
__global__ void update_b( float *b);
__global__ void get_b_sink( float *b, float *b_sink, int n, int *sink_index);
// __global__ void calculate_DJ(int *row_ptr, float *J, float *normalized_b );
