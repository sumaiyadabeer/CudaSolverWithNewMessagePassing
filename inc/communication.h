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

__global__ void init_rand(curandState *my_curandstate, int seed);
__global__ void send(int *row_ptr, float *b, int *col_off, int *values, int *queue, int *outbox, int *cnt, curandState *my_curandstate, int seed, int seed2, int E);
__global__ void recv(int *outbox, int *queue, float *b, int n);
__global__ void thrust_recv(int *outbox, int *queue, int *outbox_index, int n);
__global__ void reset_outbox(int *outbox);
