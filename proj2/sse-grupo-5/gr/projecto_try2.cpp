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
	__m128 sumA, sumB;
	float *xi, *xj, *yj;
	float aux[4];
	float sumAtot, sumBtot;

	__m128 divisor = _mm_set_ps1(2*_SMOOTH*_SMOOTH);
	__m128 dividend;
	__m128 quotient;
	__m128 exponential;

	for(xi=x; xi < x+len; xi++, res++)
	{
		sumA = sumB = _mm_setzero_ps();

		for(xj=x, yj=y; xj < x+len; xj+=4, yj+=4)
		{
			// e^[(-(xi-xj)^2) / (2*smoothing^2)]
			dividend = _mm_sub_ps(_mm_setzero_ps(),
						_mm_mul_ps(
							_mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj)),
							_mm_sub_ps(_mm_load_ps1(xi), _mm_load_ps(xj))
							));

			exponential = _mm_exp_ps(_mm_div_ps(dividend, divisor));

			sumA = _mm_add_ps(sumA, _mm_mul_ps(_mm_load_ps(yj), exponential));
			sumB = _mm_add_ps(sumB, exponential);
		}

		_mm_store_ps(aux, sumA); 
		sumAtot = aux[0] + aux[1] + aux[2] + aux[3];

		_mm_store_ps(aux, sumB); 
		sumBtot = aux[0] + aux[1] + aux[2] + aux[3];

		*res = sumAtot/sumBtot;
	}
}


// no changes here
void sse256_smoothing(float *x,float *y,float *res, int len) {
	int i,j;
	__m256 vx1,vx2,vy,va,vb,vres,factor;
	float s = 2*_SMOOTH*_SMOOTH;
	__m256 smooth= _mm256_set_ps(s,s,s,s,s,s,s,s);
	float *auxx1,*auxx2,*auxy,*auxres;

	
	
	for (i=0,auxx1 = x,auxres=res; i<(len>>3); i++,auxx1+=8,auxres+=8) {
		// load (aligned) packed single precision floating point
		vx1      = _mm256_load_ps(auxx1);
		va = vb = _mm256_setzero_ps();
		for(j=0,auxx2 = x,auxy = y;j<(len>>3);j++,auxx2+=8,auxy+=8){
			vx2 = _mm256_load_ps(auxx2);
			vy = _mm256_load_ps(auxy);
			factor = _mm256_sub_ps(vx1,vx2);
			factor = _mm256_mul_ps(factor,factor);
			factor = _mm256_sub_ps(_mm256_setzero_ps(),factor);
			factor = _mm256_div_ps(factor,smooth);
			factor = _mm256_exp_ps(factor);
			va = _mm256_add_ps(va,_mm256_mul_ps(factor,vy));
			vb = _mm256_add_ps(vb,factor);
		}
		vres = _mm256_div_ps(va,vb);

		_mm256_store_ps(auxres,vres);
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
	
	/* WARM UP CACHE FOR SSE256 CASE */
	sse256_smoothing(x,y,res,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		sse256_smoothing(x,y,res,len);
	tEnd = PAPI_get_real_usec();
	timeVector[2] = ((double)(tEnd - tStart))*1000 / iters;

	sprintf(name,"256_%llu.csv",len);
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

	
	printf("==========================================================================\n");
	printf("   COMPUTING SMOOTHING SPEED-UP\n");
 	printf("==========================================================================\n");
	printf("| Vector Length | Original Time [us] | SSE-128 speedup | SSE-256 speedup |\n");
	printf("+---------------+--------------------+-----------------+-----------------+\n");
	for (i=4;i<14; i++){
		smoothing_speedup(1<<i, 5, timeVector);
		printf("|   %10d  |   %16.3f |    %9.6f    |    %9.6f    |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1] , timeVector[0]/timeVector[2] );
	}
	printf("+---------------+--------------------+-----------------+-----------------+\n\n");


	printf("Shuting down PAPI library...\n\n");
	PAPI_shutdown();
	return 0;
}
