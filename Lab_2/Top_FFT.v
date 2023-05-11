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

module Top_FFT #(	
	parameter in_BW = 16,
	parameter out_BW= 23,
	parameter cut_BW= 7
) (
	input                      nrst,clk,start,
	input                      valid,
	input [in_BW-1:0]          inReal,inImag,
	output[out_BW-cut_BW-1:0]  outReal,outImag	//reviced
);

wire [6:0] cnt;

wire [in_BW	 :0] sig1[1:0];
wire [in_BW+1:0] sig2[1:0];
wire [in_BW+2:0] sig3[1:0];
wire [in_BW+3:0] sig4[1:0];
wire [in_BW+4:0] sig5[1:0];
wire [in_BW+5:0] sig6[1:0];
wire [in_BW+6:0] sig7[1:0];

wire en_s1, en_s5, en_s7;
reg	 en_s2, en_s6;
reg [2:0] en_s4;
reg	[1:0] en_s3;

Counter cnt0(nrst,clk,start, valid,cnt);
Stage #(in_BW+1,64) stage1(nrst,clk,en_s1,cnt,inReal,inImag, valid, sig1[0],sig1[1]);
Stage #(in_BW+2,32) stage2(nrst,clk,en_s2,cnt,sig1[0],sig1[1], valid, sig2[0],sig2[1]);
Stage #(in_BW+3,16) stage3(nrst,clk,en_s3[1],cnt,sig2[0],sig2[1], valid, sig3[0],sig3[1]);
Stage #(in_BW+4,8 ) stage4(nrst,clk,en_s4[2],cnt,sig3[0],sig3[1], valid, sig4[0],sig4[1]);
Stage #(in_BW+5,4 ) stage5(nrst,clk,en_s5,cnt,sig4[0],sig4[1], valid, sig5[0],sig5[1]);
Stage #(in_BW+6,2 ) stage6(nrst,clk,en_s6,cnt,sig5[0],sig5[1], valid, sig6[0],sig6[1]);
Stage7 #(in_BW+7,1 ) stage7(nrst,clk,en_s7   ,sig6[0],sig6[1], valid, sig7[0],sig7[1]);


assign outReal = sig7[0][in_BW+6 : cut_BW];
assign outImag = sig7[1][in_BW+6 : cut_BW];

assign en_s1 = cnt[6];
always@(posedge clk)
  if(!nrst)
    en_s2 <= 0;
  else if(valid)
    en_s2 <= cnt[5];

always@(posedge clk)
  if(!nrst)
    en_s3 <= 0;
  else if(valid) begin
    en_s3[0]   <= cnt[4];
    en_s3[1] <= en_s3[0];
  end
always@(posedge clk)
  if(!nrst)
    en_s4 <= 0;
  else if(valid) begin
    en_s4[0] <= cnt[3];
		en_s4[2:1]<=en_s4[1:0];
	end

assign en_s5 = ~cnt[2];

always@(posedge clk)
  if(!nrst)
    en_s6 <= 0;
  else if(valid)
    en_s6 <= cnt[1];
    
assign en_s7 = cnt[0];

endmodule