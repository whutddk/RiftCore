/*
* @File name: instr_queue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 19:48:59
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
	output [63:0] fetch_pc_bypass,
	output [69:0] preDecode_info,


	//to decoder



	// input pcGen_pre_valid,
	// output pcGen_pre_ready,

	// input [31:0] pcGen_instr,
	// output [31:0] decoder_instr,
	// input [63:0] pcGen_pc,
	// output [63:0] decoder_pc,

	// input isRVC_in,
	// output isRVC_out,
	
	// output fetch_decoder_valid,
	// input  fetch_decoder_ready,

	input flush,
	input CLK,
	input RSTn
);

	wire isJal, isJalr, isBranch, isCall, isReturn,isRVC;
	wire [63:0] imm;

	assign fetch_pc_valid = fetch_valid;
	assign fetch_pc_bypass = fetch_pc;
	assign preDecode_info = { isJal, isJalr, isBranch, isCall, isReturn, isRVC, imm };





	wire [31:0] addr_align = fetch_pc[1] ? fetch_instr[47:16] : fetch_instr[31:0];
	assign is_rvc_instr = (addr_align[1:0] != 2'b11);
	assign instr_readout = addr_align;


	//branch predict
	preDecode i_preDecode(
		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),

		.instr_readout(instr_readout),
		.isRVC(isRVC)
	);
















// assign pcGen_pre_ready = fetch_decoder_ready;
// gen_dffren # (.DW(1)) valid_dffren ( .dnxt(pcGen_pre_valid & ~flush), .qout(fetch_decoder_valid), .en(fetch_decoder_ready), .CLK(CLK), .RSTn(RSTn) );

// gen_dffren # (.DW(1)) isRVC ( .dnxt(isRVC_in), .qout(isRVC_out), .CLK(CLK), .en(fetch_decoder_ready), .RSTn(RSTn));
// gen_dffren # (.DW(32)) instr ( .dnxt(pcGen_instr), .qout(decoder_instr), .en(fetch_decoder_ready), .CLK(CLK), .RSTn(RSTn));
// gen_dffren # (.DW(64)) pc ( .dnxt(pcGen_pc), .qout(decoder_pc), .CLK(CLK), .en(fetch_decoder_ready), .RSTn(RSTn));





endmodule


