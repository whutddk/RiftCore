/*
* @File name: icache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-25 15:14:09
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


module ifetch #
(
	parameter DW = 64
)
(

	output [63:0] IFU_ARADDR,
	output [2:0] IFU_ARPROT,
	output IFU_ARVALID,
	input IFU_ARREADY,
	input [255:0] IFU_RDATA,
	input [1:0] IFU_RRESP,
	input IFU_RVALID,
	output IFU_RREADY,

	//from pcGen
	input [DW-1:0] fetch_addr_qout,
	output pcGen_fetch_ready,

	//to iqueue
	output [63:0] if_iq_pc,
	output [63:0] if_iq_instr,
	output if_iq_valid,
	input if_iq_ready,

	input flush,
	input CLK,
	input RSTn

);

wire boot;
wire boot_set;
wire boot_rst;
wire [63:0] pending_addr;
wire pending_trans_set;
wire pending_trans_rst;
wire pending_trans_qout;
wire invalid_outstanding_set;
wire invalid_outstanding_rst;
wire invalid_outstanding_qout;

wire axi_awvalid_set, axi_awvalid_rst, axi_awvalid_qout;
wire axi_wvalid_set, axi_wvalid_rst, axi_wvalid_qout;
wire axi_bready_set, axi_bready_rst, axi_bready_qout;

wire axi_arvalid_set, axi_arvalid_rst, axi_arvalid_qout;
wire axi_rready_set, axi_rready_rst, axi_rready_qout;


assign pcGen_fetch_ready = IFU_ARREADY & ~invalid_outstanding_qout;

assign boot_set = (flush & (~pending_trans_qout | ( pending_trans_qout & axi_rready_set ))) | (invalid_outstanding_qout & invalid_outstanding_rst);
assign boot_rst = axi_arvalid_set & ~boot_set;


assign pending_trans_set = axi_arvalid_set;
assign pending_trans_rst = (~axi_arvalid_set & axi_rready_set );
assign invalid_outstanding_set = pending_trans_qout & flush & ~invalid_outstanding_rst;
assign invalid_outstanding_rst = axi_rready_set;

gen_rsffr # ( .DW(1), .rstValue(1'b1))  boot_rsffr  ( .set_in(boot_set), .rst_in(boot_rst), .qout(boot), .CLK(CLK), .RSTn(RSTn));

gen_dffren # ( .DW(64)) pending_addr_dffren ( .dnxt(fetch_addr_qout), .qout(pending_addr), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   pending_trans_rsffr ( .set_in(pending_trans_set), .rst_in(pending_trans_rst), .qout(pending_trans_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   invalid_outstanding_rsffr ( .set_in(invalid_outstanding_set), .rst_in(invalid_outstanding_rst), .qout(invalid_outstanding_qout), .CLK(CLK), .RSTn(RSTn));


gen_dffren # ( .DW(64)) fetch_pc_dffren    ( .dnxt(pending_addr),   .qout(if_iq_pc),    .en(axi_rready_set), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(DW)) fetch_instr_dffren ( .dnxt(IFU_RDATA), .qout(if_iq_instr), .en(axi_rready_set), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   if_iq_valid_rsffr  ( .set_in(axi_rready_set & ~invalid_outstanding_qout & (~flush)), .rst_in(if_iq_ready | flush), .qout(if_iq_valid), .CLK(CLK), .RSTn(RSTn));






	wire isFetch_Req = (if_iq_ready | boot) & ~flush;
	wire isCache_Rsp;
	assign if_iq_valid = (isCache_Hit) 
						|
						();

	assign if_iq_instr = data_hit[ 64 * DoubleWord_Sel +: 64]


	gen_dffr # ( .DW(1)) isCache_Rsp_dffr ( .dnxt(isFetch_Req), .qout(isCache_Rsp), .CLK(CLK), .RSTn(RSTn));


	wire [1:0] DoubleWord_Sel = fetch_addr_qout[4:3];
	wire [5:0] address_Sel = fetch_addr_qout[10:5];
	wire [55:0] tag_Req = fetch_addr_qout[63:11];
	wire tag_valid;



	wire isCache_Miss = isCache_Rsp & (&(~tag_hit));
	wire isCache_Hit  = isCache_Rsp & (| tag_hit);





	assign axi_arvalid_set = isCache_Miss & ~flush;

	assign IFU_ARADDR = fetch_addr_qout & (~64'b111);

	assign IFU_ARVALID = axi_arvalid_qout;
	assign IFU_ARPROT	= 3'b001;
	assign IFU_RREADY	= axi_rready_qout;



	assign axi_arvalid_rst = ~axi_arvalid_set & (IFU_ARREADY & axi_arvalid_qout);
	assign axi_rready_set = IFU_RVALID & ~axi_rready_qout;
	assign axi_rready_rst = axi_rready_qout;


	gen_slffr # (.DW(1)) axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));



	wire [256*4-1:0 ] cache_data_out;
	wire [57*4-1:0] cache_tag_out;
	wire [3:0] tag_hit;
	wire [255:0] data_hit;
generate
	for ( genvar i = 0 ; i < 4; i = i+ 1 ) begin
		gen_sram # (.DW(256), .AW(6) ) data_ram,
		(

			input [DW-1:0] data_w,
			input [AW-1:0] addr_w,
			input [(DW+7)/8-1:0] data_wstrb,
			input en_w,


			.data_r(cache_data_out[256*i +: 256]),
			.addr_r(address_Sel),
			.en_r(isFetch_Req),

			.CLK(CLK)

		);

		gen_sram # (.DW(57), .AW(6) ) tag_ram,
		(

			input [DW-1:0] data_w,
			input [AW-1:0] addr_w,
			input [(DW+7)/8-1:0] data_wstrb,
			input en_w,


			.data_r(cache_tag_out[57*i+:57]),
			.addr_r(address_Sel),
			.en_r(isFetch_Req),

			.CLK(CLK)

		);
	end

	wire [56:0] tag_info = cache_tag_out[57*i+:57];
	assign tag_hit[i] = (tag_info[55:0] == tag_Req) & tag_info[56];

endgenerate


	assign data_hit = 	({256{tag_hit[0]}} & cache_data_out[256*0 +: 256])
						|
						({256{tag_hit[1]}} & cache_data_out[256*1 +: 256])
						|
						({256{tag_hit[2]}} & cache_data_out[256*2 +: 256])
						|
						({256{tag_hit[3]}} & cache_data_out[256*3 +: 256])
						|


						;
						





endmodule




