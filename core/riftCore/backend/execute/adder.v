/*
* @File name: adder
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:16:34
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 17:08:05
*/

`include "define.vh"

module adder #
	(
		parameter DW = `ADDER_EXEPARAM_DW 
	)
	(

	input adder_exeparam_vaild,
	input [DW-1:0] adder_exeparam,

	output adder_writeback_vaild,
	output [63:0] adder_res_qout,
	output [(5+`RB)-1:0] adder_rd0_qout,

	input CLK,
	input RSTn
	
);


	wire rv64i_add;
	wire rv64i_sub;

	wire [(5+`RB)-1:0] adder_rd0_dnxt;

	wire  [63:0] op1;
	wire  [63:0] op2;

	wire is32w;


assign { 
			rv64i_add,
			rv64i_sub,

			adder_rd0_dnxt,
			op1,
			op2,

			is32
		} = adder_exeparam;



wire [63:0] adder_op1 = op1;
wire [63:0] adder_op2 = rv64i_sub ? ((~op2) + 64'd1) : op2;

wire [63:0] adder_cal = $unsigned(adder_op1) + $unsigned(adder_op2);
wire [63:0] adder_res_dnxt = is32 ? {{32{adder_cal[31]}}, adder_cal[31:0]} : adder_cal;



gen_dffr # (.DW((5+`RB))) adder_rd0 ( .dnxt(adder_rd0_dnxt), .qout(adder_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) adder_res ( .dnxt(adder_res_dnxt), .qout(adder_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(adder_exeparam_vaild), .qout(adder_writeback_vaild), .CLK(CLK), .RSTn(RSTn));




endmodule



