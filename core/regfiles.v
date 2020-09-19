/*
* @File name: regfiles
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-14 10:19:13
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-14 11:18:50
*/



module regfiles (

	input  [4:0] read_src1_idx,
	input  [4:0] read_src2_idx,
	output [63:0] read_src1_dat,
	output [63:0] read_src2_dat,

	input  wbck_dest1_wen,
	input  wbck_dest2_wen,
	input  [4:0] wbck_dest1_idx,
	input  [4:0] wbck_dest2_idx,
	input  [63:0] wbck_dest1_dat,
	input  [63:0] wbck_dest2_dat,

	input CLK,
	input RSTn

);




wire [63:0] int_register_x0 = 64'b0;
wire [64*32-1:0] int_register_read;
assign int_register_read[63:0] = int_register_x0;

genvar i;
generate 
	for ( i = 1; i < 32; i = i + 1 ) begin

		wire [63:0] int_register_din;
		wire [63:0] int_register_qout;
		gen_dffr int_register (.DW(64)) ( .dnxt(int_register_din), .qout(int_register_qout), .CLK(CLK), .RSTn(RSTn) );

		assign int_register_din = ({64{((wbck_dest1_idx == i) & wbck_dest1_wen)}} & wbck_dest1_dat)
								| ({64{((wbck_dest2_idx == i) & wbck_dest2_wen)}} & wbck_dest2_dat);

		assign int_register_read[64*i+63:64*i] = int_register_qout;

	end
endgenerate

	assign read_src1_dat = int_register_read[64*read_src1_idx+63 : 64*read_src1_idx];
	assign read_src2_dat = int_register_read[64*read_src2_idx+63 : 64*read_src2_idx];


endmodule










