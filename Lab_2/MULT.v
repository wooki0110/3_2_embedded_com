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

module MULT(data_in_re,data_in_im,cnt,data_out_re,data_out_im);
parameter BW=16;
parameter N =64;

wire signed [11:0] W_re[63:0];
wire signed [11:0] W_im[63:0];
                                           
input signed [BW-1:0] data_in_re;//(9:4)
input signed [BW-1:0] data_in_im;
input [5:0] cnt;
output signed[BW-1:0] data_out_re;//(9:4)
output signed[BW-1:0] data_out_im;
    
reg signed [11:0] temp_re; //[10:0]
reg signed [11:0] temp_im; //[10:0]
    
wire signed [BW+12:0] buf_re; //[23:0]
wire signed [BW+12:0] buf_im; //[23:0]

    parameter signed W_re0 = 12'b010000000000;
    parameter signed W_re1 = 12'b001111111110;
    parameter signed W_re2 = 12'b001111111011;
    parameter signed W_re3 = 12'b001111110100;
    parameter signed W_re4 = 12'b001111101100;
    parameter signed W_re5 = 12'b001111100001;
    parameter signed W_re6 = 12'b001111010011;
    parameter signed W_re7 = 12'b001111000100;
    parameter signed W_re8 = 12'b001110110010;
    parameter signed W_re9 = 12'b001110011101;
    parameter signed W_re10 = 12'b001110000111;
    parameter signed W_re11 = 12'b001101101110;
    parameter signed W_re12 = 12'b001101010011;
    parameter signed W_re13 = 12'b001100110110;
    parameter signed W_re14 = 12'b001100010111;
    parameter signed W_re15 = 12'b001011110110;
    parameter signed W_re16 = 12'b001011010100;
    parameter signed W_re17 = 12'b001010101111;
    parameter signed W_re18 = 12'b001010001001;
    parameter signed W_re19 = 12'b001001100001;
    parameter signed W_re20 = 12'b001000111000;
    parameter signed W_re21 = 12'b001000001110;
    parameter signed W_re22 = 12'b000111100010;
    parameter signed W_re23 = 12'b000110110101;
    parameter signed W_re24 = 12'b000110000111;
    parameter signed W_re25 = 12'b000101011000;
    parameter signed W_re26 = 12'b000100101001;
    parameter signed W_re27 = 12'b000011111000;
    parameter signed W_re28 = 12'b000011000111;
    parameter signed W_re29 = 12'b000010010110;
    parameter signed W_re30 = 12'b000001100100;
    parameter signed W_re31 = 12'b000000110010;
    parameter signed W_re32 = 12'b000000000000;
    parameter signed W_re33 = 12'b111111001101;
    parameter signed W_re34 = 12'b111110011011;
    parameter signed W_re35 = 12'b111101101001;
    parameter signed W_re36 = 12'b111100111000;
    parameter signed W_re37 = 12'b111100000111;
    parameter signed W_re38 = 12'b111011010110;
    parameter signed W_re39 = 12'b111010100111;
    parameter signed W_re40 = 12'b111001111000;
    parameter signed W_re41 = 12'b111001001010;
    parameter signed W_re42 = 12'b111000011101;
    parameter signed W_re43 = 12'b110111110001;
    parameter signed W_re44 = 12'b110111000111;
    parameter signed W_re45 = 12'b110110011110;
    parameter signed W_re46 = 12'b110101110110;
    parameter signed W_re47 = 12'b110101010000;
    parameter signed W_re48 = 12'b110100101011;
    parameter signed W_re49 = 12'b110100001001;
    parameter signed W_re50 = 12'b110011101000;
    parameter signed W_re51 = 12'b110011001001;
    parameter signed W_re52 = 12'b110010101100;
    parameter signed W_re53 = 12'b110010010001;
    parameter signed W_re54 = 12'b110001111000;
    parameter signed W_re55 = 12'b110001100010;
    parameter signed W_re56 = 12'b110001001101;
    parameter signed W_re57 = 12'b110000111011;
    parameter signed W_re58 = 12'b110000101100;
    parameter signed W_re59 = 12'b110000011110;
    parameter signed W_re60 = 12'b110000010011;
    parameter signed W_re61 = 12'b110000001011;
    parameter signed W_re62 = 12'b110000000100;
    parameter signed W_re63 = 12'b110000000001;


    parameter signed W_im0 = 12'b000000000000;
    parameter signed W_im1 = 12'b111111001101;
    parameter signed W_im2 = 12'b111110011011;
    parameter signed W_im3 = 12'b111101101001;
    parameter signed W_im4 = 12'b111100111000;
    parameter signed W_im5 = 12'b111100000111;
    parameter signed W_im6 = 12'b111011010110;
    parameter signed W_im7 = 12'b111010100111;
    parameter signed W_im8 = 12'b111001111000;
    parameter signed W_im9 = 12'b111001001010;
    parameter signed W_im10 = 12'b111000011101;
    parameter signed W_im11 = 12'b110111110001;
    parameter signed W_im12 = 12'b110111000111;
    parameter signed W_im13 = 12'b110110011110;
    parameter signed W_im14 = 12'b110101110110;
    parameter signed W_im15 = 12'b110101010000;
    parameter signed W_im16 = 12'b110100101011;
    parameter signed W_im17 = 12'b110100001001;
    parameter signed W_im18 = 12'b110011101000;
    parameter signed W_im19 = 12'b110011001001;
    parameter signed W_im20 = 12'b110010101100;
    parameter signed W_im21 = 12'b110010010001;
    parameter signed W_im22 = 12'b110001111000;
    parameter signed W_im23 = 12'b110001100010;
    parameter signed W_im24 = 12'b110001001101;
    parameter signed W_im25 = 12'b110000111011;
    parameter signed W_im26 = 12'b110000101100;
    parameter signed W_im27 = 12'b110000011110;
    parameter signed W_im28 = 12'b110000010011;
    parameter signed W_im29 = 12'b110000001011;
    parameter signed W_im30 = 12'b110000000100;
    parameter signed W_im31 = 12'b110000000001;
    parameter signed W_im32 = 12'b110000000000;
    parameter signed W_im33 = 12'b110000000001;
    parameter signed W_im34 = 12'b110000000100;
    parameter signed W_im35 = 12'b110000001011;
    parameter signed W_im36 = 12'b110000010011;
    parameter signed W_im37 = 12'b110000011110;
    parameter signed W_im38 = 12'b110000101100;
    parameter signed W_im39 = 12'b110000111011;
    parameter signed W_im40 = 12'b110001001101;
    parameter signed W_im41 = 12'b110001100010;
    parameter signed W_im42 = 12'b110001111000;
    parameter signed W_im43 = 12'b110010010001;
    parameter signed W_im44 = 12'b110010101100;
    parameter signed W_im45 = 12'b110011001001;
    parameter signed W_im46 = 12'b110011101000;
    parameter signed W_im47 = 12'b110100001001;
    parameter signed W_im48 = 12'b110100101011;
    parameter signed W_im49 = 12'b110101010000;
    parameter signed W_im50 = 12'b110101110110;
    parameter signed W_im51 = 12'b110110011110;
    parameter signed W_im52 = 12'b110111000111;
    parameter signed W_im53 = 12'b110111110001;
    parameter signed W_im54 = 12'b111000011101;
    parameter signed W_im55 = 12'b111001001010;
    parameter signed W_im56 = 12'b111001111000;
    parameter signed W_im57 = 12'b111010100111;
    parameter signed W_im58 = 12'b111011010110;
    parameter signed W_im59 = 12'b111100000111;
    parameter signed W_im60 = 12'b111100111000;
    parameter signed W_im61 = 12'b111101101001;
    parameter signed W_im62 = 12'b111110011011;
    parameter signed W_im63 = 12'b111111001101;

