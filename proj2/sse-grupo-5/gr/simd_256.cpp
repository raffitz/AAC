#include <immintrin.h>
#include <cstdlib>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "papi.h"

#define VECT_LEN 1000000000
#define AVERAGE_ITERS 5

#define _SMOOTH 4

// cache line size
#define CACHE_LINE 64

void write_results(char* name,float*x,float*y,float*res,int len){
	FILE* f;
	int i;

	
	f = fopen(name,"w");
	if(f==NULL){
		printf("Error writing file.\n");
	}
	
	for(i=0;i<len;i++){
		fprintf(f,"%f,%f,%f\n",x[i],y[i],res[i]);
	}

	fclose(f);
	
}



void *aligned_malloc(int size) {
	void *mem,*ptr;
	char *aux;
	// allocate required memory, including some extra space
    mem = malloc(size + CACHE_LINE);
	// point ptr to the beguinning of the next alignmed memory address
	ptr = (void*) (((long long)mem & ~(CACHE_LINE-1)) + CACHE_LINE);
	// store the offset to the original pointer in the previous byte
	aux = (char*) ptr;
    aux[-1] = (char) ((long long) ptr - (long long) mem);
    return ptr;
}

void aligned_free(void *ptr) {
	char* aux;
	long long offset;
	// get original pointer
	aux    = (char*) ptr;
	offset = (long long) (aux[-1]);
	// free original pointer
    free(ptr - offset);
}


float randy(){
	return ( rand() * 2.0 / RAND_MAX ) - 1;
}

float init_function(float x){
	return sin(0.02 * x) + sin(0.001 * x) + (0.1*randy());
}

void init_vector(float* x, float* y, int len){
	int i;

	for(i=0;i<len;i++){
		x[i]=(float)i/10;
	}
	for(i=0;i<len;i++){
		y[i]=init_function((float)i/10);
	}
}

void normal_smoothing(float*x,float*y,float*res,int len){
	int i,j;
	float sumA;
	float sumB;
	float factor;
	for(i=0;i<len;i++){
		sumA = 0;
		sumB = 0;
		for(j=0;j<len;j++){
			factor = exp((-(x[i]-x[j])*(x[i]-x[j]))/(2*_SMOOTH*_SMOOTH));
			sumA += factor*y[j];
			sumB += factor;
		}
		res[i] = sumA/sumB;
	}
}


void sse256_smoothing_simple(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float *aux = (float*) aligned_malloc(8*sizeof(float));
	float sumAtot, sumBtot, s = 2*_SMOOTH*_SMOOTH;

	__m256 divisor = _mm256_div_ps(_mm256_set_ps(1,1,1,1,1,1,1,1), _mm256_broadcast_ss(&s));
	__m256 sumA, sumB;
	__m256 exponential;
	__m256 cache;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm256_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=8, yj+=8)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj));

			exponential = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm256_add_ps(sumB, exponential);
			sumA = _mm256_add_ps(sumA, _mm256_mul_ps(_mm256_load_ps(yj), exponential));
		}

		// horizontaly add sumA and sumB
		_mm256_store_ps(aux, sumA);
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		_mm256_store_ps(aux, sumB);
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		*res = sumAtot/sumBtot;
	}

	aligned_free(aux);
}


void sse256_smoothing_unroll2(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float *aux = (float*) aligned_malloc(8*sizeof(float));
	float sumAtot, sumBtot, s = 2*_SMOOTH*_SMOOTH;

	__m256 divisor = _mm256_div_ps(_mm256_set_ps(1,1,1,1,1,1,1,1), _mm256_broadcast_ss(&s));
	__m256 sumA, sumB, sumA_1, sumB_1;
	__m256 exponential, exponential_1;
	__m256 cache, cache_1;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm256_setzero_ps();
		sumA_1 = sumB_1 = _mm256_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=16, yj+=16)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj));
			cache_1 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+8));

			exponential = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm256_add_ps(sumB, exponential);
			sumA = _mm256_add_ps(sumA, _mm256_mul_ps(_mm256_load_ps(yj), exponential));


			exponential_1 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm256_add_ps(sumB_1, exponential);
			sumA_1 = _mm256_add_ps(sumA_1, _mm256_mul_ps(_mm256_load_ps(yj+8), exponential_1));
		}
		
		sumA = _mm256_add_ps(sumA, sumA_1);
		sumB = _mm256_add_ps(sumB, sumB_1);

		// horizontaly add sumA and sumB
		_mm256_store_ps(aux, sumA);
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		_mm256_store_ps(aux, sumB);
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		*res = sumAtot/sumBtot;
	}

	aligned_free(aux);
}


