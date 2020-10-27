/*
* @File name: alu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 14:45:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 11:55:48
*/

//单拍操作，对前不需要握手

module alu (


	//from alu_issue

	input alu_execute_vaild,
	input [ :0] alu_execute_info,


	output alu_writeback_vaild,
	output [:] alu_writeback_info



);

	wire alu_fun_add;
	wire alu_fun_sub;
	wire alu_fun_slt;
	wire alu_fun_sll;
	wire alu_fun_srl;
	wire alu_fun_sra;
	wire alu_fun_xor;
	wire alu_fun_or;
	wire alu_fun_and;

	wire [(5+RNBIT-1):0] rd0,
	wire  [63:0] op1,
	wire  [63:0] op2,



	wire alu_fun_is32w;
	wire alu_fun_isUsi;




assign { 
			alu_fun_add,
			alu_fun_sub,
			alu_fun_slt,
			alu_fun_sll,
			alu_fun_srl,
			alu_fun_sra,
			alu_fun_xor,
			alu_fun_or,
			alu_fun_and,
			rd0,
			op1,
			op2,
			alu_64n_32,
			alu_fun_isUsi
		} = alu_execute_info;










wire [63:0] alu_adder_op1 = op1;
wire [63:0] alu_adder_op2 = alu_fun_sub ? ((~op2) + 64'd1) : op2;
wire [63:0] alu_adder_cal = $unsigned(alu_adder_op1) + $unsigned(alu_adder_op2);
wire [63:0] alu_adder_res = alu_64n_32 ? {{32{alu_adder_cal[31]}}, alu_adder_cal[31:0]} : alu_adder_cal;



//逻辑运算XOR OR AND 


wire [63:0] alu_logic_xor = op1 ^ op2;
wire [63:0] alu_logic_or  = op1 | op2;
wire [63:0] alu_logic_and = op1 & op2;



//shift SLL SRL SRA

wire [63:0] alu_shiftLeft_op1 = op1;
wire [64:0] alu_shiftRight_op1 = alu_64n_32 ? { {33{(alu_shift_op1[31] & alu_fun_sra)}}, op1[31:0]} 
											: { (alu_shift_op1[63] & alu_fun_sra), op1 };

wire [5:0] shamt = op2[5:0];

wire [63:0] alu_shift_left64 = alu_shiftLeft_op1 << shamt;
wire [63:0] alu_shift_left32 = {32'b0,alu_shift_left[31:0]};

wire [63:0] alu_shift_left  = alu_64n_32 ? alu_shift_left32 : alu_shift_left64;
wire [63:0] alu_shift_right = alu_shiftRight_op1 >>> shamt;

//slti slt [u]

wire [63:0] alu_slt_sign_res = ( $signed(op1) < $signed(op2) ) ? 64'd1 : 64'd0;
wire [63:0] alu_slt_unsign_res = ( $unsigned(op1) < $unsigned(op2) ) ? 64'd1 : 64'd0;
wire [63:0] alu_slt_res = alu_fun_isUsi ? alu_slt_unsign_res : alu_slt_sign_res;


wire [63:0] alu_res =  	({64{alu_fun_add | alu_fun_sub}} & alu_adder_res)
						| ( {64{alu_fun_slt}} & alu_slt_res )
						| ( {64{alu_fun_sll}} & alu_shift_left )
						| ( {64{alu_fun_srl | alu_fun_sra}} & alu_shift_right )
						| ( {64{alu_fun_xor}} & alu_logic_xor )
						| ( {64{alu_fun_or}} & alu_logic_or )
						| ( {64{alu_fun_and}} & alu_logic_and );

assign alu_writeback_info = {alu_res, rd0};

endmodule








