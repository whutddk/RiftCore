/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-14 16:57:23
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

	output ifu_mstReq_valid,
	input ifu_mstReq_ready,
	output [63:0] ifu_addr,
	input [DW-1:0] ifu_data_r,
	input ifu_slvRsp_valid,

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


assign ifu_mstReq_valid = (if_iq_ready | boot) & ~flush ;
assign ifu_addr = fetch_addr_qout & (~64'b111);
assign pcGen_fetch_ready = ifu_mstReq_valid;

assign boot_set = flush;
assign boot_rst = ifu_mstReq_valid & ~boot_set;


assign pending_trans_set = ifu_mstReq_valid & ~flush;
assign pending_trans_rst = (~ifu_mstReq_valid & ifu_slvRsp_valid) | flush;


gen_rsffr # ( .DW(1), .rstValue(1'b1))  boot_rsffr  ( .set_in(boot_set), .rst_in(boot_rst), .qout(boot), .CLK(CLK), .RSTn(RSTn));

gen_dffren # ( .DW(64)) pending_addr_dffren    ( .dnxt(fetch_addr_qout),   .qout(pending_addr),    .en(ifu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   pending_trans_rsffr  ( .set_in(pending_trans_set), .rst_in(pending_trans_rst), .qout(pending_trans_qout), .CLK(CLK), .RSTn(RSTn));

gen_dffren # ( .DW(64)) fetch_pc_dffren    ( .dnxt(pending_addr),   .qout(if_iq_pc),    .en(ifu_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(DW)) fetch_instr_dffren ( .dnxt(ifu_data_r), .qout(if_iq_instr), .en(ifu_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1))   if_iq_valid_rsffr  ( .set_in(ifu_slvRsp_valid & pending_trans_qout & (~flush)), .rst_in(if_iq_ready | flush), .qout(if_iq_valid), .CLK(CLK), .RSTn(RSTn));











endmodule




