/******************************************************************************
Copyright (c) 2014-2017 SoC Design Laboratory, Konkuk University, South Korea
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


module axis_fft
(
   ///////////////////////////////////////////////////////////////////////////////
   // Port Declarations
   ///////////////////////////////////////////////////////////////////////////////
   // System Signals
   ///////////////////////////////////////////////////////////////////////////////
   input                           s_axis_aresetn,
   input                           m_axis_aresetn,

   // Slave side (FFT Input)
   input                           s_axis_aclk,
   input                           s_axis_tvalid,
   output                          s_axis_tready,
   input signed [32-1:0]   		  s_axis_tdata,
   input                           s_axis_tlast,
   input        [32/8-1:0] 		  s_axis_tkeep,

    // Master side (FFT Output)
   input                           m_axis_aclk,
   output                          m_axis_tvalid,
   input                           m_axis_tready,
   output signed [32-1:0]   		  m_axis_tdata,
   output                          m_axis_tlast,
   output        [32/8-1:0] 		  m_axis_tkeep
);

// Internal signals
wire valid     = s_axis_tvalid && s_axis_tready;
wire start_FFT = !(s_axis_tdata == 32'h7FFFFFFF);

///////////////////////////////////////////////////////
//FFT: start instantiation
///////////////////////////////////////////////////////

Top_FFT  #(.in_BW(16),.out_BW(22),.cut_BW(6)) inst_FFT(
   .nrst(s_axis_aresetn),
   .clk(s_axis_aclk),
   .start(start_FFT),
   .valid(valid),
   .inReal(s_axis_tdata[31:16]),
   .inImag(s_axis_tdata[15:0]),
   .outReal(m_axis_tdata[31:16]),
   .outImag(m_axis_tdata[15:0])
   );

///////////////////////////////////////////////////////
//FFT: end instantiation
///////////////////////////////////////////////////////

assign m_axis_tvalid = s_axis_tvalid;
assign s_axis_tready = m_axis_tready;
assign m_axis_tlast  = s_axis_tlast;
assign m_axis_tkeep  = s_axis_tkeep;

endmodule