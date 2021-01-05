/*
* @File name: lsu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:21
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:08:25
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

module lsu_issue #
	(
		parameter DW = `LSU_ISSUE_INFO_DW,
		parameter DP = `LSU_ISSUE_INFO_DP,
		parameter EXE_DW = `LSU_EXEPARAM_DW

	)
	(
		output lsu_fifo_pop,
		input lsu_fifo_empty,
		input [DW-1:0] lsu_issue_info,
		
		input lsu_exeparam_ready,
		output lsu_exeparam_valid_qout,
		output [EXE_DW-1:0] lsu_exeparam_qout,

		//from regFile
		input [(64*`RP*32)-1:0] regFileX_read,
		input [32*`RP-1 : 0] wbLog_qout,

		//from commit
		input suILP_ready,

		input flush,
		input CLK,
		input RSTn
);



	wire rv64i_lb;
	wire rv64i_lh;
	wire rv64i_lw;
	wire rv64i_ld;

	wire rv64i_lbu;
	wire rv64i_lhu;
	wire rv64i_lwu;

	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;

	wire rv64zi_fence_i;
	wire rv64i_fence;

	wire [63:0] imm;

	wire [(5+`RB)-1:0] lsu_rd0;
	wire [(5+`RB)-1:0] lsu_rs1;
	wire [(5+`RB)-1:0] lsu_rs2;

	wire rs1_ready;
	wire rs2_ready;

	wire lsu_isClearRAW;

	wire [63:0] op1;
	wire [63:0] op2;




	initial $info("the pervious instruction must be commit then store can execute");

	assign {
			rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
			rv64zi_fence_i, rv64i_fence,
			imm,
			lsu_rd0,
			lsu_rs1,
			lsu_rs2
			} = lsu_issue_info;


	assign rs1_ready = wbLog_qout[lsu_rs1] | ( lsu_rs1[`RB +: 5] == 5'd0 );
	assign rs2_ready = wbLog_qout[lsu_rs2] | ( lsu_rs2[`RB +: 5] == 5'd0 );

	assign lsu_isClearRAW = ( ~lsu_fifo_empty ) & (
													(
														(rv64i_lb | rv64i_lh | rv64i_lw | rv64i_ld | rv64i_lbu | rv64i_lhu | rv64i_lwu)
														& rs1_ready 
													)
													|
													(
														(rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd)
														& rs1_ready & rs2_ready & suILP_ready
													)
													|
													(
														rv64zi_fence_i | rv64i_fence
													)
												);


	assign op1 = regFileX_read[lsu_rs1 * 64 +: 64] + imm;
	assign op2 = regFileX_read[lsu_rs2 * 64 +: 64];


	wire lsu_exeparam_valid_dnxt;
	wire [EXE_DW-1:0] lsu_exeparam_dnxt = flush 
											? {EXE_DW{1'b0}} 
											: (
												lsu_exeparam_valid_dnxt 
													? { 
														rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
														rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
														rv64zi_fence_i, rv64i_fence,
														lsu_rd0,
														op1,
														op2
														}
													: lsu_exeparam_qout
												);

	assign lsu_exeparam_valid_dnxt = flush ? 1'b0 : (lsu_exeparam_ready & lsu_isClearRAW );
	assign lsu_fifo_pop = lsu_exeparam_ready & lsu_exeparam_valid_dnxt;


	gen_dffr # (.DW(EXE_DW)) lsu_exeparam ( .dnxt(lsu_exeparam_dnxt), .qout(lsu_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) lsu_exeparam_valid ( .dnxt(lsu_exeparam_valid_dnxt), .qout(lsu_exeparam_valid_qout), .CLK(CLK), .RSTn(RSTn));




































// assign fence_dispat = (rv64zi_fence_i | rv64i_fence) & dispat_valid 
// 							& ~(fencing);

// 	initial $warning("暂不支持TSO,暂不区分io和memory");
// 	initial $warning("在派遣阶段做fence将会导致其它计算指令一同被fence");

// 	wire [3:0] predecessor = imm[7:4];
// 	wire [3:0] successor = imm[3:0];

// 	wire fenceS = (successor & 4'b0100) || (successor & 4'b0001);
// 	wire fenceL = (successor & 4'b1000) || (successor & 4'b0010);
// 	wire afterS = (predecessor & 4'b0100) || (predecessor & 4'b0001);
// 	wire afterL = (predecessor & 4'b1000) || (predecessor & 4'b0010);

// 	wire fence_SAS = rv64i_fence & fenceS & afterS;
// 	wire fence_SAL = rv64i_fence & fenceS & afterL;
// 	wire fence_LAS = rv64i_fence & fenceL & afterS;
// 	wire fence_LAL = rv64i_fence & fenceL & afterL;
// 	wire fence_ALL = rv64zi_fence_i;

	// wire fence_lu_dispat = ~( fence_LAS & ~su_fifo_empty )
	// 						&
	// 						~( fence_LAL & (| lu_buffer_malloc) )
	// 						& 
	// 						~( fence_ALL & ~su_fifo_empty & (| lu_buffer_malloc) );

	// wire fence_su_dispat = ~(fence_SAS & ~su_fifo_empty)
	// 						&
	// 						~(fence_SAL & (| lu_buffer_malloc))
	// 						&
	// 						~(fence_ALL & ~su_fifo_empty & (|lu_buffer_malloc) );

	// wire fencing = ( fence_LAS & ~su_fifo_empty ) 
	// 				| ( fence_LAL & (| lu_buffer_malloc) )
	// 				| (fence_SAS & ~su_fifo_empty)
	// 				| (fence_SAL & (| lu_buffer_malloc))
	// 				| (fence_ALL & ~su_fifo_empty & (|lu_buffer_malloc) );















endmodule
