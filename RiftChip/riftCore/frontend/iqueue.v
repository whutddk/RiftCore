/*
* @File name: iqueue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-11 14:40:55
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
	output branch_pc_valid,
	output [63:0] branch_pc,

	//to decoder
	output iq_id_valid,
	output [32+64+1-1:0] iq_id_info,
	input iq_id_ready,

	input flush,
	input CLK,
	input RSTn
);


	wire [127:0] instr_load;
	wire [15:0] iq_instr_mask_load;

	wire [31:0] pc_load;

	wire [63:0] align_instr;
	wire [3:0] align_instr_mask;

	wire instr_buf_empty;

	wire iq_stall;
	wire bp_stall;


	iAlign i_align(

		.if_iq_pc(if_iq_pc),
		.if_iq_instr(if_iq_instr),

		.align_instr(align_instr),
		.align_instr_mask(align_instr_mask)

	);




	//if un-align onlu happen when flush,but will also check
	assign instr_load = 
			({128{iq_instr_mask_qout == 16'b0}} & {64'b0, (if_iq_valid ? align_instr : 64'b0) })
			|
			({128{iq_instr_mask_qout == 16'b1}} & {48'b0, (if_iq_valid ? align_instr : 64'b0), iq_instr_buf_qout[15:0]})
			|
			({128{iq_instr_mask_qout == 16'b11}} & {32'b0, (if_iq_valid ? align_instr : 64'b0), iq_instr_buf_qout[31:0]})
			|
			({128{iq_instr_mask_qout == 16'b111}} & {16'b0, (if_iq_valid ? align_instr : 64'b0), iq_instr_buf_qout[47:0]})
			|
			({128{iq_instr_mask_qout == 16'b1111}} & { (if_iq_valid ? align_instr : 64'b0), iq_instr_buf_qout[63:0]})
			|
			({128{iq_instr_mask_qout == 16'b11111}} & { 48'b0, iq_instr_buf_qout[79:0]})
			|
			({128{iq_instr_mask_qout == 16'b111111}} & { 32'b0, iq_instr_buf_qout[95:0]})
			|
			({128{iq_instr_mask_qout == 16'b1111111}} & { 16'b0, iq_instr_buf_qout[111:0]})
			|
			({128{iq_instr_mask_qout == 16'b11111111}} &  iq_instr_buf_qout[127:0]);


	//only when iq_instr_buf is empty (flush) can iq use new pc fetch
	assign pc_load = (iq_instr_mask_qout == 16'b0 & if_iq_valid) ? if_iq_pc : iq_pc_buf_qout;
	assign iq_instr_mask_load = 
			({8{iq_instr_mask_qout == 8'b0}} & (if_iq_valid ? align_instr_mask : 8'b0 ) )
			|
			({8{iq_instr_mask_qout == 8'b1}} & (if_iq_valid ? align_instr_mask : 8'b1 ) )
			|
			({8{iq_instr_mask_qout == 8'b11}} & (if_iq_valid ? align_instr_mask : 8'b11 ) )
			|
			({8{iq_instr_mask_qout == 8'b111}} & (if_iq_valid ? align_instr_mask : 8'b111 ) )
			|
			({8{iq_instr_mask_qout == 8'b1111}} & (if_iq_valid ? align_instr_mask : 8'b1111 ) )
			|
			({8{iq_instr_mask_qout == 8'b11111}} & 8'b11111 )
			|
			({8{iq_instr_mask_qout == 8'b111111}} & 8'b111111 )
			|
			({8{iq_instr_mask_qout == 8'b1111111}} & 8'b1111111 )
			|
			({8{iq_instr_mask_qout == 8'b11111111}} & 8'b11111111 );

	

	assign if_iq_ready = if_iq_valid & (iq_instr_mask_qout[7:4] == 4'b0000);







	wire isJal, isJalr, isBranch, isCall, isReturn, isRVC;
	wire [63:0] imm;

	//branch predict
	preDecode i_preDecode(
		.instr(instr_load),

		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.isRVC(isRVC),
		.imm(imm)
	);

	assign instr_buf_empty = ((iq_instr_mask_load[1:0] != 2'b11) & ~isRVC)
							|
							((iq_instr_mask_load[0] != 1'b1) & isRVC);

	branch_predict i_branch_predict(

		.isJal(isJal),
		.isJalr(isJalr),
		.isBranch(isBranch),
		.isCall(isCall),
		.isReturn(isReturn),
		.imm(imm),
		.isRVC(isRVC),
		.pc_load(pc_load),

		.jalr_valid(jalr_valid),
		.jalr_pc(jalr_pc),
		.bru_res_valid(bru_res_valid),
		.bru_takenBranch(bru_takenBranch),


		.branch_pc_valid(branch_pc_valid),
		.branch_pc(branch_pc),
		.isMisPredict(isMisPredict),

		.stall(bp_stall),

		.flush(flush),
		.CLK(CLK),
		.RSTn(RSTn)

	);


wire [127:0] iq_instr_buf_shift = instr_load >> (~isRVC ? 32 : 16);
wire [63:0] iq_pc_buf_shift = pc_load + (~isRVC ? 64'd4 : 64'd2) ;
wire [7:0] iq_instr_mask_shift =  iq_instr_mask_load >> (~isRVC ? 2 : 1);

assign iq_stall = bp_stall | ~iq_id_ready | instr_buf_empty;


assign iq_instr_buf_dnxt = (~iq_stall) ? iq_instr_buf_shift : instr_load ;
assign iq_pc_buf_dnxt = (~iq_stall) ? iq_pc_buf_shift : pc_load;
assign iq_instr_mask_dnxt = (~iq_stall) ? iq_instr_mask_shift : iq_instr_mask_load;



















wire [32+64+1-1:0] iq_id_info_dnxt;
wire [32+64+1-1:0] iq_id_info_qout;
wire iq_id_valid_dnxt;
wire iq_id_valid_qout;

assign iq_id_info_dnxt = {instr_load[31:0], pc_load, isRVC};
assign iq_id_valid_dnxt =  (~iq_stall) ;
gen_dffr # (.DW(97)) iq_id_info_dffr ( .dnxt(iq_id_info_dnxt),  .qout(iq_id_info_qout),  .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) iq_id_valid_dffr ( .dnxt(iq_id_valid_dnxt), .qout(iq_id_valid_qout), .CLK(CLK), .RSTn(RSTn));





// wire [70+64-1:0] iq_pcgen_info_dnxt;
// wire [70+64-1:0] iq_pcgen_info_qout;
// wire iq_pcgen_valid_dnxt;
// wire iq_pcgen_valid_qout;

// gen_dffr # (.DW(134)) iq_pcgen_info_dffr  ( .dnxt(iq_pcgen_info_dnxt),  .qout(iq_pcgen_info_qout),  .CLK(CLK), .RSTn(RSTn));
// gen_dffr # (.DW(1))   iq_pcgen_valid_dffr ( .dnxt(iq_pcgen_valid_dnxt), .qout(iq_pcgen_valid_qout), .CLK(CLK), .RSTn(RSTn));




wire [127:0] iq_instr_buf_dnxt;
wire [127:0] iq_instr_buf_qout;
wire [31:0] iq_pc_buf_dnxt;
wire [31:0] iq_pc_buf_qout;
wire [7:0] iq_instr_mask_dnxt;
wire [7:0] iq_instr_mask_qout;


gen_dffr # (.DW(128)) iq_instr_buf_dffr ( .dnxt(iq_instr_buf_dnxt),   .qout(iq_instr_buf_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(32))  iq_pc_buf_dffr    ( .dnxt(iq_pc_buf_dnxt),      .qout(iq_pc_buf_qout),    .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(8))  iq_instr_mask_dffr ( .dnxt(iq_instr_mask_dnxt), .qout(iq_instr_mask_qout), .CLK(CLK), .RSTn(RSTn));










// always @(posedge CLK) begin
// 	if (iq_instr_mask_qout > 16'b1111 & if_iq_valid) begin
// 		$display("Assert Fail at iq, buf not enough big when fetch comes");
// 		$finish;
// 	end
// end




endmodule


