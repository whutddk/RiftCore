/*
* @File name: instr_queue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 11:50:20
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

module instr_queue (

	//form ifetch
	input [63:0] fetch_pc,
	input [63:0] fetch_instr,
	input fetch_valid,

	//to pcGen
	output fetch_pc_valid,
	output [63:0] fetch_pc_queue,
	output [69:0] preDecode_info,

	//to decoder
	output queue_decode_valid,
	input queue_decode_ready,

	output [31:0] queue_decode_instr,
	output [63:0] queue_decode_pc,
	output queue_decode_isRVC,

	input flush,
	input CLK,
	input RSTn
);

	wire isJal, isJalr, isBranch, isCall, isReturn, isRVC;
	wire [63:0] imm;

	wire bpfifo_valid_i;
	wire bpfifo_ready_i;
	wire bpfifo_valid_o;
	wire bpfifo_ready_o;

	wire [63:0] bypass_instr;
	wire [63:0] bypass_pc;


	assign fetch_pc_valid = bpfifo_ready_i & queue_decode_ready; //both instr fifo not full and bypass fifo empty can fetch instr
	assign bpfifo_valid_i = fetch_valid;

	assign bpfifo_ready_o = queue_decode_ready;

	gen_dffren # (.DW(1)) queue_decode_valid_dffren ( .dnxt(bpfifo_valid_o & ~flush), .qout(queue_decode_valid), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn) );


	gen_bypassfifo # 
	(
		.DW(64+64)
	)
	bypassfifo
	(
		.valid_i(bpfifo_valid_i), //ifu read out
		.data_i({fetch_pc, fetch_instr}),
		.ready_i(bpfifo_ready_i), //the fifo is empty  (output)

		.valid_o(bpfifo_valid_o), //the bypass data is valid (output)
		.data_o({bypass_pc, bypass_instr}),
		.ready_o(bpfifo_ready_o), //decoder handshake

		.flush(flush),
		.CLK(CLK),
		.RSTn(RSTn)
	);



	wire [31:0] align_instr;

	assign align_instr = bypass_pc[1] ? bypass_instr[47:16] : bypass_instr[31:0];
	assign isRVC = (align_instr[1:0] != 2'b11);

	assign fetch_pc_queue = queue_decode_pc;
	assign preDecode_info = { isJal, isJalr, isBranch, isCall, isReturn, isRVC, imm };

	//branch predict
	preDecode i_preDecode(
		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),

		.instr(align_instr),
		.isRVC(isRVC)
	);


	gen_dffren # (.DW(32)) instr_dffren ( .dnxt(align_instr), .qout(queue_decode_instr), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(64)) pc_dffren    ( .dnxt(bypass_pc),   .qout(queue_decode_pc),    .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1))  isRVC_dffren ( .dnxt(isRVC),       .qout(queue_decode_isRVC), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));






endmodule


