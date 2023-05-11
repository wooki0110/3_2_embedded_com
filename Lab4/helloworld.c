/******************************************************************************
Copyright (c) 2017 SoC Design Laboratory, Konkuk University, South Korea
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met: redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer;
redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution;
neither the name of the copyright holders nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Authors: Jooho Wang (joohowang@konkuk.ac.kr)

Revision History
2018.11.13: Started by Jooho Wang
*******************************************************************************/

#include <stdio.h>
#include "xparameters.h"
#include "xparameters_ps.h"
#include "platform.h"
#include "xaxidma.h"
#include "xscugic.h"
#include "xtime_l.h"
#include "input.h"


#define LENGTH		135+128+1

XAxiDma DMA0, DMA1;
//
//
#include "PL_DMA.h"

void DMA_transfer(int input_addr, int output_addr, int len);

void Output_Console();

void Example_DMA();

void Example_PS();

int i, j, tmp, tmp1, k;
int input_array[LENGTH] = {0,};
int output_array[LENGTH] = {0,};
char o[LENGTH][32];

XTime start, stop;
XTime start1, stop1;
XTime start2, stop2;
XTime start3, stop3;
XTime start4, stop4;
XTime start5, stop5;

#define INPUT_BASE 			0x11000000
#define OUTPUT_BASE 		0x12000000
#define IP_FOR_DMA_BASE		0x44A00000

int reordering(int x)
{
	return 64 * (x % 2) + 32 * ((x % 4) / 2) + 16 * ((x % 8) / 4)
		+ 8 * ((x % 16) / 8) + 4 * ((x % 32) / 16) + 2 * ((x % 64) / 32)
		+ x / 64;
}

int main()
{
	xil_printf("main start.\r\n");

	init_platform();

	// Initialize
	for (i = 0; i < LENGTH; i++){
		Xil_Out32(OUTPUT_BASE+i*4, 0);
		Xil_Out32(INPUT_BASE+i*4, 0);
	}

	// Set input data to array
	for(i = 0; i < LENGTH; i++){
		tmp  = inReal[i]<<16;
		tmp1 = (0x0000FFFF & inImag[i]);
		input_array[i] = tmp + tmp1;
	}

	// Put input data to DMA source region
	Xil_Out32(INPUT_BASE,0x7FFFFFFF);
	for(i = 0; i < LENGTH; i++)
		Xil_Out32(INPUT_BASE + 4*(i+1),input_array[i]);

	// DMA basic setting
	DMA_preset();

	// DMA transfer control
	XTime_GetTime((XTime*)&start);
	DMA_transfer(INPUT_BASE, OUTPUT_BASE, LENGTH);
	xil_printf("DMA out\r\n");
	XTime_GetTime((XTime*)&stop);
	printf("DMA transfer  %0.3f us \n\n", ((float)stop - (float)start)/COUNTS_PER_SECOND*1000000);
	printf("Cache flush  %0.3f us \n", ((float)stop1 - (float)start1)/COUNTS_PER_SECOND*1000000);
	printf("DMA addr setup  %0.3f us \n", ((float)stop2 - (float)start2)/COUNTS_PER_SECOND*1000000);
	printf("DMA start  %0.3f us \n", ((float)stop3 - (float)start3)/COUNTS_PER_SECOND*1000000);
	printf("Accelerator in & out  %0.3f us \n", ((float)stop4 - (float)start4)/COUNTS_PER_SECOND*1000000);
	printf("Cache invalidate  %0.3f us \n\n", ((float)stop5 - (float)start5)/COUNTS_PER_SECOND*1000000);

	// Get output data from DMA destination region
	for(i = 0; i < LENGTH; i++)
		output_array[i] = Xil_In32(OUTPUT_BASE + 4*i);


	Output_Console();

	xil_printf("\n\nmain end.\n");

	return 0;
}

void DMA_transfer(int input_addr, int output_addr, int len)
{
	XTime_GetTime((XTime*)&start1);
	Xil_DCacheFlushRange(input_addr, 4 * len);
	XTime_GetTime((XTime*)&stop1);

	XTime_GetTime((XTime*)&start2);
	DMA_ADDR_setup(&DMA0, input_addr, output_addr);
	XTime_GetTime((XTime*)&stop2);

	XTime_GetTime((XTime*)&start3);
	DMA_Go(&DMA0, len * 4);
	XTime_GetTime((XTime*)&stop3);

	XTime_GetTime((XTime*)&start4);
	while ((XAxiDma_Busy(&DMA0, XAXIDMA_DEVICE_TO_DMA)));
	while ((XAxiDma_Busy(&DMA0, XAXIDMA_DMA_TO_DEVICE)));
	XTime_GetTime((XTime*)&stop4);

	XTime_GetTime((XTime*)&start5);
	Xil_DCacheInvalidateRange(output_addr, 4 * len + 32);
	XTime_GetTime((XTime*)&stop5);
}

void Output_Console(){

	for(i = 0; i < LENGTH; i++)
	{
		for(j=0;j<32;j++)
			if ((output_array[i]>>(31-j))&0x00000001)
				o[i][j] = '1';
			else
				o[i][j] = '0';
	}

	for(i = 0; i < LENGTH; i++)
	{
		if(i<135)
		{
			xil_printf("%3d: ",i);
			for(j=0;j<16;j++)
				xil_printf("%c",o[i][j]);
			xil_printf(" ");
			for(j=16;j<32;j++)
				xil_printf("%c",o[i][j]);
			xil_printf("\r\n");
		}
		else {
			xil_printf("%3d: ",i);
			k = reordering(i-135);
			for(j=0;j<16;j++)
				xil_printf("%c",o[k+135][j]);
			xil_printf(" ");
			for(j=16;j<32;j++)
				xil_printf("%c",o[k+135][j]);
			xil_printf("\r\n");
		}
	}
}




