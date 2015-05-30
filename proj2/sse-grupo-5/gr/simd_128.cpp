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


void sse128_smoothing(float *x, float *y, float *res, int len)
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

			sumB_1 = _mm_add_ps(sumB, exponential_1);
			sumA_1 = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj+4), exponential_1));
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
	timeVector[0] = ((double)(tEnd - tStart))*1000 / iters;

	sprintf(name,"normal_%llu.csv",len);
	write_results(name,x,y,res,len);
	

	/* WARM UP CACHE FOR SSE128 CASE */
	sse128_smoothing(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse128_smoothing(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[1] = ((double)(tEnd - tStart))*1000 / iters;


	sprintf(name,"128_%llu.csv",len);
	write_results(name,x,y,res,len);
	
	/* FREE ALLOCATED MEMORY */
	aligned_free(x);
	aligned_free(y);
	aligned_free(res);

}


int main(void) {

	double timeVector[4];
	int retval;
	long long i;
	
	printf("Initializing PAPI library to get number of clock cycles...\n\n");
	if((retval = PAPI_library_init(PAPI_VER_CURRENT)) != PAPI_VER_CURRENT )
	{
	  printf("Library initialization error! \n");
	  exit(1);
	}

	srand(time(NULL));

	
	printf("========================================================\n");
	printf("   COMPUTING SMOOTHING SPEED-UP\n");
 	printf("========================================================\n");
	printf("| Vector Length | Original Time [us] | SSE-128 speedup |\n");
	printf("+---------------+--------------------+-----------------+\n");
	for (i=4;i<14; i++){
		smoothing_speedup(1<<i, 5, timeVector);
		printf("|   %10d  |   %16.3f |    %9.6f    |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1]);
	}
	printf("+---------------+--------------------+-----------------+\n\n");


	printf("Shuting down PAPI library...\n\n");
	PAPI_shutdown();
	return 0;
}
