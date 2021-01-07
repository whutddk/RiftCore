/*
* @File name: instr_queue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 15:28:45
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
	output fetch_queue_ready,

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
	wire [31:0] align_instr;

	assign fetch_pc_valid = fetch_valid & queue_decode_ready; 

	assign fetch_queue_ready = queue_decode_ready;







	assign align_instr = fetch_pc[1] ? fetch_instr[47:16] : fetch_instr[31:0];
	assign isRVC = (align_instr[1:0] != 2'b11);

	assign fetch_pc_queue = fetch_pc;
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

	gen_dffren # (.DW(1)) queue_decode_valid_dffren ( .dnxt(fetch_valid & ~flush), .qout(queue_decode_valid), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn) );

	gen_dffren # (.DW(32)) instr_dffren ( .dnxt(align_instr), .qout(queue_decode_instr), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(64)) pc_dffren    ( .dnxt(fetch_pc),   .qout(queue_decode_pc),    .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1))  isRVC_dffren ( .dnxt(isRVC),       .qout(queue_decode_isRVC), .en(queue_decode_ready), .CLK(CLK), .RSTn(RSTn));






endmodule


