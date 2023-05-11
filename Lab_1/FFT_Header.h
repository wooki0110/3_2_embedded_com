/******************************************************************************
Copyright (c) 2018 SoC Design Laboratory, Konkuk University, South Korea
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

Authors: Sunwoo Kim (sunwkim@konkuk.ac.kr)

Revision History
2017.02.15: Started by Sunwoo Kim
*******************************************************************************/
#define N 64

typedef struct
{
	int re;
	int im;
} complex;

complex init1_int = {0,0};
complex init2_int = {0,0};


complex W[64]=                           //twiddle factor°ª
{
	{1024,0},
	{1019,-100}, 
	{1004,-200}, 
	{980,-297}, 
	{946,-392}, 
	{903,-483}, 
	{851,-569}, 
	{792,-650}, 
	{724,-724}, 
	{650,-792}, 
	{569,-851}, 
	{483,-903}, 
	{392,-946}, 
	{297,-980}, 
	{200,-1004}, 
	{100,-1019}, 
	{0,-1024}, 
	{-100,-1019}, 
	{-200,-1004}, 
	{-297,-980}, 
	{-392,-946}, 
	{-483,-903}, 
	{-569,-851}, 
	{-650,-792}, 
	{-724,-724}, 
	{-792,-650}, 
	{-851,-569}, 
	{-903,-483}, 
	{-946,-392}, 
	{-980,-297}, 
	{-1004,-200}, 
	{-1019,-100},
	{-1024,0},
	{-1019,100},
	{-1004,200},
	{-980,297},
	{-946,392},
	{-903,483},
	{-851,569},
	{-792,650},
	{-724,724},
	{-650,792},
	{-569,851},
	{-483,903},
	{-392,946},
	{-297,980},
	{-200,1004},
	{-100,1019},
	{0,1024},
	{100,1019},
	{200,1004},
	{297,980},
	{392,946},
	{483,903},
	{569,851},
	{650,792},
	{724,724},
	{792,650},
	{851,569},
	{903,483},
	{946,392},
	{980,297},
	{1004,200},
	{1019,100}
};

complex multiple(complex x, complex y)
{
	complex result;

	result.re = (x.re*y.re - x.im*y.im)>>10;
	result.im = (x.re*y.im + x.im*y.re)>>10;

	return result;
}

complex add_cal(complex x, complex y)
{
	complex result;

	result.re = x.re + y.re;
	result.im = x.im + y.im;

	return result;
}

complex sub_cal(complex x, complex y)
{
	complex result;

	result.re = x.re - y.re;
	result.im = x.im - y.im;

	return result;
}


int in_imag[N]={
		8037,
		6989,
	   14023,
	   14566,
		3423,
		8971,
		8162,
	   11839,
	   12994,
	   13824,
		5056,
	   12451,
	   12000,
		2979,
		2180,
		9129,
	   17580,
		6235,
	   10721,
		4100,
	   13762,
		4673,
		9268,
	   12806,
	   16319,
	   17572,
	   10024,
		2539,
		2735,
		4717,
	   15400,
		4658,
	   14916,
		4461,
	   17022,
		6411,
		3601,
		4599,
	   11285,
		8670,
		6442,
	   15219,
	   10721,
	   10070,
	   16801,
		5236,
	   13870,
	   13807,
		6969,
	   10401,
		1390,
		 988,
		9723,
	   14273,
	   17109,
		2380,
	   10420,
		8598,
		 218,
		6175,
		2971,
	   14550,
		5701,
		9682
};
int in_real[N]={
 		3034,
       11027,
        4817,
       11981,
       12625,
       13705,
        8253,
        1535,
        4194,
       16730,
        2791,
       15127,
        9861,
       18247,
        1432,
        8109,
        1954,
       17620,
          85,
       14195,
       14971,
       15913,
        1547,
        7323,
        4760,
       14656,
        7903,
       16681,
        3331,
        4832,
        2666,
        2492,
       15924,
       10619,
       10072,
        2655,
       15626,
       11395,
        6429,
        9402,
        7360,
        1392,
        4395,
        2259,
        3369,
        4395,
        7643,
         910,
       16536,
       17307,
        8992,
        8962,
        6186,
       16487,
        6764,
        2037,
       14293,
        7139,
        4427,
        7399,
        1767,
        2417,
       17256,
       17514
};

