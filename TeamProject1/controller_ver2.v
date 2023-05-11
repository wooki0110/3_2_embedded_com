/******************************************************************************
Copyright (c) 2022 SoC Design Laboratory, Konkuk University, South Korea
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

Authors: Uyong Lee (uyonglee@konkuk.ac.kr)

Revision History
2022.11.17: Started by Uyong Lee
*******************************************************************************/
module controller(
        input 		    clk, nrst, in_vld, out_rdy,
        output wire 	in_rdy, out_vld,
	    output wire	    sel_input,
	    output wire 	sel_res,
        output wire 	sel_mem,
        output wire 	we_AMEM, we_BMEM, we_OMEM,
        output wire 	[3:0] addr_AMEM,
        output wire 	[3:0] addr_BMEM,
        output wire 	[3:0] addr_OMEM,
        output wire 	[2:0] addr_CROM,
        output wire 	en_REG_A,
	    output reg	    en_REG_B, en_REG_C
);

/////////////////////////////////////
/////////// Edit code below!!////////

reg [4:0] cnt, cnt_out, cnt_in;
reg [3:0]  cnt_addr, cnt_cr, cnt_oaddr;		// cnt_cr : 1clock delay sig of cnt
//reg [2:0] cstate, nstate, cstate_in, nstate_in, cstate_out, nstate_out;
reg [2:0] cstate, nstate;
reg cstate_in, nstate_in, cstate_out, nstate_out;		// IDLE : 0, RUN : 1
reg [3:0] vld_flag, sel_flag;


localparam
	IDLE	= 3'b000,
	RUN		= 3'b001,
    Stage1  = 3'b100,
    Stage2  = 3'b101,
    Stage3  = 3'b110,
    Stage4  = 3'b111;	

