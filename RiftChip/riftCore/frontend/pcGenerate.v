/*
* @File name: pcGenerate
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-13 16:56:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 17:49:38
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

module pcGenerate (



	input isReset,

	//from jalr exe
	input jalr_valid,
	input [63:0] jalr_pc,
	
	//from bru
	input bru_res_valid,
	input bru_takenBranch,

	// from expection 	
	input [63:0] privileged_pc,
	input privileged_valid,

	//to commit to flush
	output isMisPredict,

	//to fetch
	output [63:0] fetch_pc_qout,
	output [31:0] instr_readout,
	output is_rvc_instr,

	output pcGen_pre_valid,
	input pcGen_pre_ready,



	output ifu_mstReq_valid,
	output [63:0] ifu_addr,
	input [63:0] ifu_data_r,
	input ifu_slvRsp_valid,



	input CLK,
	input RSTn

);

	wire [63:0] fetch_pc_dnxt;

	wire pcGen_fetch_valid;

	wire isExpection = privileged_valid;
	wire [63:0] expection_pc = privileged_pc;


	wire isJal;
	wire isJalr;
	wire isBranch;
	wire isCall;
	wire isReturn;
	wire [63:0] imm;

	wire [63:0] fetch_instr;







	//branch predict
	preDecode i_preDecode(
		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),

		.instr_readout(instr_readout),
		.is_rvc_instr(is_rvc_instr)
	);


	branch_predict i_branch_predict(
		.isReset(isReset),

		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),
		.is_rvc_instr(is_rvc_instr),

		.isMisPredict(isMisPredict),
		.isExpection(isExpection),
		.pcGen_pre_ready(pcGen_pre_ready),
		.fetchBuff_valid(pcGen_pre_valid),
		.expection_pc(expection_pc),

		.jalr_valid(jalr_valid),
		.jalr_pc(jalr_pc),
		.bru_res_valid(bru_res_valid),
		.bru_takenBranch(bru_takenBranch),

		.fetch_pc_qout(fetch_pc_qout),
		.fetch_pc_dnxt(fetch_pc_dnxt),
		.pcGen_fetch_valid(pcGen_fetch_valid),


		.CLK(CLK),
		.RSTn(RSTn)

	);






	ifu i_ifu(

		.ifu_mstReq_valid(ifu_mstReq_valid),
		.ifu_addr(ifu_addr),
		.ifu_data_r(ifu_data_r),
		.ifu_slvRsp_valid(ifu_slvRsp_valid),

		.pcGen_fetch_valid(pcGen_fetch_valid),
		.fetch_pc_dnxt(fetch_pc_dnxt),
		.fetch_pc_qout(fetch_pc_qout),
		.fetch_instr(fetch_instr),
		.fetchBuff_valid(pcGen_pre_valid),
		.pcGen_pre_ready(pcGen_pre_ready),

		.CLK(CLK),
		.RSTn(RSTn)

	);

	wire [31:0] addr_align = fetch_pc_qout[1] ? fetch_instr[47:16] : fetch_instr[31:0];
	assign is_rvc_instr = (addr_align[1:0] != 2'b11);
	assign instr_readout = addr_align;











endmodule










