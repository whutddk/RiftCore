/*
* @File name: frontEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-31 15:42:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 17:42:35
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

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

module frontEnd (

	input instrFifo_full,
	output instrFifo_push,
	output [`DECODE_INFO_DW-1:0] decode_microInstr,

	output isMisPredict,
	input bru_res_vaild,
	input bru_takenBranch,
	input jalr_vaild,
	input [63:0] jalr_pc,

	input CLK,
	input RSTn
	
);

wire flush = isMisPredict;

wire [63:0] fetch_pc_dnxt,fetch_pc_qout;
wire isReset_qout;


gen_dffr # (.DW(64), .rstValue(64'h80000000)) fetch_pc ( .dnxt(fetch_pc_dnxt), .qout(fetch_pc_qout), .CLK(CLK), .RSTn(RSTn));
// gen_dffr # (.DW(1)) isReset ( .dnxt(1'b1), .qout(isReset_qout), .CLK(CLK), .RSTn(RSTn));

wire [31:0] isInstrFetch;
wire [31:0] instr;
wire isInstrReadOut;

wire fetch_decode_vaild;

//C0
pcGenerate i_pcGenerate
(
	//feedback
	.fetch_pc_dnxt(fetch_pc_dnxt),
	.fetch_pc_reg(fetch_pc_qout),
	// .isReset(~isReset_qout),

	//from jalr exe
	.jalr_vaild(jalr_vaild),
	.jalr_pc(jalr_pc),
	
	//from bru
	.bru_res_vaild(bru_res_vaild),
	.bru_takenBranch(bru_takenBranch),

	// from expection 	


	//to fetch
	.instr_readout(isInstrFetch),

	//to commit to flush
	.isMisPredict(isMisPredict),

	.isInstrReadOut(isInstrReadOut),
	.instrFifo_full(instrFifo_full),

	.CLK(CLK),
	.RSTn(RSTn)
);




//T0  
//T0包含在了C0里

wire [63:0] decode_pc;
//C1
instr_fetch i_instr_pre(

	.instr_readout(isInstrFetch),
	.instr(instr),
	.pc_in(fetch_pc_qout),
	.pc_out(decode_pc),

	//handshake
	.isInstrReadOut(isInstrReadOut),
	.fetch_decode_vaild(fetch_decode_vaild),
	.instrFifo_full(instrFifo_full),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
	
);




//T1
//T1包含在C1中


//C2
decoder i_decoder
(
	.instr(instr),
	.fetch_decode_vaild(fetch_decode_vaild),
	.pc(decode_pc),

	.instrFifo_full(instrFifo_full),
	.decode_microInstr(decode_microInstr),
	.instrFifo_push(instrFifo_push)

);




endmodule






