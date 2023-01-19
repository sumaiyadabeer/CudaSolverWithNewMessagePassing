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

void random_ints(int* a, int N);
bool cnt0(int *cnt, int n);
void read_file( std:: string file_path, int *arr);
void read_file( std:: string file_path, float *arr);
void read_file_by_line(std:: string file_path, int *arr, int line_no, int len);
void read_file_by_line(std:: string file_path, float *arr, int line_no, int len);