always@(*) begin
if (N==64) begin
    case(cnt)
        6'd0 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        6'd1 : begin
               temp_re <= W_re1;
               temp_im <= W_im1;
               end
        6'd2 : begin
               temp_re <= W_re2;
               temp_im <= W_im2;
               end
        6'd3 : begin
               temp_re <= W_re3;
               temp_im <= W_im3;
               end
        6'd4 : begin
               temp_re <= W_re4;
               temp_im <= W_im4;
               end
        6'd5 : begin
               temp_re <= W_re5;
               temp_im <= W_im5;
               end
        6'd6 : begin
               temp_re <= W_re6;
               temp_im <= W_im6;
               end
        6'd7 : begin
               temp_re <= W_re7;
               temp_im <= W_im7;
               end
        6'd8 : begin
               temp_re <= W_re8;
               temp_im <= W_im8;
               end
        6'd9 : begin
               temp_re <= W_re9;
               temp_im <= W_im9;
               end
        6'd10 : begin
               temp_re <= W_re10;
               temp_im <= W_im10;
               end
        6'd11 : begin
               temp_re <= W_re11;
               temp_im <= W_im11;
               end
        6'd12 : begin
               temp_re <= W_re12;
               temp_im <= W_im12;
               end
        6'd13 : begin
               temp_re <= W_re13;
               temp_im <= W_im13;
               end
        6'd14 : begin
               temp_re <= W_re14;
               temp_im <= W_im14;
               end
        6'd15 : begin
               temp_re <= W_re15;
               temp_im <= W_im15;
               end
        6'd16 : begin
               temp_re <= W_re16;
               temp_im <= W_im16;
               end
        6'd17 : begin
               temp_re <= W_re17;
               temp_im <= W_im17;
               end
        6'd18 : begin
               temp_re <= W_re18;
               temp_im <= W_im18;
               end
        6'd19 : begin
               temp_re <= W_re19;
               temp_im <= W_im19;
               end
        6'd20 : begin
               temp_re <= W_re20;
               temp_im <= W_im20;
               end
        6'd21 : begin
               temp_re <= W_re21;
               temp_im <= W_im21;
               end
        6'd22 : begin
               temp_re <= W_re22;
               temp_im <= W_im22;
               end
        6'd23 : begin
               temp_re <= W_re23;
               temp_im <= W_im23;
               end
        6'd24 : begin
               temp_re <= W_re24;
               temp_im <= W_im24;
               end
        6'd25 : begin
               temp_re <= W_re25;
               temp_im <= W_im25;
               end
        6'd26 : begin
               temp_re <= W_re26;
               temp_im <= W_im26;
               end
        6'd27 : begin
               temp_re <= W_re27;
               temp_im <= W_im27;
               end
        6'd28 : begin
               temp_re <= W_re28;
               temp_im <= W_im28;
               end
        6'd29 : begin
               temp_re <= W_re29;
               temp_im <= W_im29;
               end
        6'd30 : begin
               temp_re <= W_re30;
               temp_im <= W_im30;
               end
        6'd31 : begin
               temp_re <= W_re31;
               temp_im <= W_im31;
               end
        6'd32 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end
        6'd33 : begin
               temp_re <= W_re33;
               temp_im <= W_im33;
               end
        6'd34 : begin
               temp_re <= W_re34;
               temp_im <= W_im34;
               end
        6'd35 : begin
               temp_re <= W_re35;
               temp_im <= W_im35;
               end
        6'd36 : begin
               temp_re <= W_re36;
               temp_im <= W_im36;
               end
        6'd37 : begin
               temp_re <= W_re37;
               temp_im <= W_im37;
               end
        6'd38 : begin
               temp_re <= W_re38;
               temp_im <= W_im38;
               end
        6'd39 : begin
               temp_re <= W_re39;
               temp_im <= W_im39;
               end
        6'd40 : begin
               temp_re <= W_re40;
               temp_im <= W_im40;
               end
        6'd41 : begin
               temp_re <= W_re41;
               temp_im <= W_im41;
               end
        6'd42 : begin
               temp_re <= W_re42;
               temp_im <= W_im42;
               end
        6'd43 : begin
               temp_re <= W_re43;
               temp_im <= W_im43;
               end
        6'd44 : begin
               temp_re <= W_re44;
               temp_im <= W_im44;
               end
        6'd45 : begin
               temp_re <= W_re45;
               temp_im <= W_im45;
               end
        6'd46 : begin
               temp_re <= W_re46;
               temp_im <= W_im46;
               end
        6'd47 : begin
               temp_re <= W_re47;
               temp_im <= W_im47;
               end
        6'd48 : begin
               temp_re <= W_re48;
               temp_im <= W_im48;
               end
        6'd49 : begin
               temp_re <= W_re49;
               temp_im <= W_im49;
               end
        6'd50 : begin
               temp_re <= W_re50;
               temp_im <= W_im50;
               end
        6'd51 : begin
               temp_re <= W_re51;
               temp_im <= W_im51;
               end
        6'd52 : begin
               temp_re <= W_re52;
               temp_im <= W_im52;
               end
        6'd53 : begin
               temp_re <= W_re53;
               temp_im <= W_im53;
               end
        6'd54 : begin
               temp_re <= W_re54;
               temp_im <= W_im54;
               end
        6'd55 : begin
               temp_re <= W_re55;
               temp_im <= W_im55;
               end
        6'd56 : begin
               temp_re <= W_re56;
               temp_im <= W_im56;
               end
        6'd57 : begin
               temp_re <= W_re57;
               temp_im <= W_im57;
               end
        6'd58 : begin
               temp_re <= W_re58;
               temp_im <= W_im58;
               end
        6'd59 : begin
               temp_re <= W_re59;
               temp_im <= W_im59;
               end
        6'd60 : begin
               temp_re <= W_re60;
               temp_im <= W_im60;
               end
        6'd61 : begin
               temp_re <= W_re61;
               temp_im <= W_im61;
               end
        6'd62 : begin
               temp_re <= W_re62;
               temp_im <= W_im62;
               end
        6'd63 : begin
               temp_re <= W_re63;
               temp_im <= W_im63;
               end
    endcase
