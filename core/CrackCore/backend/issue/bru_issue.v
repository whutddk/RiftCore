/*
* @File name: bru_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:50:36
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 09:58:43
*/

module bru_issue (
	//from fifo
	output bru_fifo_pop,
	input bru_fifo_empty,
	input [`BRU_ISSUE_INFO_DW-1:0] bru_issue_info,

	//from execute

	// input bru_execute_ready,
	output bru_execute_vaild,
	output [ :0] bru_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout
);

	//bru must be ready
	assign bru_execute_ready = 1'b1;



//对于有条件分支预测，先解决分支也没用，必须等先序指令commit，因此还不如顺序发射

	wire rv64i_beq;
	wire rv64i_bne;
	wire rv64i_blt;
	wire rv64i_bge;
	wire rv64i_bltu;
	wire rv64i_bgeu;

	wire bru_rs1;
	wire bru_rs2;


	wire [63 : 0] src1;
	wire [63 : 0] src2;

	wire  [63:0] op1;
	wire  [63:0] op2;

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


	assign rs1_ready = wbBuf_qout[bru_rs1];
	assign rs2_ready = wbBuf_qout[bru_rs2];

	assign bru_isClearRAW = ( ~bru_fifo_empty ) & 
											 rs1_ready & rs2_ready ;


	assign src1 = regFileX_read[bru_rs1_index]
	assign src2 = regFileX_read[bru_rs2_index]

	assign op1 = src1;
	assign op2 = src2;


	assign bru_execute_info = { 
								rv64i_beq,
								rv64i_bne,
								rv64i_blt,
								rv64i_bge,
								rv64i_bltu,
								rv64i_bgeu,

								op1,
								op2
								};


	assign bru_execute_vaild = bru_isClearRAW;

	assign bru_issue_pop = ( bru_execute_ready & bru_execute_vaild );









endmodule







