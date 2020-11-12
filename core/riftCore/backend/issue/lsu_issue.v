/*
* @File name: lsu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:21
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-11 22:26:26
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

module lsu_issue #
	(
		parameter LU_DW = `LU_ISSUE_INFO_DW,
		parameter LU_DP = `LU_ISSUE_INFO_DP,
		parameter LU_EXE_DW = `LU_EXEPARAM_DW,
		parameter SU_DW = `SU_ISSUE_INFO_DW,
		parameter SU_EXE_DW = `SU_EXEPARAM_DW
	)
	(

		//read 可以乱序
		output lu_buffer_pop,
		output [$clog2(LU_DP)-1:0] lu_buffer_pop_index,
		input [LU_DP-1:0] lu_buffer_malloc,
		input [LU_DW*LU_DP-1 : 0] lu_issue_info,

		input lu_exeparam_ready,
		output lu_exeparam_vaild_qout,
		output [LU_EXE_DW-1:0] lu_exeparam_qout,

		//write 暂时只能顺序
		output su_fifo_pop,
		input su_fifo_empty,
		input [SU_DW-1:0] su_issue_info,
		
		input su_exeparam_ready,
		output su_exeparam_vaild_qout,
		output [SU_EXE_DW-1:0] su_exeparam_qout,

		//from regFile
		input [(64*`RP*32)-1:0] regFileX_read,
		input [32*`RP-1 : 0] wbLog_qout,

		//from commit
		input suILP_ready,

		input flush,
		input CLK,
		input RSTn
);







// LLLLLLLLLLL            UUUUUUUU     UUUUUUUU
// L:::::::::L            U::::::U     U::::::U
// L:::::::::L            U::::::U     U::::::U
// LL:::::::LL            UU:::::U     U:::::UU
//   L:::::L               U:::::U     U:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L         LLLLLLU::::::U   U::::::U 
// LL:::::::LLLLLLLLL:::::LU:::::::UUU:::::::U 
// L::::::::::::::::::::::L UU:::::::::::::UU  
// L::::::::::::::::::::::L   UU:::::::::UU    
// LLLLLLLLLLLLLLLLLLLLLLLL     UUUUUUUUU      





	wire [LU_DP-1:0] rv64i_lb;
	wire [LU_DP-1:0] rv64i_lh;
	wire [LU_DP-1:0] rv64i_lw;
	wire [LU_DP-1:0] rv64i_ld;

	wire [LU_DP-1:0] rv64i_lbu;
	wire [LU_DP-1:0] rv64i_lhu;
	wire [LU_DP-1:0] rv64i_lwu;


	wire [64*LU_DP-1:0] lu_imm;

	wire [(5+`RB)*LU_DP-1:0] lu_rd0;
	wire [(5+`RB)*LU_DP-1:0] lu_rs1;

	wire [LU_DP-1:0] lu_rs1_ready;
	wire [LU_DP-1:0] lu_isClearRAW;

	wire [LU_DP-1:0] lu_fun_lb;
	wire [LU_DP-1:0] lu_fun_lh;
	wire [LU_DP-1:0] lu_fun_lw;
	wire [LU_DP-1:0] lu_fun_ld;

	wire [64*LU_DP-1:0] lu_op1;

	wire [LU_DP-1:0] lu_isUsi;

generate
	for ( genvar i = 0; i < LU_DP; i = i + 1 ) begin

		assign { 
				rv64i_lb[i], rv64i_lh[i], rv64i_lw[i], rv64i_ld[i], rv64i_lbu[i], rv64i_lhu[i], rv64i_lwu[i], 
				lu_imm[64*i +: 64],
				lu_rd0[(5+`RB)*i +: (5+`RB)],
				lu_rs1[(5+`RB)*i +: (5+`RB)]
				} = lu_issue_info[LU_DW*i +: LU_DW];

		assign lu_rs1_ready[i] = wbLog_qout[lu_rs1[(5+`RB)*i +: (5+`RB)]] | (lu_rs1[(5+`RB)*i+`RB +: 5] == 5'd0);

		assign lu_isClearRAW[i] = lu_buffer_malloc[i] & lu_rs1_ready[i];


		assign lu_fun_lb[i] = rv64i_lb[i] | rv64i_lbu[i];
		assign lu_fun_lh[i] = rv64i_lh[i] | rv64i_lhu[i];
		assign lu_fun_lw[i] = rv64i_lw[i] | rv64i_lwu[i];
		assign lu_fun_ld[i] = rv64i_ld[i];



		assign lu_op1[64*i +:64] = regFileX_read[lu_rs1[(5+`RB)*i +: (5+`RB)]*64 +: 64] + lu_imm[64*i +: 64];

		assign lu_isUsi[i] = rv64i_lbu[i] | rv64i_lhu[i] | rv64i_lwu[i];

	end
endgenerate




wire lu_all_RAW;

	lzp #(
		.CW($clog2(LU_DP))
	) lu_RAWClear(
		.in_i(~lu_isClearRAW),
		.pos_o(lu_buffer_pop_index),
		.all1(lu_all_RAW),
		.all0()
	);


	wire [LU_EXE_DW-1:0] lu_exeparam_dnxt = flush ? {LU_EXE_DW{1'b0}} : { 
								lu_fun_lb[lu_buffer_pop_index],
								lu_fun_lh[lu_buffer_pop_index],
								lu_fun_lw[lu_buffer_pop_index],
								lu_fun_ld[lu_buffer_pop_index],

								lu_rd0[(5+`RB)*lu_buffer_pop_index +: (5+`RB)],
								lu_op1[ 64*lu_buffer_pop_index +:64 ],

								lu_isUsi[ lu_buffer_pop_index ]

								};

	wire lu_exeparam_vaild_dnxt = flush ? 1'b0 : (lu_exeparam_ready ? ~lu_all_RAW : lu_exeparam_vaild_qout);


	assign lu_buffer_pop = ( lu_exeparam_ready & lu_exeparam_vaild_dnxt );


gen_dffr # (.DW(LU_EXE_DW)) lu_exeparam ( .dnxt(lu_exeparam_dnxt), .qout(lu_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) lu_exeparam_vaild ( .dnxt(lu_exeparam_vaild_dnxt), .qout(lu_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));










//    SSSSSSSSSSSSSSS UUUUUUUU     UUUUUUUU
//  SS:::::::::::::::SU::::::U     U::::::U
// S:::::SSSSSS::::::SU::::::U     U::::::U
// S:::::S     SSSSSSSUU:::::U     U:::::UU
// S:::::S             U:::::U     U:::::U 
// S:::::S             U:::::D     D:::::U 
//  S::::SSSS          U:::::D     D:::::U 
//   SS::::::SSSSS     U:::::D     D:::::U 
//     SSS::::::::SS   U:::::D     D:::::U 
//        SSSSSS::::S  U:::::D     D:::::U 
//             S:::::S U:::::D     D:::::U 
//             S:::::S U::::::U   U::::::U 
// SSSSSSS     S:::::S U:::::::UUU:::::::U 
// S::::::SSSSSS:::::S  UU:::::::::::::UU  
// S:::::::::::::::SS     UU:::::::::UU    
//  SSSSSSSSSSSSSSS         UUUUUUUUU      








initial $info("写存储器必须保证前序指令已经commit，本指令不会被撤销，需要从commit处顺序fifo跟踪");

	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;


	wire su_rs1_ready;
	wire su_rs2_ready;

	wire [63:0] su_imm;

	wire [5+`RB-1:0] su_rd0;
	wire [5+`RB-1:0] su_rs1;
	wire [5+`RB-1:0] su_rs2;

	wire su_isClearRAW;

	wire [63:0] su_op1;
	wire [63:0] su_op2;

	assign {
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
			su_imm,
			su_rd0,
			su_rs1,
			su_rs2

			} = su_issue_info;


	assign su_rs1_ready = wbLog_qout[su_rs1] | ( su_rs1[`RB +: 5] == 5'd0 );
	assign su_rs2_ready = wbLog_qout[su_rs2] | ( su_rs2[`RB +: 5] == 5'd0 );

	assign su_isClearRAW = ( ~su_fifo_empty ) & 
											 su_rs1_ready & su_rs2_ready ;


	assign su_op1 = regFileX_read[su_rs1 * 64 +: 64] + su_imm;
	assign su_op2 = regFileX_read[su_rs2 * 64 +: 64];




	wire su_exeparam_vaild_dnxt;
	wire [SU_EXE_DW-1:0] su_exeparam_dnxt = flush ? {SU_EXE_DW{1'b0}} : su_exeparam_vaild_dnxt ? { 
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
								su_rd0,
								su_op1,
								su_op2
								}
								: su_exeparam_qout;

	assign su_exeparam_vaild_dnxt = flush ? 1'b0 : (su_exeparam_ready & su_isClearRAW & suILP_ready);

	assign su_fifo_pop = su_exeparam_vaild_dnxt;


gen_dffr # (.DW(SU_EXE_DW)) su_exeparam ( .dnxt(su_exeparam_dnxt), .qout(su_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) su_exeparam_vaild ( .dnxt(su_exeparam_vaild_dnxt), .qout(su_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));



endmodule
