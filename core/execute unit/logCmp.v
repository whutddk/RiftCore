/*
* @File name: logCmp
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 14:45:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 16:40:47
*/

//单拍操作，对前不需要握手

module logCmp (


	//from logCmp_issue

	input logCmp_execute_vaild,
	input [ :0] logCmp_execute_info,


	output logCmp_writeback_vaild,
	output [63:0] logCmp_res,
	output [(5+RNBIT-1):0] logCmp_rd0,


);

	

	wire rv64i_xor;
	wire rv64i_or;
	wire rv64i_and;

	wire [(5+RNBIT-1):0] rv64i_rd0,
	wire [63:0] op1,
	wire [63:0] op2,

	wire isUsi;




assign { 

			logCmp_fun_slt,
			logCmp_fun_xor,
			logCmp_fun_or,
			logCmp_fun_and,

			logCmp_rd0,

			op1,
			op2,

			isUsi
		} = logCmp_execute_info;














//逻辑运算XOR OR AND 


wire [63:0] logCmp_logic_xor = op1 ^ op2;
wire [63:0] logCmp_logic_or  = op1 | op2;
wire [63:0] logCmp_logic_and = op1 & op2;

//slti slt [u]

wire [63:0] slt_sign_res = ( $signed(op1) < $signed(op2) ) ? 64'd1 : 64'd0;
wire [63:0] slt_unsign_res = ( $unsigned(op1) < $unsigned(op2) ) ? 64'd1 : 64'd0;
wire [63:0] slt_res = isUsi ? logCmp_slt_unsign_res : logCmp_slt_sign_res;


wire [63:0] logCmp_res =   ( {64{logCmp_fun_slt}} & logCmp_slt_res )
						| ( {64{logCmp_fun_xor}} & logCmp_logic_xor )
						| ( {64{logCmp_fun_or}} & logCmp_logic_or )
						| ( {64{logCmp_fun_and}} & logCmp_logic_and );


endmodule