end
else if (N==32) begin
    case(cnt[4:0])
        5'd1 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        5'd2 : begin
               temp_re <= W_re2;
               temp_im <= W_im2;
               end
        5'd3 : begin
               temp_re <= W_re4;
               temp_im <= W_im4;
               end            
        5'd4 : begin
               temp_re <= W_re6;
               temp_im <= W_im6;
               end                        
        5'd5 : begin
               temp_re <= W_re8;
               temp_im <= W_im8;
               end
        5'd6 : begin
               temp_re <= W_re10;
               temp_im <= W_im10;
               end
        5'd7 : begin
               temp_re <= W_re12;
               temp_im <= W_im12;
               end       
        5'd8 : begin
               temp_re <= W_re14;
               temp_im <= W_im14;
               end
        5'd9 : begin
               temp_re <= W_re16;
               temp_im <= W_im16;
               end
        5'd10 : begin
               temp_re <= W_re18;
               temp_im <= W_im18;
               end
        5'd11 : begin
               temp_re <= W_re20;
               temp_im <= W_im20;
               end
        5'd12 : begin
               temp_re <= W_re22;
               temp_im <= W_im22;
               end
        5'd13 : begin
               temp_re <= W_re24;
               temp_im <= W_im24;
               end
        5'd14 : begin
               temp_re <= W_re26;
               temp_im <= W_im26;
               end
        5'd15 : begin
               temp_re <= W_re28;
               temp_im <= W_im28;
               end       
        5'd16 : begin
               temp_re <= W_re30;
               temp_im <= W_im30;
               end
        5'd17 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end
        5'd18 : begin
               temp_re <= W_re34;
               temp_im <= W_im34;
               end
        5'd19 : begin
               temp_re <= W_re36;
               temp_im <= W_im36;
               end
        5'd20 : begin
               temp_re <= W_re38;
               temp_im <= W_im38;
               end
        5'd21 : begin
               temp_re <= W_re40;
               temp_im <= W_im40;
               end
        5'd22 : begin
               temp_re <= W_re42;
               temp_im <= W_im42;
               end
        5'd23 : begin
               temp_re <= W_re44;
               temp_im <= W_im44;
               end
        5'd24 : begin
               temp_re <= W_re46;
               temp_im <= W_im46;
               end
        5'd25 : begin
               temp_re <= W_re48;
               temp_im <= W_im48;
               end
        5'd26 : begin
               temp_re <= W_re50;
               temp_im <= W_im50;
               end
        5'd27 : begin
               temp_re <= W_re52;
               temp_im <= W_im52;
               end
        5'd28 : begin
               temp_re <= W_re54;
               temp_im <= W_im54;
               end
        5'd29 : begin
               temp_re <= W_re56;
               temp_im <= W_im56;
               end
        5'd30 : begin
               temp_re <= W_re58;
               temp_im <= W_im58;
               end
        5'd31 : begin
               temp_re <= W_re60;
               temp_im <= W_im60;
               end
        5'd0 : begin
               temp_re <= W_re62;
               temp_im <= W_im62;
               end       
      endcase
