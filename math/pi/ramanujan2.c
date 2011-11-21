/* Jonathan Leto <jonathan@leto.net> */
/* Fri Mar 30 23:56:36 EST 2001      */ 
/* Approximate pi using a Ramanujan formula */
/* Compile: gcc -O3 -fomit-frame-pointer -Wall ramanujan2.c -lgmp -o ramanujan2 */
/* More info: http://leto.net/math/pi.html */

#include <stdlib.h> 
#include <stdio.h> 
#include <time.h>
#include "gmp.h"

#define DEF_NUM 50		// Default number of iterations

#define UINT	unsigned long int
#define DEBUG	0

// Supposedly this formula gets 8 decimals per term,
// this is the default precision, in bits 
#define PRECISION ((DEF_NUM*8*8)+1)
#define mpf_inverse(x) mpf_ui_div((x),(unsigned long int)1,(x))

// Formula constants

#define K1 26390
#define K2 1103
#define K3 8
#define K4 9801



void usage(char *s){
	printf("usage: %s ITERATIONS PRECISION\n",s);
	exit(1);
}

int main (int argc, char **argv) {
        clock_t tv1, tv2;
	double time1=0,time2=0;	
	mpf_t pi;		// final result
	mpf_t term;		// value of term
	mpf_t termsum;		// value of all terms
	mpf_t tempf;		// temp float
	mpz_t tempi,tempi2;	// temp ints
	mpz_t termint;		// integer part of term

	UINT i,num,prec_bits;

	num = (argc < 2) ? DEF_NUM : atoi(argv[1] );
	prec_bits = (argc < 3 ) ? PRECISION : atoi(argv[2]);

	if( num < 1 || prec_bits < 1){
		usage(argv[0]);
	}
	mpz_init(tempi);
	mpz_init(tempi2);
	mpz_init_set_ui(termint,(UINT) 1);

	mpf_set_default_prec(prec_bits);
	mpf_init(pi);
	mpf_init(term);
	mpf_init(termsum);
	mpf_init(tempf);

	tv1 = clock();

	for(i=0;i<num;i++) {
		/******** Numerator of Term ********/

		// (4i)!
		mpz_fac_ui(termint,(UINT) i*4);	
		
		// (i*K1)
		mpz_set_ui(tempi,(UINT) i);
		mpz_mul_ui(tempi,tempi, (UINT) K1);

		// (K2 + i*K1)
		mpz_add_ui(tempi,tempi, (UINT) K2);

		// (4i)! * (K2 + i*K1)
		mpz_mul(termint,termint,tempi);	// Numerator

		/******** Denominator of Term *******/
		mpz_set_ui(tempi,(UINT) i );

		// i!
		mpz_fac_ui(tempi,(UINT) i );
		
		// (i!)^4
		mpz_pow_ui(tempi,tempi, (UINT) 4); 
	
		// 396^(4*i)
		mpz_set_ui(tempi2, (UINT) 396 );
		mpz_pow_ui(tempi2,tempi2, (UINT) 4*i);
		
		// denominator	
		mpz_mul(tempi,tempi,tempi2); 
		
		mpf_set_z(tempf,tempi);	
		mpf_set_z(term,termint);
	
		// numerator/denominator
		mpf_div(term,term,tempf);


		mpf_add(termsum,termsum,term);

		if(DEBUG){
			printf("term sum is ");
			mpf_out_str(stdout,10,prec_bits,termsum);
			printf("\n\n");
		}

		tv2 = clock();
		time1 = (tv2 - tv1)/(CLOCKS_PER_SEC / (double) 1000.0);
		time2 += time1;
		printf("Took %.2fms to find out %ldth term\n",time1,i+1);
	}

	
	// SQRT( K3 )
	mpf_sqrt_ui(tempf,(UINT) K3);

	//  SQRT( K3 ) / K4
	mpf_div_ui(tempf,tempf,(UINT) K4);

	mpf_mul(pi,termsum,tempf);

	// woohoo
	// 1 / sum approx
	mpf_inverse(pi);

	if( time2 > 10000 ){
		printf("\nTotal time: %.2fms \n pi = \n",time2); 
	} else {
		printf("\nTotal time: %.2fms\n pi = \n",time2);
	}
	mpf_out_str(stdout,10,prec_bits,pi);
	printf("\n");

	return 0;	
}
