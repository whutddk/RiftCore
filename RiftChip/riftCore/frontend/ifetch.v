/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-05 17:02:38
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

	output ifu_req_valid,
	input ifu_req_ready,
	output [31:0] ifu_addr_req,
	input [63:0] ifu_data_rsp,
	input ifu_rsp_valid,
	output ifu_rsp_ready,
	output il1_fence,


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




	assign axi_arvalid_set = (if_iq_ready | boot) & ~flush;

	assign IFU_ARADDR = fetch_addr_qout & (~64'b111);
	// gen_dffren # ( .DW(64)) araddr_dffren ( .dnxt(fetch_addr_qout & (~64'b111)), .qout(IFU_ARADDR), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));

	assign IFU_ARVALID = axi_arvalid_qout;
	assign IFU_ARPROT	= 3'b001;
	assign IFU_RREADY	= axi_rready_qout;



	assign axi_arvalid_rst = ~axi_arvalid_set & (IFU_ARREADY & axi_arvalid_qout);
	assign axi_rready_set = IFU_RVALID & ~axi_rready_qout;
	assign axi_rready_rst = axi_rready_qout;


	gen_slffr # (.DW(1)) axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));








endmodule




