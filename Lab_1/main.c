/******************************************************************************
*******************************************************************************/
#include <stdio.h>
#include <xtime_l.h>
#include <xil_cache.h>
#include <math.h>
#include "FFT_Header.h"
#include "Stage7.h"

#define N 128

complex X_DFT[N];
complex X_FFT[N];
complex X_FFT_Assembly[N];

//Function
extern void Stage6_Assembly(complex *output, complex *input);
extern void Stage6(complex *output, complex *input);

int Re_ordering(int x) {
	return 64 * (x % 2) + 32 * ((x % 4) / 2) + 16 * ((x % 8) / 4)
			+ 8 * ((x % 16) / 8) + 4 * ((x % 32) / 16) + 2 * ((x % 64) / 32)
			+ x / 64;
}

void DFT()
{
	int n = 0, i = 0 ,k = 0;

	complex input[N];
	complex temp_mult[N];

	int out_re[N] = {0,};
	int out_im[N] = {0,};

	for (n=0; n<N/2; n++)
	{
		input[2*n].re=in_real[n];
		input[2*n].im=in_imag[n];
		input[2*n+1].re= 0;
		input[2*n+1].im= 0;
	}

	for (i=0; i<N; i++)
	{
		X_DFT[i] = add_cal(init1_int,init2_int);
		for (k=0; k<N/2; k++)
		{
			//Input의 홀수 원소는 모두 0이므로 짝수 원소만 multiple, add 진행
			//W가 64까지 존재, 128으로 나눈 값들을 W64로 표현해야함
			temp_mult[2*k] = multiple(input[2*k],W[((2*k*i)%128)/2]);
			X_DFT[i] = add_cal(temp_mult[2*k],X_DFT[i]);
		}
	}

	for (n=0; n<N; n++)
	{
		out_re[n] = X_DFT[n].re;
		out_im[n] = X_DFT[n].im;
	}

}

void FFT()
{
	complex input[N],temp[N];

	int out_re[N];
	int out_im[N];

	int data;
	int n,k;

	for (data=0;data<N/2;data++)
	{
		input[2*data].re=in_real[data];
		input[2*data].im=in_imag[data];
		input[2*data+1].re = 0;
		input[2*data+1].im = 0;
	}

	for (n=0;n<64;n+=2) //stage1~7, 짝수만 계산(홀수원소들 모두 0)
		{
			temp[n]=add_cal(input[n],input[n+64]);
			temp[n+64]=multiple(sub_cal(input[n],input[n+64]),W[n/2]);//128wiehgt의 짝수 weight -> 64weight로 변경하는 과정
		}

	for (n=0;n<32;n+=2) //stage2
		{
			for (k=0;k<2;k++)
			{
				input[n+(64*k)]=add_cal(temp[n+(64*k)],temp[n+((64*k)+32)]);
				input[n+((64*k)+32)]=multiple(sub_cal(temp[n+(64*k)],temp[n+((64*k)+32)]),W[n]);
			}
		}

	for(n=0;n<16;n+=2) //stage-3
		{
			for (k=0;k<4;k++)
			{
				temp[n+(32*k)] = add_cal(input[n+(32*k)],input[n+((32*k)+16)]);
				temp[n+((32*k)+16)] = multiple(sub_cal(input[n+(32*k)],input[n+((32*k)+16)]),W[2*n]);
			}
		}

	for (n=0;n<8;n+=2) //stage4
		{
			for (k=0;k<8;k++)
			{
				input[n+(16*k)] = add_cal(temp[n+(16*k)],temp[n+((16*k)+8)]);
				input[n+((16*k)+8)] =multiple(sub_cal(temp[n+(16*k)],temp[n+((16*k)+8)]),W[4*n]);
			}
		}

	for (n=0;n<4;n+=2) //stage5
		{
			for (k=0;k<16;k++)
			{
				temp[n+(8*k)]=add_cal(input[n+(8*k)],input[n+((8*k)+4)]);
				temp[n+((8*k)+4)]=multiple(sub_cal(input[n+(8*k)],input[n+((8*k)+4)]),W[8*n]);
			}
		}

	for (n=0;n<2;n+=2) // Stage 6
		{
			for (k=0;k<32;k++)
			{
				input[n+(4*k)]=add_cal(temp[n+(4*k)],temp[n+((4*k)+2)]);
				input[n+((4*k)+2)]=multiple(sub_cal(temp[n+(4*k)],temp[n+((4*k)+2)]),W[16*n]);
			}
		}

	Stage7(temp, input);


	for(n=0;n<N;n++)
	{
		X_FFT[n]=temp[Re_ordering(n)];
	}

	for (n=0;n<N;n++)
	{
		out_im[n]=(X_FFT[n].im)>>10;
		out_re[n]=(X_FFT[n].re)>>10;
	}

}