end
else if (N==16) begin
    case(cnt[3:0])//-1
        4'd2 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        4'd3 : begin
               temp_re <= W_re4;
               temp_im <= W_im4;
               end
        4'd4 : begin
               temp_re <= W_re8;
               temp_im <= W_im8;
               end            
        4'd5 : begin
               temp_re <= W_re12;
               temp_im <= W_im12;
               end                        
        4'd6 : begin
               temp_re <= W_re16;
               temp_im <= W_im16;
               end
        4'd7 : begin
               temp_re <= W_re20;
               temp_im <= W_im20;
               end
        4'd8 : begin
               temp_re <= W_re24;
               temp_im <= W_im24;
               end       
        4'd9 : begin
               temp_re <= W_re28;
               temp_im <= W_im28;
               end
        4'd10 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end
        4'd11: begin
               temp_re <= W_re36;
               temp_im <= W_im36;
               end
        4'd12: begin
               temp_re <= W_re40;
               temp_im <= W_im40;
               end
        4'd13: begin
               temp_re <= W_re44;
               temp_im <= W_im44;
               end
        4'd14: begin
               temp_re <= W_re48;
               temp_im <= W_im48;
               end
        4'd15: begin
               temp_re <= W_re52;
               temp_im <= W_im52;
               end
        4'd0: begin
               temp_re <= W_re56;
               temp_im <= W_im56;
               end       
        4'd1 : begin
               temp_re <= W_re60;
               temp_im <= W_im60;
               end
      endcase
