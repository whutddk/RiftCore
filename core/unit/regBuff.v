/*
* @File name: regBuff
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-21 14:49:32
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-21 20:19:30
*/


module regBuff #(
	parameter RNDEPTH = 4, //重命名深度

	localparam RNBIT = 2
	localparam RNREGWIDTH= 64*RNDEPTH,
	
	)
(
	input CLK,
	input RSTn,

	input [RNDEPTH-1:0] regFile_Wen,
	input [64*RNDEPTH-1:0] regFileX_in,
	output [64*RNDEPTH-1:0] regFileX_out,
	
);



wire [64 * RNDEPTH -1 :0] regFileX_read;
wire [64 * RNDEPTH -1 :0] regFileX_write;


assign regFileX_out = regFileX_read;

generate
	for ( depth = 0; depth < RNDEPTH; depth = depth + 1 ) begin

		assign regFileX_write[64*depth +: 64] = ( regFile_Wen[depth] ? regFileX_in[64*depth +: 64] : regFileX_read[64*depth +: 64] );

	end
endgenerate

						
						









endmodule