void sse256_smoothing_unroll3(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float *aux = (float*) aligned_malloc(8*sizeof(float));
	float sumAtot, sumBtot, s = 2*_SMOOTH*_SMOOTH;

	__m256 divisor = _mm256_div_ps(_mm256_set_ps(1,1,1,1,1,1,1,1), _mm256_broadcast_ss(&s));
	__m256 sumA, sumB, sumA_1, sumB_1, sumA_2, sumB_2;
	__m256 exponential, exponential_1, exponential_2;
	__m256 cache, cache_1, cache_2;


	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm256_setzero_ps();
		sumA_1 = sumB_1 = _mm256_setzero_ps();
		sumA_2 = sumB_2 = _mm256_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=24, yj+=24)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj));
			cache_1 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+8));
			cache_2 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+16));

			exponential = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm256_add_ps(sumB, exponential);
			sumA = _mm256_add_ps(sumA, _mm256_mul_ps(_mm256_load_ps(yj), exponential));


			exponential_1 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm256_add_ps(sumB_1, exponential);
			sumA_1 = _mm256_add_ps(sumA_1, _mm256_mul_ps(_mm256_load_ps(yj+8), exponential_1));


			exponential_2 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_2,
								cache_2
								)), divisor));

			sumB_2 = _mm256_add_ps(sumB_2, exponential);
			sumA_2 = _mm256_add_ps(sumA_2, _mm256_mul_ps(_mm256_load_ps(yj+16), exponential_2));
		}
		
		sumA = _mm256_add_ps(sumA, sumA_2);
		sumB = _mm256_add_ps(sumB, sumB_2);

		sumA = _mm256_add_ps(sumA, sumA_1);
		sumB = _mm256_add_ps(sumB, sumB_1);
		
		// horizontaly add sumA and sumB
		_mm256_store_ps(aux, sumA);
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		_mm256_store_ps(aux, sumB);
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		*res = sumAtot/sumBtot;
	}

	aligned_free(aux);
}


void sse256_smoothing_unroll4(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float *aux = (float*) aligned_malloc(8*sizeof(float));
	float sumAtot, sumBtot, s = 2*_SMOOTH*_SMOOTH;

	__m256 divisor = _mm256_div_ps(_mm256_set_ps(1,1,1,1,1,1,1,1), _mm256_broadcast_ss(&s));
	__m256 sumA, sumB, sumA_1, sumB_1, sumA_2, sumB_2, sumA_3, sumB_3;
	__m256 exponential, exponential_1, exponential_2, exponential_3;
	__m256 cache, cache_1, cache_2, cache_3;


	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm256_setzero_ps();
		sumA_1 = sumB_1 = _mm256_setzero_ps();
		sumA_2 = sumB_2 = _mm256_setzero_ps();
		sumA_3 = sumB_3 = _mm256_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=32, yj+=32)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj));
			cache_1 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+8));
			cache_2 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+16));
			cache_3 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+24));

			exponential = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm256_add_ps(sumB, exponential);
			sumA = _mm256_add_ps(sumA, _mm256_mul_ps(_mm256_load_ps(yj), exponential));


			exponential_1 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm256_add_ps(sumB_1, exponential);
			sumA_1 = _mm256_add_ps(sumA_1, _mm256_mul_ps(_mm256_load_ps(yj+8), exponential_1));


			exponential_2 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_2,
								cache_2
								)), divisor));

			sumB_2 = _mm256_add_ps(sumB_2, exponential);
			sumA_2 = _mm256_add_ps(sumA_2, _mm256_mul_ps(_mm256_load_ps(yj+16), exponential_2));


			exponential_3 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_3,
								cache_3
								)), divisor));

			sumB_3 = _mm256_add_ps(sumB_3, exponential);
			sumA_3 = _mm256_add_ps(sumA_3, _mm256_mul_ps(_mm256_load_ps(yj+24), exponential_3));
		}
		
		sumA = _mm256_add_ps(sumA, sumA_3);
		sumB = _mm256_add_ps(sumB, sumB_3);
		
		sumA = _mm256_add_ps(sumA, sumA_2);
		sumB = _mm256_add_ps(sumB, sumB_2);

		sumA = _mm256_add_ps(sumA, sumA_1);
		sumB = _mm256_add_ps(sumB, sumB_1);
		
		// horizontaly add sumA and sumB
		_mm256_store_ps(aux, sumA);
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		_mm256_store_ps(aux, sumB);
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		*res = sumAtot/sumBtot;
	}

	aligned_free(aux);
}


