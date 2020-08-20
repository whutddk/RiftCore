/*
* @File name: ALU
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-08-18 16:59:17
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-08-20 20:20:39
*/


module ALU (
	input [SZ_DW-1 :0] dw,
	input [SZ_ALU_FN-1 :0] fn,
	input [xLen-1 : 0] in2,
	input [xLen-1 : 0] in1,
	output [xLen-1 : 0] out,
	output [xLen-1 : 0] adder_out,
	output cmp_out
);



	// ADD, SUB
	wire [xLen-1 : 0] in2_inv = fn[3] ? ~in2 : in2;
	wire [xLen-1 : 0] in1_xor_in2 = io.in1 ^ in2_inv;
	assign adder_out = in1 + in2_inv + fn[3];

	// SLT, SLTU
	wire [xLen-1 : 0] slt = ( in1[xLen-1] == in2[xLen-1] ) ? adder_out[xLen-1] :
															( fn[1] ? in2[xLen-1] : in1[xLen-1] );
	assign cmp_out = fn[0] ^ ( !fn[3] ? in1_xor_in2 == {xLen{1'd0}} : slt);

	// SLL, SRL, SRA
	
	wire [xLen-1 : 0] shin_r;


#if xLen == 32

	wire shamt = in2[4,0];
	assign shin_r = in1;

#else if xLen == 64
	wire [32-1:0] shin_hi_32 = {32{fn[3] & in1[31]}};
	wire [31-1:0] shin_hi = ( dw ? in1[63:32] : shin_hi_32);
	wire [5:0] shamt = {in2[5] & dw, in2[4:0]};
	assign shin_r = {shin_hi, in1[31:0]};

#end


  // wire [xLen-1:0] shin = (fn == FN_SR  || fn == FN_SRA) ? shin_r : Reverse(shin_r);

	genvar i;
	generate
	for ( i = 0; i < xLen; i = i + 1 ) begin 
		if (fn == FN_SR  || fn == FN_SRA) begin
			shin[i] = shin_r[i];
		end
		else begin
			shin[i] = shin_r[xLen-1-i];
		end
		end
	endgenerate

	wire [xLen-1:0] shout_r = ({fn[3] & shin[xLen-1], shin} >> shamt)[xLen-1:0];

	generate
	for ( i = 0; i < xLen; i = i + 1 ) begin 
		shout_l[i] = shout_r[xLen-1-i];
	end
	endgenerate

	wire [xLen-1:0] shout = ((fn == FN_SR || fn == FN_SRA) ? shout_r : {xLen{1'd0}})
  							|
              				((fn == FN_SL) ? shout_l : {xLen{1'd0}});

  // AND, OR, XOR
	wire [xLen-1:0] lgc = ((fn == FN_XOR || fn == FN_OR) ? in1_xor_in2 : {xLen{1'd0}}) 
				|
              	((fn == FN_OR || fn == FN_AND) ? (in1 & in2) : {xLen{1'd0}});

	wire [xLen-1:0] shift_logic = ( fn >= FN_SLT && slt) | lgc | shout;


	wire [xLen-1:0] pre_out = (fn == FN_ADD || fn == FN_SUB) ? adder_out : shift_logic;

#if xLen == 32
	assign out = pre_out;
#else if xLen == 64
   	assign out = (dw == 1'd0) ? { {32{out[31]}}, pre_out[31:0] } : pre_out;
}

#end 







endmodule

