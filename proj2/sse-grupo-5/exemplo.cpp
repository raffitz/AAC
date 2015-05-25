#include <immintrin.h>
#include <cstdlib>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "papi.h"

#define VECT_LEN 1000000000
#define AVERAGE_ITERS 5

// cache line size
#define CACHE_LINE 64

// compute vector dot product 
void normal_vector_dot_product(float *f1, float *f2, float *res, int len);
void    sse_vector_dot_product(float *f1, float *f2, float *res, int len);

// compute vector inner product 
float normal_vector_inner_product(float *f1, float *f2, int len);
float    sse_vector_inner_product(float *f1, float *f2, int len);

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

void normal_vector_dot_product(float *f1, float *f2, float *res, int len) {
	int i;
	
	for (i=0; i<len; i++) {
		res[i] = f1[i] * f2[i];
	}
}

void sse128_vector_dot_product(float *f1, float *f2, float *res, int len) {
	int i;
	__m128 vect1, vect2, vectRes;
	float *faux1=f1, *faux2=f2, *raux=res;

	/* compute SSE vector product, 4 products at a time */
	for (i=0; i<(len>>2); i++,faux1+=4,faux2+=4,raux+=4) {
		// load packed single precision floating point
		vect1   = _mm_loadu_ps(faux1);
		vect2   = _mm_loadu_ps(faux2);
		// multiply packed single precision floating point vectors
		vectRes = _mm_mul_ps(vect1,vect2);
		// store packed single precision floating point
		_mm_storeu_ps(raux, vectRes);
	}
	/* compute remaining elements */
	for (i=i<<2; i<len; i++) {
		res[i] = f1[i] * f2[i];
	}
}

void sse256_vector_dot_product(float *f1, float *f2, float *res, int len) {
	int i;
	__m256 vect1, vect2, vectRes;
	float *faux1=f1, *faux2=f2, *raux=res;

	/* compute SSE vector product, 8 products at a time */
	for (i=0; i<(len>>3); i++,faux1+=8,faux2+=8,raux+=8) {
		// load packed single precision floating point
		vect1   = _mm256_loadu_ps(faux1);
		vect2   = _mm256_loadu_ps(faux2);
		// multiply packed single precision floating point vectors
		vectRes = _mm256_mul_ps(vect1,vect2);
		// store packed single precision floating point
		_mm256_storeu_ps(raux, vectRes);
	}
	/* compute remaining elements */
	for (i=i<<3; i<len; i++) {
		res[i] = f1[i] * f2[i];
	}
}

float normal_vector_inner_product(float *f1, float *f2, int len) {
	int i;
	float res=0.0;
	
	for (i=0; i<len; i++) {
		res += f1[i] * f2[i];
	}
	return res;
}

float sse128_vector_inner_product(float *f1, float *f2, int len) {
	int i;
	__m128 v1, v2, vectRes, vv;
	float aux[4];
	float *faux1=f1,*faux2=f2;

	/* initialize all four words with zero */
	vectRes = _mm_setzero_ps();
	
	/* compute SSE vector product, 4 products at a time */
	for (i=0; i<(len>>2); i++,faux1+=4,faux2+=4) {
		// load packed single precision floating point
		v1      = _mm_loadu_ps(faux1);
		v2      = _mm_loadu_ps(faux2);
		// multiply packed single precision floating point vectors
		vv      = _mm_mul_ps(v1,v2);
		// accumulate result
		vectRes = _mm_add_ps(vectRes,vv);
	}
	_mm_storeu_ps(aux, vectRes);

	aux[0] = aux[0] + aux[1] + aux[2] + aux[3];
	/* compute remaining elements */
	for (i=i<<2; i<len; i++) {
		aux[0] += f1[i] * f2[i];
	}
	return aux[0];
}

float sse256_vector_inner_product(float *f1, float *f2, int len) {
	int i;
	__m256 v1, v2, vectRes, vv;
	float aux[8];
	float *faux1=f1,*faux2=f2;

	/* initialize all four words with zero */
	vectRes = _mm256_setzero_ps();
	
	/* compute SSE vector product, 4 products at a time */
	for (i=0; i<(len>>3); i++,faux1+=8,faux2+=8) {
		// load packed single precision floating point
		v1      = _mm256_loadu_ps(faux1);
		v2      = _mm256_loadu_ps(faux2);
		// multiply packed single precision floating point vectors
		vv      = _mm256_mul_ps(v1,v2);
		// accumulate result
		vectRes = _mm256_add_ps(vectRes,vv);
	}
	_mm256_storeu_ps(aux, vectRes);

	aux[0] = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];
	/* compute remaining elements */
	for (i=i<<3; i<len; i++) {
		aux[0] += f1[i] * f2[i];
	}
	return aux[0];
}

