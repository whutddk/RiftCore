/*
* @File name: frontEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-31 15:42:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 16:01:00
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

module frontEnd (

	input instrFifo_full,
	output instrFifo_push,
	output [`DECODE_INFO_DW-1:0] decode_microInstr,

	output flush,
	input bru_res_valid,
	input bru_takenBranch,
	input jalr_valid,
	input [63:0] jalr_pc,

	input [63:0] privileged_pc,
	input privileged_valid,

	output ifu_mstReq_valid,
	output [63:0] ifu_addr,
	input [63:0] ifu_data_r,
	input ifu_slvRsp_valid,


	input CLK,
	input RSTn
	
);








wire isMisPredict;

assign flush = isMisPredict | privileged_valid;

wire [63:0] fetch_pc_qout;
wire isReset_qout;


// gen_dffr # (.DW(64), .rstValue(64'h80000000)) fetch_pc ( .dnxt(fetch_pc_dnxt), .qout(fetch_pc_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) isReset ( .dnxt(1'b1), .qout(isReset_qout), .CLK(CLK), .RSTn(RSTn));

wire [31:0] isInstrFetch;
wire [31:0] instr;
wire pcGen_pre_valid;
wire pcGen_pre_ready;

wire fetch_decode_valid;
wire fetch_decoder_ready;
wire is_rvc_instr;
//C0
pcGenerate i_pcGenerate
(
	//feedback
	// .fetch_pc_dnxt(fetch_pc_dnxt),
	.fetch_pc_qout(fetch_pc_qout),
	.isReset(~isReset_qout),

	//from jalr exe
	.jalr_valid(jalr_valid),
	.jalr_pc(jalr_pc),
	
	//from bru
	.bru_res_valid(bru_res_valid),
	.bru_takenBranch(bru_takenBranch),

	// from expection 	
	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

	//to fetch
	.instr_readout(isInstrFetch),
	.is_rvc_instr(is_rvc_instr),

	//to commit to flush
	.isMisPredict(isMisPredict),

	.pcGen_pre_valid(pcGen_pre_valid),
	.pcGen_pre_ready(pcGen_pre_ready),

	.ifu_mstReq_valid(ifu_mstReq_valid),
	.ifu_addr(ifu_addr),
	.ifu_data_r(ifu_data_r),
	.ifu_slvRsp_valid(ifu_slvRsp_valid),

	.CLK(CLK),
	.RSTn(RSTn)
);




//T0  
//T0 is included in C0

wire [63:0] decode_pc;
wire is_rvc;
//C1
instr_fetch i_instr_pre(

	.pcGen_pre_valid(pcGen_pre_valid),
	.pcGen_pre_ready(pcGen_pre_ready),

	.pcGen_instr(isInstrFetch),
	.decoder_instr(instr),
	.pcGen_pc(fetch_pc_qout),
	.decoder_pc(decode_pc),

	.isRVC_in(is_rvc_instr),
	.isRVC_out(is_rvc),
	
	.fetch_decoder_valid(fetch_decode_valid),
	.fetch_decoder_ready(fetch_decoder_ready),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
	
);




//T1
//T1 is included in C1


//C2
decoder i_decoder
(
	.instr(instr),
	.fetch_decode_valid(fetch_decode_valid),
	.fetch_decoder_ready(fetch_decoder_ready),
	.pc(decode_pc),
	.is_rvc(is_rvc),

	.instrFifo_full(instrFifo_full),
	.decode_microInstr(decode_microInstr),
	.instrFifo_push(instrFifo_push)

);










endmodule






