/*
* @File name: adder
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:16:34
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 17:00:12
*/

module adder (

	input adder_execute_vaild,
	input [ :0] adder_execute_info,


	output adder_writeback_vaild,
	output [63:0] adder_res,
	output [(5+RNBIT-1):0] adder_rd0,
	
);


	wire rv64i_add;
	wire rv64i_sub;

	wire [(5+RNBIT-1):0] alu_rd0,
	wire  [63:0] op1,
	wire  [63:0] op2,



	wire is32w;


assign { 
			rv64i_add,
			rv64i_sub,

			alu_rd0,
			op1,
			op2,

			is32
		} = alu_execute_info;



wire [63:0] alu_adder_op1 = op1;
wire [63:0] alu_adder_op2 = alu_fun_sub ? ((~op2) + 64'd1) : op2;
wire [63:0] alu_adder_cal = $unsigned(alu_adder_op1) + $unsigned(alu_adder_op2);
wire [63:0] alu_adder_res = alu_64n_32 ? {{32{alu_adder_cal[31]}}, alu_adder_cal[31:0]} : alu_adder_cal;

wire [63:0] alu_res = ({64{alu_fun_add | alu_fun_sub}} & alu_adder_res);




endmodule



