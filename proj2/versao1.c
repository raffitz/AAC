#define _XOPEN_SOURCE 700
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


float randy();
float f(float x);

int main(int argc, char **argv){
	
	int fd;
	
	int N;
	int smooth;
	
	int i,j;
	float sumA;
	float sumB;
	
	float* x;
	float* y;
	float* yest;
	
	if(argc<=2){
		printf("arg number\n");
		exit(-1);
	}
	if(sscanf(argv[1],"%d",&N)!=1){
		printf("missing N\n");
		exit(-1);
	}
	if(sscanf(argv[2],"%d",&smooth)!=1){
		printf("missing smooth\n");
		exit(-1);
	}
	x = malloc(N*sizeof(float));
	y = malloc(N*sizeof(float));
	yest = malloc(N*sizeof(float));
	
	
	/* Initialization loop: */
	for(i=0;i<N;i++){
		x[i] = (float)i / 10;
		y[i] = f(x[i]);
	}
	
	/* Loop a sério: */
	
	for(i=0;i<N;i++){
		sumA=0;
		for(j=1;j<N;j++){
			sumA+=exp((-pow((x[i]-x[j]),2))/(2*smooth*smooth))*y[j];
		}
		sumB=0;
		for(j=1;j<N;j++){
			sumB+=exp((-pow((x[i]-x[j]),2))/(2*smooth*smooth));
		}
		yest[i] = sumA/sumB;
	}	
	
	/* Fim do loop a sério. */
	
	fd = open("./results.csv",O_WRONLY | O_CREAT | O_TRUNC);
	if(fd<0){
		printf("Error creating file\n");
		exit(-1);
	}
	
	
	dprintf(fd,"x,y,yest;\n");
	for(i=0;i<N;i++){
		dprintf(fd,"%f,%f,%f;\n",x[i],y[i],yest[i]);
	}
	close(fd);
	
	free(x);
	free(y);
	free(yest);
	exit(0);
	
}

float randy(){
	return ( rand()* 2.0/ RAND_MAX) - 1;
}

float f(float x){
	return sin(0.02 * x) + sin(0.001*x) + (0.1*randy());
}
