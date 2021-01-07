/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 10:54:18
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
	output [63:0] ifu_addr,
	input [DW-1:0] ifu_data_r,
	input ifu_slvRsp_valid,

	//from pcGen
	input [DW-1:0] fetch_addr_qout,
	input fetch_addr_valid,


	//to instr queue
	output [63:0] fetch_pc,
	output [DW-1:0] fetch_instr,
	output fetch_valid,

	input flush,
	input CLK,
	input RSTn

);


assign ifu_mstReq_valid = fetch_addr_valid;
assign ifu_addr = fetch_addr_qout;

wire [63:0] pending_addr;

gen_dffren # ( .DW(64), .rstValue(64'h80000000)) pending_addr_dffren ( .dnxt(ifu_addr), .qout(pending_addr), .en(ifu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(64), .rstValue(64'h80000000)) fetch_pc_dffren ( .dnxt(pending_addr), .qout(fetch_pc), .en(ifu_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # ( .DW(64)) fetch_instr_dffren ( .dnxt(ifu_data_r), .qout(fetch_instr), .en(ifu_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffr # ( .DW(1)) fetch_valid_dffren ( .dnxt(ifu_slvRsp_valid & ~flush), .qout(fetch_valid), .CLK(CLK), .RSTn(RSTn));











endmodule