end
else if (N==8)begin
    case(cnt[2:0])
        3'd3 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        3'd4 : begin
               temp_re <= W_re8;
               temp_im <= W_im8;
               end
        3'd5 : begin
               temp_re <= W_re16;
               temp_im <= W_im16;
               end            
        3'd6 : begin
               temp_re <= W_re24;
               temp_im <= W_im24;
               end                        
        3'd7 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end
        3'd0 : begin
               temp_re <= W_re40;
               temp_im <= W_im40;
               end
        3'd1 : begin
               temp_re <= W_re48;
               temp_im <= W_im48;
               end       
        3'd2 : begin
               temp_re <= W_re56;
               temp_im <= W_im56;
               end
      endcase
end
else if (N==4) begin
    case(cnt[1:0])
        2'd0 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        2'd1 : begin
               temp_re <= W_re16;
               temp_im <= W_im16;
               end
        2'd2 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end            
        2'd3 : begin
               temp_re <= W_re48;
               temp_im <= W_im48;
               end            
      endcase
end
else begin//if (N==2) begin
    case(cnt[0])
        2'd1 : begin
               temp_re <= W_re0;
               temp_im <= W_im0;
               end
        2'd0 : begin
               temp_re <= W_re32;
               temp_im <= W_im32;
               end
      endcase
end
end


assign buf_re = (temp_re*data_in_re)-(temp_im*data_in_im); // [24:0]
assign buf_im = (temp_im*data_in_re)+(temp_re*data_in_im); // [24:0]

assign data_out_re = {buf_re[BW+12],buf_re[BW+8:10]};
assign data_out_im = {buf_im[BW+12],buf_im[BW+8:10]};

endmodule                                                                                        

