/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 15:56:12
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
	output pcGen_fetch_ready,


	//to instr queue
	input fetch_queue_ready,
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


	wire bpfifo_valid_i;
	wire bpfifo_ready_i;
	wire bpfifo_valid_o;
	wire bpfifo_ready_o;
	wire [127:0] bpfifo_data_o;

	wire [63:0] bypass_instr;
	wire [63:0] bypass_pc;

	assign bpfifo_valid_i = ifu_slvRsp_valid;
	assign bpfifo_ready_o = fetch_queue_ready;
	assign pcGen_fetch_ready = bpfifo_ready_i;

	gen_bypassfifo # 
	(
		.DW(64+64)
	)
	bypassfifo
	(
		.valid_i(bpfifo_valid_i), //ifu read out
		.data_i({pending_addr, ifu_data_r}),
		.ready_i(bpfifo_ready_i), //the fifo is empty  (output)

		.valid_o(bpfifo_valid_o), //the bypass data is valid (output)
		.data_o(bpfifo_data_o),
		.ready_o(bpfifo_ready_o), //instr_queue handshake

		.flush(flush),
		.CLK(CLK),
		.RSTn(RSTn)
	);










gen_dffr # ( .DW(64), .rstValue(64'h80000000)) fetch_pc_dffren ( .dnxt(bpfifo_data_o[127:64]), .qout(fetch_pc), .CLK(CLK), .RSTn(RSTn));
gen_dffr # ( .DW(64)) fetch_instr_dffr ( .dnxt(bpfifo_data_o[63:0]), .qout(fetch_instr), .CLK(CLK), .RSTn(RSTn));
gen_dffr # ( .DW(1)) fetch_valid_dffr ( .dnxt(bpfifo_valid_o & ~flush), .qout(fetch_valid), .CLK(CLK), .RSTn(RSTn));











endmodule




