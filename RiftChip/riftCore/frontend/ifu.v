/*
* @File name: ifu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 12:03:48
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
	output fetchBuff_ready,
	output fetchBuff_valid,
	input instrFifo_full,


	input flush,
	input CLK,
	input RSTn

);


assign ifu_mstReq_valid = pcGen_fetch_valid;
assign ifu_addr = fetch_pc_dnxt;


wire [63:0] fetch_pc_tmp;


gen_dffren # ( .DW(64), .rstValue(64'h80000000)) fetch_pc ( .dnxt(fetch_pc_dnxt), .qout(fetch_pc_tmp), .en(fetchBuff_valid), .CLK(CLK), .RSTn(RSTn));







gen_bypassfifo # ( .DW(64+64), .AW(0) ) 
fetchBuff
(
	.valid_i(ifu_slvRsp_valid),
	.data_i({fetch_pc_tmp, ifu_data_r}),
	.ready_i(fetchBuff_ready),

	.valid_o(fetchBuff_valid),
	.data_o({fetch_pc_qout, fetch_instr}),
	.ready_o(~instrFifo_full),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);








endmodule