float sse256lu_vector_inner_product(float *f1, float *f2, int len) {
	int i;
	__m256 va1,va2,va3,va4, vb1,vb2,vb3,vb4, vectRes;
	float aux[8];
	float *faux1=f1,*faux2=f2;

	/* initialize all four words with zero */
	vectRes = _mm256_setzero_ps();
	
	/* compute SSE vector product, 4 products at a time */
	for (i=0; i<(len>>5); i++,faux1+=32,faux2+=32) {
		// load packed single precision floating point
		va1     = _mm256_load_ps(faux1);
		vb1     = _mm256_load_ps(faux2);
		va2     = _mm256_load_ps(faux1+8);
		vb2     = _mm256_load_ps(faux2+8);
		va3     = _mm256_load_ps(faux1+16);
		vb3     = _mm256_load_ps(faux2+16);
		va4     = _mm256_load_ps(faux1+24);
		vb4     = _mm256_load_ps(faux2+24);
		// multiply packed single precision floating point vectors
		va1     = _mm256_mul_ps(va1,vb1);
		va2     = _mm256_mul_ps(va2,vb2);
		va3     = _mm256_mul_ps(va3,vb3);
		va4     = _mm256_mul_ps(va4,vb4);
		// accumulate result
		vb1     = _mm256_add_ps(va1,va2);
		vb2     = _mm256_add_ps(va3,va4);
		vb3     = _mm256_add_ps(vb1,vb2);
		vectRes = _mm256_add_ps(vectRes,vb3);
	}
	_mm256_storeu_ps(aux, vectRes);

	aux[0] = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];
	/* compute remaining elements */
	for (i=i<<5; i<len; i++) {
		aux[0] += f1[i] * f2[i];
	}
	return aux[0];
}

float normal_vect_power(float *f1, int len) {
	int i;
	float res=0.0;
	
	for (i=0; i<len; i++) {
		res += f1[i] * f1[i];
	}
	return sqrt(res);
}

float sse128_vect_power(float *f1, int len) {
	int i;
	__m128 v1,vv,vectRes;
	float aux[4];
	float *faux;

	/* initialize all four words with zero */
	vectRes = _mm_setzero_ps();
	
	/* compute SSE power */
	for (i=0,faux=f1; i<(len>>2); i++,faux+=4) {
		// load (aligned) packed single precision floating point
		v1      = _mm_load_ps(faux);
		// multiply packed single precision floating point vectors
		vv      = _mm_mul_ps(v1,v1);
		// accumulate result
		vectRes = _mm_add_ps(vectRes,vv);
	}
	// store (non-aligned) packed single precision floating point
	_mm_storeu_ps(aux, vectRes);

	aux[0] = aux[0] + aux[1] + aux[2] + aux[3];
	/* compute remaining elements */
	for (i=i<<2; i<len; i++) {
		aux[0] += f1[i] * f1[i];
	}
	return sqrt(aux[0]);
}

float sse256_vect_power(float *f1, int len) {
	int i;
	__m256 v1,vv,vectRes;
	float aux[8];
	float *faux;

	/* initialize all four words with zero */
	vectRes = _mm256_setzero_ps();
	
	/* compute SSE power */
	for (i=0,faux=f1; i<(len>>3); i++,faux+=8) {
		// load (aligned) packed single precision floating point
		v1      = _mm256_load_ps(faux);
		// multiply packed single precision floating point vectors
		vv      = _mm256_mul_ps(v1,v1);
		// accumulate result
		vectRes = _mm256_add_ps(vectRes,vv);
	}
	// store (non-aligned) packed single precision floating point
	_mm256_storeu_ps(aux, vectRes);

	aux[0] = aux[0] + aux[1] + aux[2] + aux[3] + aux[4] + aux[5] + aux[6] + aux[7];
	/* compute remaining elements */
	for (i=i<<3; i<len; i++) {
		aux[0] += f1[i] * f1[i];
	}
	return sqrt(aux[0]);
}

void init_float_vect(float *vect, int len, float min, float max){
	float scale = max-min;
	int i;
	
	for (i=0; i<len; i++)
		vect[i] = ((float)rand()/(float)(RAND_MAX)) * scale - min;
}

