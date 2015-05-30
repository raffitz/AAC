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


void sse128_smoothing_simple(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float aux[4];
	float sumAtot, sumBtot;

	__m128 sumA, sumB;
	__m128 divisor = _mm_div_ps(_mm_set_ps1(1.0), _mm_set_ps1(2*_SMOOTH*_SMOOTH));
	__m128 exponential;
	__m128 cache;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=4, yj+=4)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj));
			exponential = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm_add_ps(sumB, exponential);
			sumA = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj), exponential));
		}

		// horizontaly add sumA and sumB
		_mm_store_ps(aux, _mm_hadd_ps(_mm_hadd_ps(sumA, sumB), _mm_setzero_ps()));

		sumAtot = aux[0];
		sumBtot = aux[1];

		*res = sumAtot/sumBtot;
	}
}


void sse128_smoothing_unroll2(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float aux[4];
	float sumAtot, sumBtot;

	__m128 sumA, sumB, sumA_1, sumB_1;
	__m128 divisor = _mm_div_ps(_mm_set_ps1(1.0), _mm_set_ps1(2*_SMOOTH*_SMOOTH));
	__m128 exponential, exponential_1;
	__m128 cache, cache_1;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm_setzero_ps();
		sumA_1 = sumB_1 = _mm_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=8, yj+=8)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj));
			cache_1 = _mm_sub_ps(_mm_load_ps1(xi+4), _mm_load_ps(xj+4));
			exponential = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm_add_ps(sumB, exponential);
			sumA = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj), exponential));



			exponential_1 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm_add_ps(sumB_1, exponential_1);
			sumA_1 = _mm_add_ps(sumA_1, _mm_mul_ps(_mm_load_ps(yj+4), exponential_1));
		}

		sumA = _mm_add_ps(sumA, sumA_1);
		sumB = _mm_add_ps(sumB, sumB_1);

		// horizontaly add sumA and sumB
		_mm_store_ps(aux, _mm_hadd_ps(_mm_hadd_ps(sumA, sumB), _mm_setzero_ps()));

		sumAtot = aux[0];
		sumBtot = aux[1];

		*res = sumAtot/sumBtot;
	}
}


void sse128_smoothing_unroll3(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float aux[4];
	float sumAtot, sumBtot;

	__m128 sumA, sumB, sumA_1, sumB_1, sumA_2, sumB_2;
	__m128 divisor = _mm_div_ps(_mm_set_ps1(1.0), _mm_set_ps1(2*_SMOOTH*_SMOOTH));
	__m128 exponential, exponential_1, exponential_2;
	__m128 cache, cache_1, cache_2;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm_setzero_ps();
		sumA_1 = sumB_1 = _mm_setzero_ps();
		sumA_2 = sumB_2 = _mm_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=12, yj+=12)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj));
			cache_1 = _mm_sub_ps(_mm_load_ps1(xi+4), _mm_load_ps(xj+4));
			cache_2 = _mm_sub_ps(_mm_load_ps1(xi+8), _mm_load_ps(xj+8));
			exponential = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm_add_ps(sumB, exponential);
			sumA = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj), exponential));



			exponential_1 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm_add_ps(sumB_1, exponential_1);
			sumA_1 = _mm_add_ps(sumA_1, _mm_mul_ps(_mm_load_ps(yj+4), exponential_1));



			exponential_2 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_2,
								cache_2
								)), divisor));

			sumB_2 = _mm_add_ps(sumB_2, exponential_2);
			sumA_2 = _mm_add_ps(sumA_2, _mm_mul_ps(_mm_load_ps(yj+8), exponential_2));
		}

		sumA = _mm_add_ps(sumA, sumA_1);
		sumB = _mm_add_ps(sumB, sumB_1);

		sumA = _mm_add_ps(sumA, sumA_2);
		sumB = _mm_add_ps(sumB, sumB_2);

		// horizontaly add sumA and sumB
		_mm_store_ps(aux, _mm_hadd_ps(_mm_hadd_ps(sumA, sumB), _mm_setzero_ps()));

		sumAtot = aux[0];
		sumBtot = aux[1];

		*res = sumAtot/sumBtot;
	}
}