void FFT_Assembly()
{
	complex input[N],temp[N];

	int out_re[N];
	int out_im[N];

	int data;
	int n,k;

	for (data=0;data<N/2;data++)
	{
		input[2*data].re=in_real[data];
		input[2*data].im=in_imag[data];
		input[2*data+1].re = 0;
		input[2*data+1].im = 0;
	}

	for (n=0;n<64;n+=2) //stage1~7, 짝수만 계산(홀수원소들 모두 0)
		{
			temp[n]=add_cal(input[n],input[n+64]);
			temp[n+64]=multiple(sub_cal(input[n],input[n+64]),W[n/2]);//128wiehgt의 짝수 weight -> 64weight로 변경하는 과정
		}

	for (n=0;n<32;n+=2) //stage2
		{
			for (k=0;k<2;k++)
			{
				input[n+(64*k)]=add_cal(temp[n+(64*k)],temp[n+((64*k)+32)]);
				input[n+((64*k)+32)]=multiple(sub_cal(temp[n+(64*k)],temp[n+((64*k)+32)]),W[n]);
			}
		}

	for(n=0;n<16;n+=2) //stage-3
		{
			for (k=0;k<4;k++)
			{
				temp[n+(32*k)] = add_cal(input[n+(32*k)],input[n+((32*k)+16)]);
				temp[n+((32*k)+16)] = multiple(sub_cal(input[n+(32*k)],input[n+((32*k)+16)]),W[2*n]);
			}
		}

	for (n=0;n<8;n+=2) //stage4
		{
			for (k=0;k<8;k++)
			{
				input[n+(16*k)] = add_cal(temp[n+(16*k)],temp[n+((16*k)+8)]);
				input[n+((16*k)+8)] =multiple(sub_cal(temp[n+(16*k)],temp[n+((16*k)+8)]),W[4*n]);
			}
		}

	for (n=0;n<4;n+=2) //stage5
		{
			for (k=0;k<16;k++)
			{
				temp[n+(8*k)]=add_cal(input[n+(8*k)],input[n+((8*k)+4)]);
				temp[n+((8*k)+4)]=multiple(sub_cal(input[n+(8*k)],input[n+((8*k)+4)]),W[8*n]);
			}
		}

	for (n=0;n<2;n+=2) // Stage 6
		{
			for (k=0;k<32;k++)
			{
				input[n+(4*k)]=add_cal(temp[n+(4*k)],temp[n+((4*k)+2)]);
				input[n+((4*k)+2)]=multiple(sub_cal(temp[n+(4*k)],temp[n+((4*k)+2)]),W[16*n]);
			}
		}


	Stage7_Assembly(temp, input);

	for(n=0;n<N;n++)
	{
		X_FFT_Assembly[n]=temp[Re_ordering(n)];
	}

	for (n=0;n<N;n++)
	{
		out_im[n]=(X_FFT_Assembly[n].im)>>10;
		out_re[n]=(X_FFT_Assembly[n].re)>>10;
	}

}

int main() {
	XTime start,stop;
	int i = 0;

	float error_total, error_real, error_imag;
	float sig_total;
	float SNR;

	XTime_GetTime((XTime*)&start);
	DFT();
	XTime_GetTime((XTime*)&stop);
	printf("DFT          %8.3f us\r\n",((float)stop - (float)start)/COUNTS_PER_SECOND*1000000);

	XTime_GetTime((XTime*)&start);
	FFT();
	XTime_GetTime((XTime*)&stop);
	printf("FFT          %8.3f us\r\n",((float)stop - (float)start)/COUNTS_PER_SECOND*1000000);

	XTime_GetTime((XTime*)&start);
	FFT_Assembly();
	XTime_GetTime((XTime*)&stop);
	printf("FFT Assembly %8.3f us\r\n",((float)stop - (float)start)/COUNTS_PER_SECOND*1000000);


	error_total = 0;
	sig_total = 0;
	for(i = 0; i<N; i++){
		error_real = (X_DFT[i].re)-(X_FFT[i].re);
		error_imag = (X_DFT[i].im) -(X_FFT[i].im);

		error_total += error_real*error_real + error_imag*error_imag;

		sig_total += (X_DFT[i].re)*(X_DFT[i].re) + (X_DFT[i].im)*(X_DFT[i].im);
	}
	SNR = 10*log10(sig_total/error_total);
	xil_printf("FFT model SNR : %d dB\r\n",(int)SNR);


	error_total = 0;
	sig_total = 0;
	for(i = 0; i<N; i++){
		error_real = (X_DFT[i].re)-(X_FFT_Assembly[i].re);
		error_imag = (X_DFT[i].im) -(X_FFT_Assembly[i].im);

		error_total += error_real*error_real + error_imag*error_imag;

		sig_total += (X_DFT[i].re)*(X_DFT[i].re) + (X_DFT[i].im)*(X_DFT[i].im);
	}
	SNR = 10*log10(sig_total/error_total);
	xil_printf("FFT Assembly model SNR : %d dB\r\n",(int)SNR);

	return 0;
}
