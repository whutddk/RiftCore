/*
* @File name: writeBack
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 17:48:36
*/

`include "define.vh"

module writeBack (

	//from phyRegister
	input  [(64*`RP*32)-1:0] regFileX_qout,
	output [(64*`RP*32)-1:0] regFileX_dnxt,

	output [32*`RP-1 : 0] wbLog_writeb_set,


	//from adder
	input adder_writeback_vaild,
	input [63:0] adder_res,
	input [(5+`RB-1):0] adder_rd0,

	//from logCmp
	input logCmp_writeback_vaild,
	input [63:0] logCmp_res,
	input [(5+`RB-1):0] logCmp_rd0,

	//from shift
	input shift_writeback_vaild,
	input [63:0] shift_res,
	input [(5+`RB-1):0] shift_rd0,

	//from jal
	input jal_writeback_vaild,
	input [(5+`RB-1):0] jal_rd0,
	input [63:0] jal_res,

	//from lsu
	input lsu_writeback_vaild,
	input [(5+`RB-1):0] lsu_rd0,
	input [63:0] lsu_res,

	//from csr
	input csr_writeback_vaild,
	input [(5+`RB-1):0] csr_rd0,
	input [63:0] csr_res

);

// adder wb
wire [(64*`RP*32)-1:0] adder_writeback_dnxt;
// logCmp wb
wire [(64*`RP*32)-1:0] logCmp_writeback_dnxt;
// shift wb
wire [(64*`RP*32)-1:0] shift_writeback_dnxt;
//jal wb
wire [(64*`RP*32)-1:0] jal_writeback_dnxt;
//lsu wb
wire [(64*`RP*32)-1:0] lsu_writeback_dnxt;
//csr wb
wire [(64*`RP*32)-1:0] csr_writeback_dnxt;


//write back

assign wbLog_writeb_set[`RP-1 : 0]  = {`RP{1'b1}};

assign regFileX_dnxt[64*`RP-1:0] = {64*`RP{1'b0}};
generate
	
	for ( genvar regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( genvar depth = 0 ; depth < `RP; depth = depth + 1 ) begin

			localparam  SEL = regNum*4+depth;

			assign regFileX_dnxt[64*SEL +: 64] =  
				(
					//adder wb
					{64{adder_writeback_vaild & (adder_rd0 == SEL)}} & adder_res
					|
					//logCmp wb
					{64{logCmp_writeback_vaild & (logCmp_rd0 == SEL)}} & logCmp_res
					|
					//shift wb
					{64{shift_writeback_vaild & (shift_rd0 == SEL)}} & shift_res
					|
					//jal wb
					{64{jal_writeback_vaild & (jal_rd0 == SEL)}} & jal_res
					|
					//lsu wb
					{64{lsu_writeback_vaild & (lsu_rd0 == SEL)}} & lsu_res
					|
					//csr wb
					{64{csr_writeback_vaild & (csr_rd0 == SEL)}} & csr_res
				)
				|
				(
					//nobody wb
					(~{64{adder_writeback_vaild & (adder_rd0 == SEL)}} &
					~{64{logCmp_writeback_vaild & (logCmp_rd0 == SEL)}} &
					~{64{shift_writeback_vaild & (shift_rd0 == SEL)}} &
					~{64{jal_writeback_vaild & (jal_rd0 == SEL)}} &
					~{64{lsu_writeback_vaild & (lsu_rd0 == SEL)}} &
					~{64{csr_writeback_vaild & (csr_rd0 == SEL)}}) 
					& regFileX_qout[64*SEL +: 64]
				);

			assign wbLog_writeb_set[SEL] = 
				(adder_writeback_vaild & (adder_rd0 == SEL))
				|
				(logCmp_writeback_vaild & (logCmp_rd0 == SEL))
				|
				(shift_writeback_vaild & (shift_rd0 == SEL))
				|
				(jal_writeback_vaild & (jal_rd0 == SEL))
				| 
				(lsu_writeback_vaild & (lsu_rd0 == SEL))
				| 
				(csr_writeback_vaild & (csr_rd0 == SEL))
				;


		end
	end

endgenerate








endmodule

