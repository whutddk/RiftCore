/*
* @File name: shift_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 17:44:52
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

module shift_issue #
	(
		parameter DW = `SHIFT_ISSUE_INFO_DW,
		parameter DP = `SHIFT_ISSUE_INFO_DP,
		parameter EXE_DW = `SHIFT_EXEPARAM_DW
	)
	(
	
	//from buffer
	output shift_buffer_pop,
	output [$clog2(DP)-1:0] shift_buffer_pop_index,
	input [DP-1:0] shift_buffer_malloc,
	input [DW*DP-1 : 0] shift_issue_info,

	//from execute

	output shift_exeparam_vaild_qout,
	output [EXE_DW-1:0] shift_exeparam_qout,

	//from regFile
	input [(64*`RP*32)-1:0] regFileX_read,
	input [32*`RP-1 : 0] wbLog_qout,

	input flush,
	input CLK,
	input RSTn
);


	//shift must be ready
	wire shift_exeparam_ready = 1'b1;



	wire [DP-1:0] rv64i_slli;
	wire [DP-1:0] rv64i_slliw;
	wire [DP-1:0] rv64i_srli;
	wire [DP-1:0] rv64i_srliw;
	wire [DP-1:0] rv64i_srai;
	wire [DP-1:0] rv64i_sraiw;
	wire [DP-1:0] rv64i_sll;
	wire [DP-1:0] rv64i_sllw;
	wire [DP-1:0] rv64i_srl;
	wire [DP-1:0] rv64i_srlw;
	wire [DP-1:0] rv64i_sra;
	wire [DP-1:0] rv64i_sraw;


	wire [64*DP-1:0] shift_pc;
	wire [6*DP-1:0] shift_shamt;

	wire [(5+`RB)*DP-1:0] shift_rd0;
	wire [(5+`RB)*DP-1:0] shift_rs1;
	wire [(5+`RB)*DP-1:0] shift_rs2;

	wire [DP-1:0] rs1_ready;
	wire [DP-1:0] rs2_ready;

	wire [DP-1:0] shift_isClearRAW;

	wire [DP-1:0] shift_fun_sll;
	wire [DP-1:0] shift_fun_srl;
	wire [DP-1:0] shift_fun_sra;

	wire [64*DP-1:0] src1;
	wire [64*DP-1:0] src2;

	wire  [64*DP-1:0] op1;
	wire  [64*DP-1:0] op2;

	wire [DP-1:0] is32;

generate
	for ( genvar i = 0; i < DP; i = i + 1 ) begin

		assign { 
				rv64i_slli[i], rv64i_slliw[i], rv64i_sll[i], rv64i_sllw[i],
				rv64i_srli[i], rv64i_srliw[i], rv64i_srl[i], rv64i_srlw[i],
				rv64i_srai[i], rv64i_sraiw[i], rv64i_sra[i], rv64i_sraw[i], 
				
				shift_pc[64*i +: 64], shift_shamt[6*i +: 6], 
				shift_rd0[(5+`RB)*i +: (5+`RB)], 
				shift_rs1[(5+`RB)*i +: (5+`RB)], 
				shift_rs2[(5+`RB)*i +: (5+`RB)]
				} = shift_issue_info[DW*i +: DW];

		assign rs1_ready[i] = wbLog_qout[shift_rs1[(5+`RB)*i +: (5+`RB)]] | (shift_rs1[(5+`RB)*i+`RB +: 5] == 5'd0);
		assign rs2_ready[i] = wbLog_qout[shift_rs2[(5+`RB)*i +: (5+`RB)]] | (shift_rs2[(5+`RB)*i+`RB +: 5] == 5'd0);
		

		assign shift_isClearRAW[i] = 	( shift_buffer_malloc[i] ) & 
										(
										  ( rv64i_slli[i] & rs1_ready[i] )
										| ( rv64i_slliw[i] & rs1_ready[i] )
										| ( rv64i_sll[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_sllw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_srli[i] & rs1_ready[i] )
										| ( rv64i_srliw[i] & rs1_ready[i] )
										| ( rv64i_srl[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_srlw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_srai[i] & rs1_ready[i] )
										| ( rv64i_sraiw[i] & rs1_ready[i] )
										| ( rv64i_sra[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_sraw[i] & rs1_ready[i] & rs2_ready[i] )

										
									);

		assign shift_fun_sll[i] = rv64i_slli[i] | rv64i_slliw[i] | rv64i_sll[i] | rv64i_sllw[i];
		assign shift_fun_srl[i] = rv64i_srli[i] | rv64i_srliw[i] | rv64i_srl[i] | rv64i_srlw[i];
		assign shift_fun_sra[i] = rv64i_srai[i] | rv64i_sraiw[i] | rv64i_sra[i] | rv64i_sraw[i];


		assign src1[64*i +: 64] = regFileX_read[shift_rs1[(5+`RB)*i +: (5+`RB)]*64 +: 64];
		assign src2[64*i +: 64] = regFileX_read[shift_rs2[(5+`RB)*i +: (5+`RB)]*64 +: 64];

		assign op1[64*i +:64] = ( {64{rv64i_slli[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_slliw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sll[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sllw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_srli[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srliw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srl[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srlw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_srai[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sraiw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sra[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sraw[i]}} & src1[64*i +: 64] );

		assign op2[64*i +:64] = ( {64{rv64i_slli[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_slliw[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_sll[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_sllw[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_srli[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_srliw[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_srl[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_srlw[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_srai[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_sraiw[i]}} & { 59'b0, shift_shamt[6*i +: 6]} )
								| ( {64{rv64i_sra[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_sraw[i]}} & src2[64*i +: 64] );


		assign is32[i] = rv64i_slliw[i]
								| rv64i_sllw[i]
								| rv64i_srliw[i]
								| rv64i_srlw[i]
								| rv64i_sraiw[i]
								| rv64i_sraw[i];



	end
endgenerate


	wire shift_all_RAW;

	lzp #(
		.CW($clog2(DP))
	) shift_RAWClear(
		.in_i(~shift_isClearRAW),
		.pos_o(shift_buffer_pop_index),
		.all1(shift_all_RAW),
		.all0()
	);

	wire shift_exeparam_vaild_dnxt;
	wire [EXE_DW-1:0] shift_exeparam_dnxt = flush ? {EXE_DW{1'b0}} : 
								(shift_exeparam_vaild_dnxt ? { 
								shift_fun_sll[ shift_buffer_pop_index ],
								shift_fun_srl[ shift_buffer_pop_index ],
								shift_fun_sra[ shift_buffer_pop_index ],

								shift_rd0[(5+`RB)*shift_buffer_pop_index +: (5+`RB)],
								op1[ 64*shift_buffer_pop_index +:64 ],
								op2[ 64*shift_buffer_pop_index +:64 ],
								is32[ shift_buffer_pop_index ]

								}
								: shift_exeparam_qout);

	assign shift_exeparam_vaild_dnxt = flush ? 1'b0 : (shift_exeparam_ready & ~shift_all_RAW);


	assign shift_buffer_pop = shift_exeparam_vaild_dnxt;


	gen_dffr # (.DW(EXE_DW)) shift_exeparam ( .dnxt(shift_exeparam_dnxt), .qout(shift_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) shift_exeparam_vaild ( .dnxt(shift_exeparam_vaild_dnxt), .qout(shift_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));































endmodule
