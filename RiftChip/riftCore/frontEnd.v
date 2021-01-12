/*
* @File name: frontEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-31 15:42:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-12 14:43:52
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

	output flush,
	input CLK,
	input RSTn
	
);


	wire branch_pc_valid;
	wire [63:0] branch_pc;
	wire [63:0] fetch_addr_qout;
	wire pcGen_fetch_ready;
	wire [63:0] if_iq_pc;
	wire [63:0] if_iq_instr;
	wire if_iq_valid;
	wire if_iq_ready;
	wire iq_id_valid;
	wire [32+64+1-1:0] iq_id_info;
	wire iq_id_ready;
	wire isMisPredict;


	assign flush = isMisPredict | privileged_valid;


pcGenerate i_pcGenerate(
	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

	.branch_pc_valid(branch_pc_valid),
	.branch_pc(branch_pc),

	.fetch_addr_qout(fetch_addr_qout),
	.pcGen_fetch_ready(pcGen_fetch_ready),

	.flush(flush|branch_pc_valid),
	.CLK(CLK),
	.RSTn(RSTn)
);


ifetch i_ifetch(
	.ifu_mstReq_valid(ifu_mstReq_valid),
	.ifu_addr(ifu_addr),
	.ifu_data_r(ifu_data_r),
	.ifu_slvRsp_valid(ifu_slvRsp_valid),

	.fetch_addr_qout(fetch_addr_qout),
	.pcGen_fetch_ready(pcGen_fetch_ready),

	.if_iq_pc(if_iq_pc),
	.if_iq_instr(if_iq_instr),
	.if_iq_valid(if_iq_valid),
	.if_iq_ready(if_iq_ready),

	.flush(flush|branch_pc_valid),
	.CLK(CLK),
	.RSTn(RSTn)
);




iqueue i_iqueue(

	.if_iq_pc(if_iq_pc),
	.if_iq_instr(if_iq_instr),
	.if_iq_valid(if_iq_valid),
	.if_iq_ready(if_iq_ready),

	.branch_pc_valid(branch_pc_valid),
	.branch_pc(branch_pc),

	.jalr_valid(jalr_valid),
	.jalr_pc(jalr_pc),
	.bru_res_valid(bru_res_valid),
	.bru_takenBranch(bru_takenBranch),

	.iq_id_valid(iq_id_valid),
	.iq_id_info(iq_id_info),
	.iq_id_ready(iq_id_ready),

	.isMisPredict(isMisPredict),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);


decoder i_decoder
(
	.iq_id_valid(iq_id_valid),
	.iq_id_ready(iq_id_ready),
	.iq_id_info(iq_id_info),

	.instrFifo_full(instrFifo_full),
	.decode_microInstr(decode_microInstr),
	.instrFifo_push(instrFifo_push),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)

);









endmodule






