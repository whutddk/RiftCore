/*
* @File name: regFiles
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-21 14:34:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 17:48:13
*/

`include "define.vh"

module regFiles
(

	output [(64*`RP*32)-1:0] regFileX_qout,
	input  [(64*`RP*32)-1:0] regFileX_dnxt,

	input CLK,
	input RSTn
);

assign regFileX_qout[64*`RP-1:0] = {64*`RP{1'b0}};

generate
	
	for ( genvar regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( genvar depth = 0 ; depth < `RP; depth = depth + 1 ) begin

			localparam  SEL = regNum*4+depth;

			gen_dffr  #(.DW(64)) int_regX ( .dnxt(regFileX_dnxt[64*SEL +: 64]), .qout(regFileX_qout[64*SEL +: 64]), .CLK(CLK), .RSTn(RSTn) );

		end
	end



endgenerate









endmodule







