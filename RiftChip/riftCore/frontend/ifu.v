/*
* @File name: ifu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 18:10:56
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


module ifu #
(
	parameter DW = 64
)
(

	output ifu_mstReq_valid,
	output [63:0] ifu_addr,
	input [63:0] ifu_data_r,
	input ifu_slvRsp_valid,


	input pcGen_fetch_valid,
	input [63:0] fetch_pc_dnxt,
	output [63:0] fetch_pc_qout,
	output [63:0] fetch_instr,
	output fetchBuff_valid,
	input pcGen_pre_ready,

	input CLK,
	input RSTn

);


assign ifu_mstReq_valid = pcGen_fetch_valid;
assign ifu_addr = fetch_pc_dnxt;

wire [63:0] pending_addr;
gen_dffren # ( .DW(64), .rstValue(64'h80000000)) pending_addr_dffren ( .dnxt(ifu_addr), .qout(pending_addr), .en(ifu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(64), .rstValue(64'h80000000)) fetch_pc_dffren ( .dnxt(pending_addr), .qout(fetch_pc_qout), .en(ifu_slvRsp_valid&(pcGen_pre_ready)), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(64)) fetch_instr_dffren ( .dnxt(ifu_data_r), .qout(fetch_instr), .en(ifu_slvRsp_valid&(pcGen_pre_ready)), .CLK(CLK), .RSTn(RSTn));
gen_dffr # ( .DW(1)) fetch_valid ( .dnxt(ifu_slvRsp_valid), .qout(fetchBuff_valid), .CLK(CLK), .RSTn(RSTn));











endmodule




