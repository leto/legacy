/* Jonathan Leto <jonathan@leto.net> */
/* Sat Feb 03 04:53:01 EST 2001      */ 
/* Approximate pi using Ramanujan I formula */
/* Compile: gcc -O3 -fomit-frame-pointer -Wall -lgmp ramanujan1.c -o ramanujan1 */
/* More info: http://leto.net/math/pi.html */

#include <stdlib.h> 
#include <stdio.h> 
#include <time.h>
#include "gmp.h"

#define DEF_NUM 50		// Default number of iterations

#define UINT	unsigned long int
#define DEBUG	0

// Supposedly this formula gets 14 decimals per term,
// this is the default precision, in bits 
#define PRECISION ((DEF_NUM*14*8)+1)

// Formula constants
#define K1 545140134
#define K2 13591409
#define K3 640320
#define K4 100100025
#define K5 327843840
#define K6 53360



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

		// (6n)!
		mpz_fac_ui(termint,(UINT) i*6);	
		
		// (i*K1)
		mpz_set_ui(tempi,(UINT) i);
		mpz_mul_ui(tempi,tempi, (UINT) K1);

		// (K2 + i*K1)
		mpz_add_ui(tempi,tempi, (UINT) K2);

		// (6n)! * (K2 + i*K1)
		mpz_mul(termint,termint,tempi);	// Numerator

		/******** Denominator of Term *******/
		mpz_set_ui(tempi,(UINT) i );

		// i!
		mpz_fac_ui(tempi,(UINT) i );
		
		// (i!)^3
		mpz_pow_ui(tempi,tempi, (UINT) 3);

		//  (3i)!
		mpz_fac_ui(tempi2,(UINT) i*3);
		
		// store tempi2 in tempi	
		mpz_mul(tempi,tempi,tempi2);

		// (8*K4*K5)
		mpz_set_ui(tempi2, (UINT) K4 );
		mpz_mul_ui(tempi2, tempi2, (UINT) K5 );
		mpz_mul_ui(tempi2, tempi2, (UINT) 8 );

		// (8*K4*K5)^n
		mpz_pow_ui(tempi2,tempi2,(UINT) i );  

		// denominator	
		mpz_mul(tempi,tempi,tempi2); 
		
		mpf_set_z(tempf,tempi);	
		mpf_set_z(term,termint);
	
		// numerator/denominator
		mpf_div(term,term,tempf);

		// add on evens, subtract on odds
		if( i % 2 == 0) { 
			mpf_add(termsum,termsum,term);
		} else {
			mpf_sub(termsum,termsum,term);
		}	
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

	// K6 * SQRT( K3 )
	mpf_mul_ui(tempf,tempf,(UINT) K6 );

	// woohoo
	mpf_div(pi,tempf,termsum);

	printf("\nTotal time: %.2fms\n pi = \n",time2);
	mpf_out_str(stdout,10,prec_bits,pi);
	printf("\n");

	return 0;	
}
