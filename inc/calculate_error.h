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


__global__ void Lx_b(int *row_ptr,  int *col_off, int *values, float *b, float *b_sink, float *beta, int *L, float *x, float *ans, int n);
