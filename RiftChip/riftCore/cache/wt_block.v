/*
* @File name: wt_block
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-03-02 14:32:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-02 19:16:22
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
	parameter DP = 8
)
(
	input [31:0] chkAddr,
	output isAddrHazard,

	input push,
	input [31:0] waddr,
	input [7:0] wstrb,
	input [63:0] wdata,

	input pop,
	output [DW-1:0] data_o,

	output empty,
	output full,

	input CLK,
	input RSTn
);

wire [DP-1:0] addrHit_r;
wire [DP-1:0] addrHit_w;


generate
	for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin
		assign addrHit_r = ( chkAddr == wtb_info_qout[ DW*dp +: 32] ) & valid[dp];
		assign addrHit_w = ( waddr   == wtb_info_qout[ DW*dp +: 32] ) & valid[dp];
	end
endgenerate

assign isAddrHazard = (| addrHit_r);

wire [64*DP-1:0] wtb_wdata_dnxt;
wire [64*DP-1:0] wtb_wdata_qout;
wire [8*DP-1:0] wtb_wstrb_dnxt;
wire [8*DP-1:0] wtb_wstrb_qout;
wire [32*DP-1:0] wtb_waddr_dnxt;
wire [32*DP-1:0] wtb_waddr_qout;

wire [32*DP-1:0] wtb_info_dnxt;
wire [32*DP-1:0] wtb_info_qout;
wire [DP-1:0] wtb_info_en;

wire [DP-1:0] valid_dnxt;
wire [DP-1:0] valid_qout;
wire [DP-1:0] valid_en;


wire [63:0] wtb_wdata_mask;



assign wtb_wdata_mask = { {8{wstrb[7]}}, {8{wstrb[6]}}, {8{wstrb[5]}}, {8{wstrb[4]}}, {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}};

	assign wtb_info_en = {DP{push}} & addrHit_w;

generate
	for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin


		assign wtb_wdata_dnxt[64*dp+:64] =
				  (wtb_wdata_qout[64*dp+:64] & (~wtb_wdata_mask) )
				| (wdata & (wtb_wdata_mask));


		assign wtb_wstrb_dnxt[8*dp+:8] = wtb_wstrb_qout[8*dp+:8] & {8{addrHit_w[dp]}} | wstrb;
		assign wtb_waddr_dnxt[32*dp+:32] = waddr;

		assign wtb_info_dnxt[DW*dp+:DW] = { wtb_wdata_dnxt[64*dp+:64], wtb_wstrb_dnxt[8*dp+:8], wtb_waddr_dnxt[32*dp+:32] };
		assign { wtb_wdata_qout[64*dp+:64], wtb_wstrb_qout[8*dp+:8], wtb_waddr_qout[32*dp+:32] } = wtb_info_qout[DW*dp+:DW];






		assign valid_dnxt[dp] = push & (~flush);
		assign valid_en[dp] = (pop | push | flush) & (dp == index);



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

	assign full = &valid_qout;
	assign empty = &(~valid_qout)


endgenerate





//ASSERT
always @( negedge CLK ) begin
	if (push & pop)  begin
		$display("Assert Fail at wt_block");
		$stop;
	end


end


endmodule