void sse256_smoothing_unroll8(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float *aux = (float*) aligned_malloc(8*sizeof(float));
	float sumAtot, sumBtot, s = 2*_SMOOTH*_SMOOTH;

	__m256 divisor = _mm256_div_ps(_mm256_set_ps(1,1,1,1,1,1,1,1), _mm256_broadcast_ss(&s));
	__m256 sumA, sumB, sumA_1, sumB_1, sumA_2, sumB_2, sumA_3, sumB_3;
	__m256 sumA_4, sumB_4, sumA_5, sumB_5, sumA_6, sumB_6, sumA_7, sumB_7;
	__m256 exponential, exponential_1, exponential_2, exponential_3;
	__m256 exponential_4, exponential_5, exponential_6, exponential_7;
	__m256 cache, cache_1, cache_2, cache_3;
	__m256 cache_4, cache_5, cache_6, cache_7;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm256_setzero_ps();
		sumA_1 = sumB_1 = _mm256_setzero_ps();
		sumA_2 = sumB_2 = _mm256_setzero_ps();
		sumA_3 = sumB_3 = _mm256_setzero_ps();
		sumA_4 = sumB_4 = _mm256_setzero_ps();
		sumA_5 = sumB_5 = _mm256_setzero_ps();
		sumA_6 = sumB_6 = _mm256_setzero_ps();
		sumA_7 = sumB_7 = _mm256_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=64, yj+=64)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj));
			cache_1 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+8));
			cache_2 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+16));
			cache_3 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+24));
			cache_4 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+32));
			cache_5 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+40));
			cache_6 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+48));
			cache_7 = _mm256_sub_ps(_mm256_broadcast_ss(xi), _mm256_load_ps(xj+56));

			exponential = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm256_add_ps(sumB, exponential);
			sumA = _mm256_add_ps(sumA, _mm256_mul_ps(_mm256_load_ps(yj), exponential));


			exponential_1 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm256_add_ps(sumB_1, exponential);
			sumA_1 = _mm256_add_ps(sumA_1, _mm256_mul_ps(_mm256_load_ps(yj+8), exponential_1));


			exponential_2 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_2,
								cache_2
								)), divisor));

			sumB_2 = _mm256_add_ps(sumB_2, exponential);
			sumA_2 = _mm256_add_ps(sumA_2, _mm256_mul_ps(_mm256_load_ps(yj+16), exponential_2));


			exponential_3 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_3,
								cache_3
								)), divisor));

			sumB_3 = _mm256_add_ps(sumB_3, exponential);
			sumA_3 = _mm256_add_ps(sumA_3, _mm256_mul_ps(_mm256_load_ps(yj+24), exponential_3));


			exponential_4 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_4,
								cache_4
								)), divisor));

			sumB_4 = _mm256_add_ps(sumB_4, exponential);
			sumA_4 = _mm256_add_ps(sumA_4, _mm256_mul_ps(_mm256_load_ps(yj+32), exponential_4));


			exponential_5 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_5,
								cache_5
								)), divisor));

			sumB_5 = _mm256_add_ps(sumB_5, exponential);
			sumA_5 = _mm256_add_ps(sumA_5, _mm256_mul_ps(_mm256_load_ps(yj+40), exponential_5));


			exponential_6 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_6,
								cache_6
								)), divisor));

			sumB_6 = _mm256_add_ps(sumB_6, exponential);
			sumA_6 = _mm256_add_ps(sumA_6, _mm256_mul_ps(_mm256_load_ps(yj+48), exponential_6));


			exponential_7 = _mm256_exp_ps(
					_mm256_mul_ps(
						_mm256_sub_ps(_mm256_setzero_ps(),
							_mm256_mul_ps(
								cache_7,
								cache_7
								)), divisor));

			sumB_7 = _mm256_add_ps(sumB_7, exponential);
			sumA_7 = _mm256_add_ps(sumA_7, _mm256_mul_ps(_mm256_load_ps(yj+56), exponential_7));
		}

		sumA = _mm256_add_ps(sumA, sumA_7);
		sumB = _mm256_add_ps(sumB, sumB_7);
		
		sumA = _mm256_add_ps(sumA, sumA_6);
		sumB = _mm256_add_ps(sumB, sumB_6);
		
		sumA = _mm256_add_ps(sumA, sumA_5);
		sumB = _mm256_add_ps(sumB, sumB_5);
		
		sumA = _mm256_add_ps(sumA, sumA_4);
		sumB = _mm256_add_ps(sumB, sumB_4);
		
		sumA = _mm256_add_ps(sumA, sumA_3);
		sumB = _mm256_add_ps(sumB, sumB_3);
		
		sumA = _mm256_add_ps(sumA, sumA_2);
		sumB = _mm256_add_ps(sumB, sumB_2);

		sumA = _mm256_add_ps(sumA, sumA_1);
		sumB = _mm256_add_ps(sumB, sumB_1);
		
		// horizontaly add sumA and sumB
		_mm256_store_ps(aux, sumA);
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		_mm256_store_ps(aux, sumB);
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];

		*res = sumAtot/sumBtot;
	}

	aligned_free(aux);
}


