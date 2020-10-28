/*
* @File name: writeBack
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 17:47:42
*/

module writeBack (

	//from phyRegister
	input  [(64*RNDEPTH*32)-1:0] regFileX_qout,
	output [(64*RNDEPTH*32)-1:0] regFileX_dnxt,

	output [32*RNDEPTH-1 : 0] wbLog_writeb_set,



	//from adder
	input adder_writeback_vaild,
	input [63:0] adder_res,
	input [(5+RNBIT-1):0] adder_rd0,

	//from logCmp
	input logCmp_writeback_vaild,
	input [63:0] logCmp_res,
	input [(5+RNBIT-1):0] logCmp_rd0,

	//from shift
	input shift_writeback_vaild,
	input [63:0] shift_res,
	input [(5+RNBIT-1):0] shift_rd0,

	//from jal
	output [(5+RNBIT-1):0] jal_rd0,
	output [63:0] jal_result

	//from bru
	input bru_writeback_vaild,
	input [(5+RNBIT-1):0] bru_rd0,
	input [63:0] bru_res,






	
);

// adder wb
wire [(64*RNDEPTH*32)-1:0] adder_writeback_dnxt;
// logCmp wb
wire [(64*RNDEPTH*32)-1:0] logCmp_writeback_dnxt;
// shift wb
wire [(64*RNDEPTH*32)-1:0] shift_writeback_dnxt;
//jal wb
wire [(64*RNDEPTH*32)-1:0] jal_writeback_dnxt;
//bru wb
wire [(64*RNDEPTH*32)-1:0] bru_writeback_dnxt;




//write back

assign wbLog_writeb_set[RNDEPTH-1 : 0]  = {RNDEPTH{1'b1}};


generate
	
	for ( genvar regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( genvar depth = 0 ; depth < RNDEPTH; depth = depth + 1 ) begin

			localparam  SEL = regNum*4+depth;

			assign regFileX_dnxt[64*SEL +: 64] =  

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
				//bru wb
				{64{bru_writeback_vaild & (bru_rd0 == SEL)}} & bru_res


				//nobody wb
				(~{64{adder_writeback_vaild & (adder_rd0 == SEL)}} &
					~{64{logCmp_writeback_vaild & (logCmp_rd0 == SEL)}} &
					~{64{shift_writeback_vaild & (shift_rd0 == SEL)}} &
					~{64{jal_writeback_vaild & (jal_rd0 == SEL)}} &
					~{64{bru_writeback_vaild & (bru_rd0 == SEL)}}) 
					& regFileX_qout[64*SEL +: 64];
		

			assign wbLog_writeb_set[SEL] = 
				(adder_writeback_vaild & (adder_rd0 == SEL))
				|
				(logCmp_writeback_vaild & (logCmp_rd0 == SEL))
				|
				(shift_writeback_vaild & (shift_rd0 == SEL))
				|
				(jal_writeback_vaild & (jal_rd0 == SEL))
				| 
				(bru_writeback_vaild & (bru_rd0 == SEL))
				;


		end
	end

endgenerate








endmodule

