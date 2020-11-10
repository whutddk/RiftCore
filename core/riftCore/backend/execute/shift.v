/*
* @File name: shift
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:10:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 11:55:39
*/
`timescale 1 ns / 1 ps
`include "define.vh"

module shift #
	(
		parameter DW = `SHIFT_EXEPARAM_DW
	)
	(
		input shift_exeparam_vaild,
		input [DW-1:0] shift_exeparam,

		output shift_writeback_vaild,
		output [63:0] shift_res_qout,
		output [(5+`RB-1):0] shift_rd0_qout,

		input flush,
		input CLK,
		input RSTn
);


	wire rv64i_slt;
	wire rv64i_sll;
	wire rv64i_srl;
	wire rv64i_sra;

	wire [(5+`RB-1):0] shift_rd0_dnxt;
	wire  [63:0] op1;
	wire  [63:0] op2;

	wire is32w;



assign { 	rv64i_sll,
			rv64i_srl,
			rv64i_sra,

			shift_rd0_dnxt,
			op1,
			op2,

			is32w
		} = shift_exeparam;



	//shift SLL SRL SRA

	wire [63:0] shiftLeft_op1 = op1;
	wire [64:0] shiftRight_op1 = is32w ? { {33{(op1[31] & rv64i_sra)}}, op1[31:0]} 
												: { (op1[63] & rv64i_sra), op1 };

	wire [5:0] shamt = op2[5:0];

	wire [63:0] shift_left64 = shiftLeft_op1 << shamt;
	wire [63:0] shift_left32 = {32'b0,shift_left64[31:0]};

	wire [63:0] shift_left  = is32w ? shift_left32 : shift_left64;
	wire [63:0] shift_right = shiftRight_op1 >>> shamt;


	wire [63:0] shift_res_dnxt =  ( {64{rv64i_sll}} & shift_left )
								| ( {64{rv64i_srl | rv64i_sra}} & shift_right );


gen_dffr # (.DW((5+`RB))) shift_rd0 ( .dnxt(shift_rd0_dnxt), .qout(shift_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) shift_res ( .dnxt(shift_res_dnxt), .qout(shift_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(shift_exeparam_vaild&(~flush)), .qout(shift_writeback_vaild), .CLK(CLK), .RSTn(RSTn));


endmodule




