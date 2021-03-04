/*
* @File name: wt_block
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-03-02 14:32:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-04 11:52:32
*/


/*
  Copyright (c) 2020 - 2021 Ruige Lee <wut.ruigeli@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/



`timescale 1 ns / 1 ps

`include "define.vh"

module wt_block # 
(
	parameter DW = 64 + 8 + 32,
	parameter DP = 8,
	parameter TAG_W = 32
)
(
	input [31:0] chkAddr,
	output isHazard_r,

	input push,
	input [DW-1:0] data_i,

	input pop,
	output [DW-1:0] data_o,

	output empty,
	output full,

	input CLK,
	input RSTn
);


wire [DP-1:0] isAddrHit_r;

generate
	for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin
		wire [31:0] wtb_addr_qout = wtb_info_qout[ DW*dp +: 32];
		assign isAddrHit_r = ( chkAddr[31 -: TAG_W] == wtb_addr_qout[31 -: TAG_W] ) & valid_qout[dp];
	end
endgenerate

assign isHazard_r = | isAddrHit_r;


assign data_o = wtb_info_qout[DW*rdp_qout+:DW];







wire [DW*DP-1:0] wtb_info_dnxt;
wire [DW*DP-1:0] wtb_info_qout;
wire [DP-1:0] wtb_info_en;

wire [DP-1:0] valid_dnxt;
wire [DP-1:0] valid_qout;
wire [DP-1:0] valid_en;





localparam AW = $clog2(DP);




assign wtb_info_en = {DP{push}} & ((1 << wrp_qout[AW-1:0]));
assign valid_en =
		  ({DP{pop }} & (1 << rdp_qout[AW-1:0]))
		| ({DP{push}} & (1 << wrp_qout[AW-1:0]));


generate
	for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin

		assign valid_dnxt[dp] = push;

		assign wtb_info_dnxt[DW*dp+:DW] = data_i;

		gen_dffren # (.DW(DW)) wtb_info_dffren 
		(
			.dnxt(wtb_info_dnxt[DW*dp +: DW]),
			.qout(wtb_info_qout[DW*dp +: DW]),
			.en(wtb_info_en[dp]),
			.CLK(CLK),
			.RSTn(RSTn)
		);

		gen_dffren # (.DW(1)) valid_dffren
		(
			.dnxt(valid_dnxt[dp]),
			.qout(valid_qout[dp]),
			.en(valid_en[dp]),
			.CLK(CLK),
			.RSTn(RSTn)
		);


	end



endgenerate

	assign full = &valid_qout;
	assign empty = &(~valid_qout);




wire [AW+1-1:0] rdp_dnxt;
wire [AW+1-1:0] rdp_qout;
wire [AW+1-1:0] wrp_dnxt;
wire [AW+1-1:0] wrp_qout;



gen_dffr #( .DW(AW+1) ) rdp_dffr ( .dnxt(rdp_dnxt), .qout(rdp_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr #( .DW(AW+1) ) wrp_dffr ( .dnxt(wrp_dnxt), .qout(wrp_qout), .CLK(CLK), .RSTn(RSTn));


assign rdp_dnxt = pop  ? rdp_qout + 'd1 : rdp_qout;
assign wrp_dnxt = push ? wrp_qout + 'd1 : wrp_qout;









//ASSERT
always @( negedge CLK ) begin

	if (
		(rdp_qout == wrp_qout & ~empty)
		||
		((rdp_qout[AW-1:0] == wrp_qout[AW-1:0]) & (rdp_qout[AW] != wrp_qout[AW]) & ~full)
		) begin
		$display("Assert Fail at wt_block");
		$stop;
	end

end


endmodule



