/*
* @File name: iqueue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-08 20:14:23
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

module iqueue (

	//form ifetch
	input [63:0] if_iq_pc,
	input [63:0] if_iq_instr,
	input if_iq_valid,
	output if_iq_ready,

	//to pcGen
	output iq_pcgen_valid,
	output [70+64-1:0] iq_pcgen_info,

	//to decoder
	output iq_id_valid,
	output [32+64+1-1:0] iq_id_info,
	input iq_id_ready,

	input flush,
	input CLK,
	input RSTn
);


wire [127:0] instr_load;
wire [31:0] pc_load;




// wire [127:0] iq_instr_buf_qout;
// wire [7:0] iq_instr_mask_qout;


assign instr_load = 
{if_iq_instr}
iq_instr_buf_qout 













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



	branch_predict i_branch_predict(
		.isReset(isReset),

		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),
		.isRVC(isRVC),

		.isMisPredict(isMisPredict),
		.isExpection(isExpection),
		.expection_pc(expection_pc),

		.jalr_valid(jalr_valid),
		.jalr_pc(jalr_pc),
		.bru_res_valid(bru_res_valid),
		.bru_takenBranch(bru_takenBranch),

		.fetch_pc_valid(fetch_pc_valid),
		.fetch_pc(fetch_pc_queue),
		.fetch_addr_qout(fetch_addr_qout),
		.fetch_addr_valid(fetch_addr_valid),
		.pcGen_fetch_ready(pcGen_fetch_ready),

		.CLK(CLK),
		.RSTn(RSTn)

	);







wire [32+64+1-1:0] iq_id_info_dnxt;
wire [32+64+1-1:0] iq_id_info_qout;
wire iq_id_valid_dnxt;
wire iq_id_valid_qout;

gen_dffr # (.DW(97)) iq_id_info_dffr ( .dnxt(iq_id_info_dnxt),  .qout(iq_id_info_qout),  .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) iq_id_valid_dffr ( .dnxt(iq_id_valid_dnxt), .qout(iq_id_valid_qout), .CLK(CLK), .RSTn(RSTn));





wire [70+64-1:0] iq_pcgen_info_dnxt;
wire [70+64-1:0] iq_pcgen_info_qout;
wire iq_pcgen_valid_dnxt;
wire iq_pcgen_valid_qout;

gen_dffr # (.DW(134)) iq_pcgen_info_dffr  ( .dnxt(iq_pcgen_info_dnxt),  .qout(iq_pcgen_info_qout),  .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1))   iq_pcgen_valid_dffr ( .dnxt(iq_pcgen_valid_dnxt), .qout(iq_pcgen_valid_qout), .CLK(CLK), .RSTn(RSTn));




wire [127:0] iq_instr_buf_dnxt;
wire [127:0] iq_instr_buf_qout;
wire [7:0] iq_instr_mask_dnxt;
wire [7:0] iq_instr_mask_qout;


gen_dffr # (.DW(128)) iq_instr_buf_dffr ( .dnxt(iq_instr_buf_dnxt),   .qout(iq_instr_buf_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(8))  iq_instr_mask_dffr ( .dnxt(iq_instr_mask_dnxt), .qout(iq_instr_mask_qout), .CLK(CLK), .RSTn(RSTn));


endmodule