void smoothing_speedup(long long len,long long iters, double *timeVector){
	float *x,*y,*res;
	
	clock_t clk_start, clk_end;
	
	long long i, tStart, tEnd;

	char name[32];

	/* INIT VECTOR 1 */
	x = (float*) aligned_malloc( len * sizeof(float) );
	y = (float*) aligned_malloc( len * sizeof(float) );
	res = (float*) aligned_malloc( len * sizeof(float) );
	init_vector(x,y,len);

	/* WARM UP CACHE FOR NORMAL CASE */
	normal_smoothing(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR NORMAL CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		normal_smoothing(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[0] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"normal_%llu.csv",len);
	write_results(name,x,y,res,len);
	

	/* WARM UP CACHE FOR SSE256 simple CASE */
	sse256_smoothing_simple(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 simple CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing_simple(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[1] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"256_simple_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* WARM UP CACHE FOR SSE256 unroll2 CASE */
	sse256_smoothing_unroll2(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 unroll2 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing_unroll2(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[2] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"256_unroll2_%llu.csv",len);
	write_results(name,x,y,res,len);
	

	/* WARM UP CACHE FOR SSE256 unroll3 CASE */
	sse256_smoothing_unroll3(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 unroll3 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing_unroll3(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[3] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"256_unroll3_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* WARM UP CACHE FOR SSE256 unroll4 CASE */
	sse256_smoothing_unroll4(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 unroll4 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing_unroll4(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[4] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"256_unroll4_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* WARM UP CACHE FOR SSE256 unroll8 CASE */
	sse256_smoothing_unroll8(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 unroll8 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing_unroll8(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[5] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"256_unroll8_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* FREE ALLOCATED MEMORY */
	aligned_free(x);
	aligned_free(y);
	aligned_free(res);

}


int main(void) {

	double timeVector[6];
	int retval;
	long long i;
	
	printf("Initializing PAPI library to get number of clock cycles...\n\n");
	if((retval = PAPI_library_init(PAPI_VER_CURRENT)) != PAPI_VER_CURRENT )
	{
	  printf("Library initialization error! \n");
	  exit(1);
	}

	srand(time(NULL));

	
	puts("=============================================================================================");
	puts("   COMPUTING SMOOTHING SPEEDUP for SSE-256");
 	puts("=============================================================================================");
	puts("| Vector |   Original |   speedup   |   speedup   |   speedup   |   speedup   |   speedup   |");
	puts("| Length |  Time [us] |    simple   | unrolling 2 | unrolling 3 | unrolling 4 | unrolling 8 |");
	puts("+--------+------------+-------------+-------------+-------------+-------------+-------------+");
	for (i=4;i<14; i++){
		smoothing_speedup(1<<i, 5, timeVector);
		printf("|  %5d | %10.1f | %11.6f | %11.6f | %11.6f | %11.6f | %11.6f |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1], timeVector[0]/timeVector[2], timeVector[0]/timeVector[3], timeVector[0]/timeVector[4], timeVector[0]/timeVector[5]);
	}
	puts("+--------+------------+-------------+-------------+-------------+-------------+-------------+\n\n");


	printf("Shuting down PAPI library...\n\n");
	PAPI_shutdown();
	return 0;
}
