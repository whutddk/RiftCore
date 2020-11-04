/*
* @File name: shift
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:10:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 12:05:32
*/


module shift (
	input shift_exeparam_vaild,
	input [`SHIFT_EXEPARAM_DW-1:0] shift_exeparam,

	output shift_writeback_vaild,
	output [63:0] shift_res_qout,
	output [(5+RNBIT-1):0] shift_rd0_qout,

	input CLK,
	input RSTn
);


	wire rv64i_slt;
	wire rv64i_sll;
	wire rv64i_srl;
	wire rv64i_sra;

	wire [(5+RNBIT-1):0] shift_rd0_dnxt;
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

	wire [63:0] alu_shiftLeft_op1 = op1;
	wire [64:0] alu_shiftRight_op1 = is32w ? { {33{(alu_shift_op1[31] & alu_fun_sra)}}, op1[31:0]} 
												: { (alu_shift_op1[63] & alu_fun_sra), op1 };

	wire [5:0] shamt = op2[5:0];

	wire [63:0] shift_left64 = alu_shiftLeft_op1 << shamt;
	wire [63:0] shift_left32 = {32'b0,alu_shift_left[31:0]};

	wire [63:0] shift_left  = is32w ? alu_shift_left32 : alu_shift_left64;
	wire [63:0] shift_right = alu_shiftRight_op1 >>> shamt;


	wire [63:0] shift_res_dnxt =  ( {64{rv64i_sll}} & alu_shift_left )
							| ( {64{rv64i_srl | rv64i_sra}} & alu_shift_right );


gen_dffr # (.DW((5+RNBIT))) shift_rd0 ( .dnxt(shift_rd0_dnxt), .qout(shift_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) shift_res ( .dnxt(shift_res_dnxt), .qout(shift_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(shift_exeparam_vaild), .qout(shift_writeback_vaild), .CLK(CLK), .RSTn(RSTn));


endmodule