void power_speedup(long long len,long long iters, double *timeVector){
	float *falign1,res;
	clock_t clk_start, clk_end;
	long long i, tStart, tEnd;

	/* INIT VECTOR 1 */
	falign1 = (float*) aligned_malloc( len * sizeof(float) );
	init_float_vect(falign1,len,-10.0,10.0);

	/* WARM UP CACHE FOR NORMAL CASE */
	res = normal_vect_power(falign1,len);

	/* COMPUTE AVERAGE TIME FOR NORMAL CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = normal_vect_power(falign1,len);
	tEnd = PAPI_get_real_usec();
	timeVector[0] = ((double)(tEnd - tStart))*1000 / iters;

	/* WARM UP CACHE FOR SSE128 CASE */
	res = sse128_vect_power(falign1,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = sse128_vect_power(falign1,len);
	tEnd = PAPI_get_real_usec();
	timeVector[1] = ((double)(tEnd - tStart))*1000 / iters;
	
	/* WARM UP CACHE FOR SSE256 CASE */
	res = sse256_vect_power(falign1,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = sse256_vect_power(falign1,len);
	tEnd = PAPI_get_real_usec();
	timeVector[2] = ((double)(tEnd - tStart))*1000 / iters;

	/* FREE ALLOCATED MEMORY */
	aligned_free(falign1);

}

void inner_product_speedup(long long len,long long iters, double *timeVector){
	float *falign1,*falign2,res;
	long long i, tStart, tEnd;

	/* INIT VECTOR 1 */
	falign1 = (float*) aligned_malloc( len * sizeof(float) );
	init_float_vect(falign1,len,-10.0,10.0);

	/* INIT VECTOR 2 */
	falign2 = (float*) aligned_malloc( len * sizeof(float) );
	init_float_vect(falign2,len,-10.0,10.0);

	/* WARM UP CACHE FOR NORMAL CASE */
	res = normal_vector_inner_product(falign1,falign2,len);

	/* COMPUTE AVERAGE TIME (in ms) FOR NORMAL CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = normal_vector_inner_product(falign1,falign2,len);
	tEnd = PAPI_get_real_usec();
	timeVector[0] = ((double)(tEnd - tStart))*1000 / iters;

	/* WARM UP CACHE FOR SSE128 CASE */
	res = sse128_vector_inner_product(falign1,falign2,len);

	/* COMPUTE AVERAGE TIME FOR SSE128 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = sse128_vector_inner_product(falign1,falign2,len);
	tEnd = PAPI_get_real_usec();
	timeVector[1] = ((double)(tEnd - tStart))*1000 / iters;
	
	/* WARM UP CACHE FOR SSE256 CASE */
	res = sse256_vector_inner_product(falign1,falign2,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 CASE */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = sse256_vector_inner_product(falign1,falign2,len);
	tEnd = PAPI_get_real_usec();
	timeVector[2] = ((double)(tEnd - tStart))*1000 / iters;

	/* WARM UP CACHE FOR SSE256 CASE, WITH LOOP UNROLLING */
	res = sse256lu_vector_inner_product(falign1,falign2,len);

	/* COMPUTE AVERAGE TIME FOR SSE256 CASE, WITH LOOP UNROLLING */
	tStart = PAPI_get_real_usec();
	for (i=0; i<iters; i++)
		res = sse256lu_vector_inner_product(falign1,falign2,len);
	tEnd = PAPI_get_real_usec();
	timeVector[3] = ((double)(tEnd - tStart))*1000 / iters;
	
	/* FREE ALLOCATED MEMORY */
	aligned_free(falign1);
	aligned_free(falign2);
		
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
	printf("   COMPUTING POWER SPEED-UP\n");
 	printf("==========================================================================\n");
	printf("| Vector Length | Original Time [us] | SSE-128 speedup | SSE-256 speedup |\n");
	printf("+---------------+--------------------+-----------------+-----------------+\n");
	for (i=4;i<20; i++){
		power_speedup(1<<i,128,timeVector);
		printf("|   %10d  |   %16.3f |    %9.6f    |    %9.6f    |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1] , timeVector[0]/timeVector[2] );
	}
	printf("+---------------+--------------------+-----------------+-----------------+\n\n");

 	printf("================================================================================================================\n");
	printf("   COMPUTING DOT PRODUCT SPEED-UP\n");
 	printf("================================================================================================================\n");
	printf("| Vector Length | Original Time [us] | SSE-128 speedup | SSE-256 speedup | SSE-256 + 4x Loop Unrolling speedup |\n");
	printf("+---------------+--------------------+-----------------+-----------------+-------------------------------------+\n");
	for (i=4;i<20; i++){
		inner_product_speedup(1<<i,128,timeVector);
		printf("|   %10d  |   %16.3f |    %9.6f    |    %9.6f    |             %9.6f               |\n", 1<<i, timeVector[0], timeVector[0]/timeVector[1] , timeVector[0]/timeVector[2] , timeVector[0]/timeVector[3] );
	}
	printf("+---------------+--------------------+-----------------+-----------------+-------------------------------------+\n");

	printf("Shuting down PAPI library...\n\n");
	PAPI_shutdown();
	return 0;
}