always@(posedge clk) begin
	if(!nrst) begin
		cnt <= 0;
		cnt_cr <= 0;	// addr_CROM ?? ????? ???? counter
	end	
	else begin
		if(in_vld == 1'b0 && out_rdy == 1'b0) begin     // ?? ?? 0??? FFT ????
			cnt <= 0;
			cnt_cr <= 0;
		end
        else if(cnt == 5'd18) begin
            cnt <= 0;
			cnt_cr <= 0;
        end
		else if(cstate == IDLE) begin
			cnt <= 0;
			cnt_cr <= 0;
		end
		else begin
			if(in_rdy) begin
				if(in_vld) begin
					cnt <= cnt + 5'd1;
					cnt_cr <= cnt;
				end
				else begin
					cnt <= cnt;
					cnt_cr <= cnt_cr;
				end
			end
			else begin
				cnt <= cnt + 5'd1;
				cnt_cr <= cnt;
			end
		end
	end
end

always@(posedge clk) begin
	if(in_rdy == 0) begin
		vld_flag <= 0;
	end
	else begin
		if(in_vld == 0)
			vld_flag <= vld_flag + 5'd1;
		else
			vld_flag <= 0;
	end
	sel_flag <= vld_flag;
end

/* addr_AMEM?? stage2,4 ?? addr_BMEM?? stage1,3?? ???? cnt?? 2 clock delay?? ????? */
always@(posedge clk) begin
	if(!nrst) begin
		cnt_addr <= -1;	
	end	
	else begin
		if(in_vld == 1'b0 && out_rdy == 1'b0) begin     // ?? ?? 0??? FFT ????
			cnt_addr <= -1;
		end
        else if(cnt_addr == 4'd15) begin
			cnt_addr <= 0; 
        end
		else if(cstate == IDLE && in_rdy == 1) begin
			if(in_vld == 1) begin 
				cnt_addr <= cnt_addr + 4'd1;
			end
			else begin
				cnt_addr <= cnt_addr;
			end
		end
		else begin
			if(in_rdy) begin
				if(in_vld) begin
					if(cnt > 2) begin
						cnt_addr <= cnt - 2;		// ??? ?? ???? ????? ????
					end
					else
						cnt_addr <= 0;
				end
				else begin
					cnt_addr <= cnt_addr;
				end
			end
			else begin
				if(cnt > 2) begin
					cnt_addr <= cnt - 2;		// ??? ?? ???? ????? ????
				end
				else
					cnt_addr <= 0;
			end
		end
	end
end

always@(posedge clk) begin
	if(!nrst) begin
		cnt_oaddr <= -1;	
	end	
	else begin
		if(in_vld == 1'b0 && out_rdy == 1'b0) begin     // ?? ?? 0??? FFT ????
			cnt_oaddr <= -1;
		end
        else if(cnt_oaddr == 4'd15) begin
			cnt_oaddr <= 0; 
        end
		else if(cstate == IDLE && in_rdy == 1) begin
			if(in_vld == 1) begin 
				cnt_oaddr <= cnt_oaddr + 4'd1;
			end
			else begin
				cnt_oaddr <= cnt_oaddr;
			end
		end
		else begin
			if(in_rdy == 1 && in_vld == 1) begin
				if(vld_flag != 0) begin
					cnt_oaddr <= cnt_oaddr;
				end
				else begin
					if(cnt > 2) begin
						cnt_oaddr <= cnt - 2;		// ??? ?? ???? ????? ????
					end
					else begin
						cnt_oaddr <= 0;
					end
				end
			end
			else if(in_rdy == 1 && in_vld == 0) begin
				if(vld_flag == 0) begin
					cnt_oaddr <= cnt_oaddr + 5'd1;
				end
				else begin
					cnt_oaddr <= cnt_oaddr;
				end
			end
			else begin
				if(cnt > 2) begin
					cnt_oaddr <= cnt - 2;		// ??? ?? ???? ????? ????
				end
				else begin
					cnt_oaddr <= 0;
				end
			end
		end
	end
end

/* cnt_in */
always@(posedge clk) begin
	if (!nrst) begin
		cnt_in <= 0;
	end 
	else if(in_vld == 1'b0 && out_rdy == 1'b0) begin    // ?? ?? 0??? FFT ????
			cnt_in <= 0;
	end
	else begin
		case (cstate)
			IDLE : begin	// cstate=IDLE ???, cnt_in : 0~15 counter
				if(cnt_in == 5'd15) begin		
					cnt_in <= 0;
				end 
				else begin
					if(in_vld == 1'b1 && in_rdy == 1'b1) begin
						cnt_in <= cnt_in + 5'd1;
					end
					else begin
						cnt_in <= cnt_in;
					end
				end
			end
			Stage4 : begin	// cstate=STAGE4 ???, cnt=3 ???? count ????
				if(cnt_in == 5'd15) begin		
					cnt_in <= 0;
				end
				else if(cnt < 3) begin
					cnt_in <= 0;	// -2?? ??????????, cnt_in?? ???????? ?????
				end
				else begin
					if(in_rdy) begin
						if(in_vld) begin
							cnt_in <= cnt_in + 5'd1;
						end
						else begin
							cnt_in <= cnt_in;
						end
					end
					else begin
						cnt_in <= cnt_in + 5'd1;
					end
				end
			end
			default begin	// ?????? state ???, ???? 0
				cnt_in <= 0;
			end
		endcase
	end
end

/* cnt_out */
always@(posedge clk) begin
	if(!nrst) begin
		cnt_out <= 0;
	end
	else begin
		if(in_vld == 1'b0 && out_rdy == 1'b0) begin
			cnt_out <= 0;
		end
		else if(cnt_out == 5'd16) begin
			cnt_out <= 0;
		end
		else if(cstate_out == RUN) begin
			cnt_out <= cnt_out + 5'd1;
		end
        else begin
			cnt_out <= 0;
		end
	end
end


always @(posedge clk)
begin
    if(!nrst) begin
       cstate <= IDLE;
       cstate_in <= IDLE[0];
       cstate_out <= IDLE;
    end
    else if ( in_vld == 1'b0 && out_rdy == 1'b0) begin     // ?? ?? 0??? ??? state IDLE -> FFT ????
       cstate <= IDLE;
       cstate_in <= IDLE[0];
       cstate_out <= IDLE;
    end
    else begin
       cstate <= nstate;
       cstate_in <= nstate_in;
       cstate_out <= nstate_out;
    end
end

/* cstate, cstate_in, cstate_out */
always @(*) begin
    case(cstate)
	        IDLE : begin
	            if(in_vld == 1'b1 && cnt_in == 5'd15) begin
	               nstate <= Stage1;
	            end
	            else begin
	               nstate <= IDLE;
	            end
	        end
            Stage1 : begin
                if(cnt == 5'd18) begin
                    nstate <= Stage2;
                end
                else begin
                    nstate <= Stage1;
                end
            end
            Stage2 : begin
                if(cnt == 5'd18) begin
                    nstate <= Stage3;
                end
                else begin
                    nstate <= Stage2;
                end
            end
            Stage3 : begin
                if(cnt == 5'd18) begin
                    nstate <= Stage4;
                end
                else begin
                    nstate <= Stage3;
                end
            end
            Stage4 : begin
                if(cnt == 5'd18) begin
                    nstate <= Stage1;
                end
                else begin
                    nstate <= Stage4;
                end
            end
			default : nstate <= IDLE;
	endcase

	// cnt_in ?? ??? ??? cstate_in ?????
    case(cstate_in)
	        IDLE[0] : begin
	            if((cstate == IDLE && in_vld == 1) || (cstate == Stage4 && cnt == 2)) begin	// cnt_in ?? -1 ???? ??????? cnt_in???? ??? ????
	               nstate_in <= RUN[0];
	            end
	            else begin
	               nstate_in <= IDLE[0];
	            end
	        end
           
            RUN[0] : begin
                if((cstate == IDLE || cstate == Stage4) && cnt_in == 5'd15) begin		// 15 ????? IDLE?? ????
                    nstate_in <= IDLE[0];
                end
                else begin
                    nstate_in <= RUN[0];
                end
            end
			default : nstate_in <= RUN[0];		// IDLE ?
	endcase

    case(cstate_out)
	        IDLE[0] : begin
	            if(cstate == Stage4 && cnt == 5'd18) begin
	               nstate_out <= RUN[0];
	            end
	            else begin
	               nstate_out <= IDLE[0];
	            end
	        end
           
            RUN[0] : begin
                if(cnt_out == 16) begin
                    nstate_out <= IDLE[0];
                end
                else begin
                    nstate_out <= RUN[0];
                end
            end
			default : nstate_out <= IDLE[0];
	endcase
end

assign en_REG_A = in_rdy ? (in_vld ? (vld_flag ? 0 : cnt[0]) : (vld_flag ? 0 : 1)) : cnt[0];

always @(posedge clk) 
begin
	if(!nrst) begin
		en_REG_B <=0;
		en_REG_C <=0;
	end
    else if(cstate != IDLE) begin
		if(in_rdy) begin
			if(vld_flag) begin
				en_REG_C <= 0;
				en_REG_B <= 0;
			end
			else begin
				en_REG_B <= en_REG_A;
				en_REG_C <= cnt_oaddr[0];
			end
		end
		else begin
			en_REG_B <= en_REG_A;		// delay
			en_REG_C <= en_REG_B;		// delay
		end
	end
	else begin
		en_REG_B <= 0;
		en_REG_C <= 0;
	end 
end

// addr_CROM - twiddel factor ??? ???? ??????? ??
// cnt_cr : clock cycle delay of cnt
// stage1 : all 0, Stage2 : cnt_cr[1] *4, Stage3 : cnt_cr[1]*2+cnt_cr[2]*4, Stage4 : cnt_cr[1]+cnt_cr[2]*2+cnt_cr[3]*4
assign addr_CROM = (cnt > 0 && cnt < 17) ? (cstate == Stage1 ? 0 : (cstate == Stage2 ? cnt_cr[1] * 4 : 
					(cstate == Stage3 ? 2*cnt_cr[1]+4*cnt_cr[2] : (cstate == Stage4 ? cnt_cr[1]+2*cnt_cr[2]+4*cnt_cr[3] : 0)))) : 0;


assign out_vld = cstate_out && cnt_out;		// cnt_out >= 1 ???? ??
assign in_rdy = cstate_in;		// cstate_in == RUN ???				

assign sel_input = in_rdy;

assign we_AMEM 	= (cstate == Stage1 || cstate == Stage3) ? 1 : (cstate == IDLE ? 0 : (cnt < 3 ? 1 : 0));
assign we_BMEM 	= (cstate == Stage2 || cstate == Stage4) ? 1 : (cstate == IDLE ? 1 : (cnt < 3 ? 1 : 0));
assign we_OMEM 	= (cstate == Stage4 && cnt >= 3) ? 0 : 1;

assign sel_res = in_rdy ? (in_vld ? (sel_flag ? 0 : en_REG_A) : 0) : en_REG_C;
assign sel_mem  = (cstate == Stage2 || cstate == Stage4) ? 1 : 0;

// stage1 : ????, stage2 : 3201, stage3 : 3021, stage4 : 0123
assign addr_AMEM =  we_AMEM ? (cstate == Stage1 ? {cnt[3], cnt[2], cnt[1], cnt[0]} : (cstate == Stage3 ? {cnt[3], cnt[0], cnt[2], cnt[1]} : 0))		// AMEM OUT
								: (cstate == Stage2 ? {cnt_addr[3], cnt_addr[2], cnt_addr[0], cnt_addr[1]} : {cnt_addr[0], cnt_addr[1], cnt_addr[2], cnt_addr[3]});	  // AMEM IN

// stage1 : ????, stage2 : 3201, stage3 : 3021, stage4 : 0321
assign addr_BMEM = we_BMEM ? (cstate == Stage2 ? {cnt[3], cnt[2], cnt[0], cnt[1]} : (cstate == Stage4 ? {cnt[0], cnt[3], cnt[2], cnt[1]} : 0))
								: (cstate == Stage1 ? {cnt_addr[3], cnt_addr[2], cnt_addr[1], cnt_addr[0]} : {cnt_addr[3], cnt_addr[0], cnt_addr[2], cnt_addr[1]});
assign addr_OMEM = !(we_OMEM) ? {cnt_addr[0], cnt_addr[3], cnt_addr[2], cnt_addr[1]} : {cnt_out[3], cnt_out[2], cnt_out[1], cnt_out[0]};
		
//////////Edit code above!!/////////
////////////////////////////////////		
		
endmodule
