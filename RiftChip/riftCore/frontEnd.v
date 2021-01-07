/*
* @File name: frontEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-31 15:42:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 15:57:00
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
wire isReset;

wire [63:0] fetch_pc;
wire fetch_pc_valid;
wire [63:0] fetch_pc_queue;
wire [69:0] preDecode_info;

wire [63:0] fetch_addr_qout;
wire fetch_addr_valid;
wire pcGen_fetch_ready;

wire [63:0] fetch_instr;
wire fetch_valid;
wire fetch_queue_ready;

wire queue_decode_valid;
wire queue_decode_ready;

wire [31:0] queue_decode_instr;
wire [63:0] queue_decode_pc;
wire queue_decode_isRVC;



assign flush = isMisPredict | privileged_valid;



pcGenerate i_pcGenerate
(
	.isReset(~isReset),

	//from jalr exe
	.jalr_valid(jalr_valid),
	.jalr_pc(jalr_pc),
	
	//from bru
	.bru_res_valid(bru_res_valid),
	.bru_takenBranch(bru_takenBranch),

	// from expection 	
	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

	//to commit to flush
	.isMisPredict(isMisPredict),

	//from instr_queue,
	.fetch_pc_valid(fetch_pc_valid),
	.fetch_pc_queue(fetch_pc_queue),
	.preDecode_info(preDecode_info),

	//to ifetch
	.fetch_addr_qout(fetch_addr_qout),
	.fetch_addr_valid(fetch_addr_valid),
	.pcGen_fetch_ready(pcGen_fetch_ready),

	.CLK(CLK),
	.RSTn(RSTn)
);





ifetch i_ifetch
(
	.ifu_mstReq_valid,
	.ifu_addr,
	.ifu_data_r,
	.ifu_slvRsp_valid,

	.fetch_addr_qout(fetch_addr_qout),
	.fetch_addr_valid(fetch_addr_valid),
	.pcGen_fetch_ready(pcGen_fetch_ready),

	.fetch_queue_ready(fetch_queue_ready),
	.fetch_pc(fetch_pc),
	.fetch_instr(fetch_instr),
	.fetch_valid(fetch_valid),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)

);




instr_queue i_instr_queue(

	.fetch_pc(fetch_pc),
	.fetch_instr(fetch_instr),
	.fetch_valid(fetch_valid),
	.fetch_queue_ready(fetch_queue_ready),

	.fetch_pc_valid(fetch_pc_valid),
	.fetch_pc_queue(fetch_pc_queue),
	.preDecode_info(preDecode_info),

	.queue_decode_valid(queue_decode_valid),
	.queue_decode_ready(queue_decode_ready),

	.queue_decode_instr(queue_decode_instr),
	.queue_decode_pc(queue_decode_pc),
	.queue_decode_isRVC(queue_decode_isRVC),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);







decoder i_decoder
(
	.queue_decode_valid(queue_decode_valid),
	.queue_decode_ready(queue_decode_ready),

	.queue_decode_instr(queue_decode_instr),
	.queue_decode_pc(queue_decode_pc),
	.queue_decode_isRVC(queue_decode_isRVC),


	.instrFifo_full(instrFifo_full),
	.decode_microInstr(decode_microInstr),
	.instrFifo_push(instrFifo_push)

);


gen_dffr # (.DW(1)) isReset_dffr ( .dnxt(1'b1), .qout(isReset), .CLK(CLK), .RSTn(RSTn));









endmodule






