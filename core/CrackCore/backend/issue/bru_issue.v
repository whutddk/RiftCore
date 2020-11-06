/*
* @File name: bru_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:50:36
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-06 18:10:38
*/

`include "define.vh"

module bru_issue #
	(
		parameter DW = `BRU_ISSUE_INFO_DW,
		parameter EXE_DW = `BRU_EXEPARAM_DW
	)
	(

	//from fifo
	output bru_fifo_pop,
	input bru_fifo_empty,
	input [DW-1:0] bru_issue_info,

	//from execute

	input bru_exeparam_ready,
	output bru_exeparam_vaild_qout,
	output [EXE_DW-1:0] bru_exeparam_qout,

	//from regFile
	input [(64*`RP*32)-1:0] regFileX_read,
	input [32*`RP-1 : 0] wbLog_qout,

	input CLK,
	input RSTn
);



	wire rv64i_beq;
	wire rv64i_bne;
	wire rv64i_blt;
	wire rv64i_bge;
	wire rv64i_bltu;
	wire rv64i_bgeu;

	wire [5+`RB-1:0] bru_rs1;
	wire [5+`RB-1:0] bru_rs2;


	wire [63:0] src1;
	wire [63:0] src2;

	wire [63:0] op1;
	wire [63:0] op2;

	assign {
				rv64i_beq,
				rv64i_bne,
				rv64i_blt,
				rv64i_bge,
				rv64i_bltu,
				rv64i_bgeu,

				bru_rs1,
				bru_rs2
			} = bru_issue_info;


	wire temp1 = wbLog_qout[bru_rs1];
	wire temp2 = wbLog_qout[bru_rs2];
	wire [4:0] temp3 = bru_rs1[`RB +: 5];
	wire [4:0] temp4 = bru_rs2[`RB +: 5];

	wire rs1_ready = wbLog_qout[bru_rs1] | (bru_rs1[`RB +: 5] == 5'd0);
	wire rs2_ready = wbLog_qout[bru_rs2] | (bru_rs2[`RB +: 5] == 5'd0);

	wire bru_isClearRAW = ( ~bru_fifo_empty ) & 
											 rs1_ready & rs2_ready;


	assign src1 = regFileX_read[bru_rs1];
	assign src2 = regFileX_read[bru_rs2];

	assign op1 = src1;
	assign op2 = src2;


	wire [EXE_DW-1:0] bru_exeparam_dnxt =  bru_exeparam_ready ? { 
								rv64i_beq,
								rv64i_bne,
								rv64i_blt,
								rv64i_bge,
								rv64i_bltu,
								rv64i_bgeu,

								op1,
								op2
								}
								: bru_exeparam_qout
								;

	wire bru_exeparam_vaild_dnxt = bru_isClearRAW;

	assign bru_fifo_pop = ( bru_exeparam_ready & bru_exeparam_vaild_dnxt );





	gen_dffr # (.DW(EXE_DW)) bru_exeparam ( .dnxt(bru_exeparam_dnxt), .qout(bru_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) bru_exeparam_vaild ( .dnxt(bru_exeparam_vaild_dnxt), .qout(bru_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));






endmodule







