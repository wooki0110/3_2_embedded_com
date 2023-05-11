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

`timescale 1ns/1ps
`define p 40
module tb_Top_FFT;

reg nrst,clk;


reg [15:0] input_re[383:0];
reg [15:0] input_im[383:0];

reg [15:0] output_re[(1+384+128+140):0];
reg [15:0] output_im[(1+384+128+140):0];
 
wire [15:0] inReal,inImag;
wire [15:0] outReal,outImag;

integer clkcnt;

reg start;


Top_FFT top0(.nrst(nrst),.clk(clk),.start(start),.valid(1'b1),.inReal(inReal),.inImag(inImag),.outReal(outReal),.outImag(outImag));

always
  #(`p/2)  clk = !clk;
 
always@(negedge clk)
  clkcnt = clkcnt +1;

initial begin
  clk  = 0;
  nrst = 0;
  clkcnt=-4;
  start = 0;
  $readmemb("binary_in_real.txt", input_re);
  $readmemb("binary_in_imag.txt", input_im);

  #(`p) start = 1'b1; 
  #(`p/2+1) nrst = 1;
end

assign inReal = clkcnt <= -2? 0: clkcnt>382? 0: input_re[clkcnt+1];
assign inImag = clkcnt <= -2? 0: clkcnt>382? 0: input_im[clkcnt+1];

always @ (posedge clk) begin
output_re[clkcnt+1] <= outReal;
output_im[clkcnt+1] <= outImag;
end


integer dumpfile, i;
initial begin


  #((1+384+128+140)*`p +1) dumpfile = $fopen("binary_out_real.txt","w");
  for(i = 0; i<1+384+128+140;i=i+1)begin
  $fwrite(dumpfile,"%b\n",output_re[i]);
  end
  $fclose(dumpfile);
  
    dumpfile = $fopen("binary_out_imag.txt","w");
    for(i = 0; i<1+384+128+140;i=i+1)begin
    $fwrite(dumpfile,"%b\n",output_im[i]);
    end
    $fclose(dumpfile);

  $stop;
end


endmodule
