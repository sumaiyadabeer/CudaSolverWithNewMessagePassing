#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <time.h>
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

__global__ void make_cnt_0(int *cnt);

__global__ void copy_eta(float *eta, float *eta_mins);

__global__ void calculate_eta(float *eta, int *cnt, float T);

__global__ void calculate_eta_del(float *eta_del, float *eta,float *eta_tminus);

__global__ void two_norm(float *eta_del,float *two_norm, int n); //this function changes tha value of eta-del

__global__ void infinity_norm(float *eta_del,float *infi_norm, int n);

__global__ void one_norm(float *eta_del,float *one_norm, int n);
__global__ void one_norm(int *eta_del, int *one_norm, int n);

__global__ void get_eta_max(float *eta,float *eta_max, int n);