void sse128_smoothing_unroll4(float *x, float *y, float *res, int len)
{
	float *xi, *xj, *yj;
	float aux[4];
	float sumAtot, sumBtot;

	__m128 sumA, sumB, sumA_1, sumB_1, sumA_2, sumB_2, sumA_3, sumB_3;
	__m128 divisor = _mm_div_ps(_mm_set_ps1(1.0), _mm_set_ps1(2*_SMOOTH*_SMOOTH));
	__m128 exponential, exponential_1, exponential_2, exponential_3;
	__m128 cache, cache_1, cache_2, cache_3;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm_setzero_ps();
		sumA_1 = sumB_1 = _mm_setzero_ps();
		sumA_2 = sumB_2 = _mm_setzero_ps();
		sumA_3 = sumB_3 = _mm_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=16, yj+=16)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			cache = _mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj));
			cache_1 = _mm_sub_ps(_mm_load_ps1(xi+4), _mm_load_ps(xj+4));
			cache_2 = _mm_sub_ps(_mm_load_ps1(xi+8), _mm_load_ps(xj+8));
			cache_3 = _mm_sub_ps(_mm_load_ps1(xi+12), _mm_load_ps(xj+12));
			exponential = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache,
								cache
								)), divisor));

			sumB = _mm_add_ps(sumB, exponential);
			sumA = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj), exponential));



			exponential_1 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_1,
								cache_1
								)), divisor));

			sumB_1 = _mm_add_ps(sumB_1, exponential_1);
			sumA_1 = _mm_add_ps(sumA_1, _mm_mul_ps(_mm_load_ps(yj+4), exponential_1));



			exponential_2 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_2,
								cache_2
								)), divisor));

			sumB_2 = _mm_add_ps(sumB_2, exponential_2);
			sumA_2 = _mm_add_ps(sumA_2, _mm_mul_ps(_mm_load_ps(yj+8), exponential_2));



			exponential_3 = _mm_exp_ps(
					_mm_mul_ps(
						_mm_sub_ps(_mm_setzero_ps(),
							_mm_mul_ps(
								cache_3,
								cache_3
								)), divisor));

			sumB_3 = _mm_add_ps(sumB_3, exponential_3);
			sumA_3 = _mm_add_ps(sumA_3, _mm_mul_ps(_mm_load_ps(yj+12), exponential_3));
		}

		sumA_2 = _mm_add_ps(sumA_2, sumA_3);
		sumB_2 = _mm_add_ps(sumB_2, sumB_3);

		sumA = _mm_add_ps(sumA, sumA_1);
		sumB = _mm_add_ps(sumB, sumB_1);

		sumA = _mm_add_ps(sumA, sumA_2);
		sumB = _mm_add_ps(sumB, sumB_2);

		// horizontaly add sumA and sumB
		_mm_store_ps(aux, _mm_hadd_ps(_mm_hadd_ps(sumA, sumB), _mm_setzero_ps()));

		sumAtot = aux[0];
		sumBtot = aux[1];

		*res = sumAtot/sumBtot;
	}
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
	

	/* WARM UP CACHE FOR SSE128 simple CASE */
	sse128_smoothing_simple(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 simple CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse128_smoothing_simple(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[1] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"128_simple_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* WARM UP CACHE FOR SSE128 unroll2 CASE */
	sse128_smoothing_unroll2(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 unroll2 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse128_smoothing_unroll2(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[2] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"128_unroll2_%llu.csv",len);
	write_results(name,x,y,res,len);
	

	/* WARM UP CACHE FOR SSE128 unroll3 CASE */
	sse128_smoothing_unroll3(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 unroll3 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse128_smoothing_unroll3(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[3] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"128_unroll3_%llu.csv",len);
	write_results(name,x,y,res,len);


	/* WARM UP CACHE FOR SSE128 unroll4 CASE */
	sse128_smoothing_unroll4(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 unroll4 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse128_smoothing_unroll4(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[4] = ((double)(tEnd - tStart)) / iters;

	sprintf(name,"128_unroll4_%llu.csv",len);
	write_results(name,x,y,res,len);

	/* FREE ALLOCATED MEMORY */
	aligned_free(x);
	aligned_free(y);
	aligned_free(res);

}


int main(void) {

	double timeVector[5];
	int retval;
	long long i;
	
	printf("Initializing PAPI library to get number of clock cycles...\n\n");
	if((retval = PAPI_library_init(PAPI_VER_CURRENT)) != PAPI_VER_CURRENT )
	{
	  printf("Library initialization error! \n");
	  exit(1);
	}

	srand(time(NULL));

	
	printf("==========================================================================\n");
	printf("   COMPUTING SMOOTHING SPEEDUP for SSE-128\n");
 	printf("==========================================================================\n");
	printf("| Vector |   Original |   speedup   |   speedup   |   speedup   |   speedup   |\n");
	printf("| Length |  Time [us] |    simple   | unrolling 2 | unrolling 3 | unrolling 4 |\n");
	printf("+--------+------------+-------------+-------------+-------------+-------------+\n");
	for (i=4;i<14; i++){
		smoothing_speedup(1<<i, 5, timeVector);
		printf("|  %5d | %10.1f | %11.6f | %11.6f | %11.6f | %11.6f |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1], timeVector[0]/timeVector[2], timeVector[0]/timeVector[3], timeVector[0]/timeVector[4]);
	}
	printf("+--------+------------+-------------+-------------+-------------+\n\n");


	printf("Shuting down PAPI library...\n\n");
	PAPI_shutdown();
	return 0;
}
