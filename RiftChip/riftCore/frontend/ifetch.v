/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-09 17:04:55
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


module ifetch (

	output ifu_req_valid,
	input ifu_req_ready,
	output [31:0] ifu_addr_req,
	input [63:0] ifu_data_rsp,
	input ifu_rsp_valid,
	output ifu_rsp_ready,

	//from pcGen
	input [63:0] pc_if_addr,
	output pc_if_ready,

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

wire cache_req;
wire cache_rsp;
wire ifu_req_valid_set, ifu_req_valid_rst, ifu_req_valid_qout;


assign pc_if_ready = cache_req & ~invalid_outstanding_qout;

assign boot_set = (flush & (~pending_trans_qout | ( pending_trans_qout & cache_rsp ))) | (invalid_outstanding_qout & invalid_outstanding_rst);
assign boot_rst = ifu_req_valid_set & ~boot_set;


assign pending_trans_set = ifu_req_valid_set;
assign pending_trans_rst = (~ifu_req_valid_set & cache_rsp );
assign invalid_outstanding_set = pending_trans_qout & flush & ~invalid_outstanding_rst;
assign invalid_outstanding_rst = cache_rsp;

gen_rsffr # ( .DW(1), .rstValue(1'b1))  boot_rsffr  ( .set_in(boot_set), .rst_in(boot_rst), .qout(boot), .CLK(CLK), .RSTn(RSTn));

gen_dffren # ( .DW(64)) pending_addr_dffren ( .dnxt(pc_if_addr), .qout(pending_addr), .en(ifu_req_valid_set), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   pending_trans_rsffr ( .set_in(pending_trans_set), .rst_in(pending_trans_rst), .qout(pending_trans_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   invalid_outstanding_rsffr ( .set_in(invalid_outstanding_set), .rst_in(invalid_outstanding_rst), .qout(invalid_outstanding_qout), .CLK(CLK), .RSTn(RSTn));


gen_dffren # ( .DW(64)) if_iq_pc_dffren    ( .dnxt(pending_addr),   .qout(if_iq_pc),    .en(cache_rsp), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(64)) if_iq_instr_dffren ( .dnxt(ifu_data_rsp), .qout(if_iq_instr), .en(cache_rsp), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   if_iq_valid_rsffr  ( .set_in(cache_rsp & ~invalid_outstanding_qout & (~flush)), .rst_in(if_iq_valid | flush), .qout(if_iq_valid), .CLK(CLK), .RSTn(RSTn));


// assign if_iq_pc = pending_addr;
// assign if_iq_instr = ifu_data_rsp;
// assign if_iq_valid = cache_rsp & ~invalid_outstanding_qout & (~flush);












	assign cache_req = ifu_req_valid & ifu_req_ready;
	assign cache_rsp = ifu_rsp_valid & ifu_rsp_ready;


	assign ifu_rsp_ready = 1'b1;


	wire isIFU_busy_set, isIFU_busy_rst, isIFU_busy_qout;

	assign isIFU_busy_set = ifu_req_valid_set;
	assign isIFU_busy_rst = cache_rsp;

	gen_rsffr # (.DW(1)) isIFU_busy_rsffr (.set_in(isIFU_busy_set), .rst_in(isIFU_busy_rst), .qout(isIFU_busy_qout), .CLK(CLK), .RSTn(RSTn) );


	assign ifu_req_valid_set = ~isIFU_busy_qout & (if_iq_ready | boot) & ~flush;
	assign ifu_req_valid_rst = cache_req;
	assign ifu_req_valid = ifu_req_valid_qout;
	gen_rsffr # ( .DW(1)) ifu_req_valid_rsffr
	(
		.set_in(ifu_req_valid_set),
		.rst_in(ifu_req_valid_rst),
		.qout  (ifu_req_valid_qout),
		.CLK   (CLK),
		.RSTn  (RSTn)
	);

	// assign axi_arvalid_set = (if_iq_ready | boot) & ~flush;

	assign ifu_addr_req = pc_if_addr[31:0] & (~32'b111);
	// assign IFU_ARADDR = pc_if_addr & (~64'b111);

	// assign IFU_ARVALID = axi_arvalid_qout;
	// assign IFU_ARPROT	= 3'b001;
	// assign IFU_RREADY	= axi_rready_qout;



	// assign axi_arvalid_rst = ~axi_arvalid_set & (IFU_ARREADY & axi_arvalid_qout);
	// assign axi_rready_set = IFU_RVALID & ~axi_rready_qout;
	// assign axi_rready_rst = axi_rready_qout;


	// gen_slffr # (.DW(1)) axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	// gen_rsffr # (.DW(1)) axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));








endmodule




