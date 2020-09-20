/*
* @File name: alu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 14:45:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-20 16:40:46
*/


module alu (


	input alu_alu_add,
	input alu_alu_addw,
	input alu_alu_sub,
	input alu_alu_subw,

	input alu_alu_xor,
	input alu_alu_sll,
	input alu_alu_sllw,
	input alu_alu_srl,
	input alu_alu_srlw,
	input alu_alu_sra,
	input alu_alu_sraw,
	input alu_alu_or,
	input alu_alu_and,
	input alu_alu_slt,
	input alu_alu_sltu,
	input alu_alu_lui,


	input  [63:0] op1,
	input  [63:0] op2,
	input [5:0] shamt,



	output [63:0] result

);

wire alu_64n_32 = ;

//加减法 ADD SUB
wire alu_addn_sub = ;



wire [63:0] alu_adder_op1 = op1;
wire [63:0] alu_adder_op2 = alu_addn_sub ? ((~op2) + 64'd1) : op2;
wire [63:0] alu_adder_cal = $unsigned(alu_adder_op1) + $unsigned(alu_adder_op2);
wire [63:0] alu_adder_res = alu_64n_32 ? {{32{alu_adder_cal[31]}}, alu_adder_cal[31:0]} : alu_adder_cal;



//逻辑运算XOR OR AND 

wire [63:0] alu_logic_op1 = op1;
wire [63:0] alu_logic_op2 = op2;
wire [63:0] alu_logic_xor = op1 ^ op2;
wire [63:0] alu_logic_or  = op1 | op2;
wire [63:0] alu_logic_and = op1 & op2;



//shift SLL SRL SRA

wire alu_shift_32 = 
wire alu_shift_arith = 


wire [63:0] alu_shiftLeft_op1 = op1;
wire [64:0] alu_shiftRight_op1 = alu_shift_32 ? { {33{(alu_shift_op1[31] & alu_shift_arith)}}, op1[31:0]} 
											: { (alu_shift_op1[63] & alu_shift_arith), op1 };

wire [5:0] alu_shift_shamt = shamt;


wire [63:0] alu_shift_left64 = alu_shiftLeft_op1 << shamt;
wire [63:0] alu_shift_left32 = {32'b0,alu_shift_left[31:0]};



wire [63:0] alu_shift_left  = alu_shift_32 ? alu_shift_left32 : alu_shift_left64;
wire [63:0] alu_shift_right = alu_shiftRight_op1 >>> shamt;


// 



endmodule








