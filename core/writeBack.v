/*
* @File name: writeBack
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 14:58:33
*/

module writeBack (

	//from phyRegister
	input  [(64*RNDEPTH*32)-1:0] regFileX_qout,
	output [(64*RNDEPTH*32)-1:0] regFileX_dnxt,

	output [32*RNDEPTH-1 : 0] wbLog_writeb_set,



	//from alu
	input alu_writeback_vaild,
	input [:] alu_writeback_info








	
);

// alu wb

wire [(64*RNDEPTH*32)-1:0] alu_writeback_dnxt;
wire [63:0] alu_res;
wire [(5+RNBIT-1):0] alu_rd0;


assign {alu_res, alu_rd0} = alu_writeback_info;






//write back

assign wbLog_writeb_set[RNDEPTH-1 : 0]  = {RNDEPTH{1'b1}};


generate
	
	for ( genvar regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( genvar depth = 0 ; depth < RNDEPTH; depth = depth + 1 ) begin

			localparam  SEL = regNum*4+depth;

			assign regFileX_dnxt[64*SEL +: 64] =  

				//alu wb
				{64{alu_writeback_vaild & (alu_rd0 == SEL)}} & alu_res
				|



				//nobody wb
				(~{64{alu_writeback_vaild & (alu_rd0 == SEL)}} ) 
					& regFileX_qout[64*SEL +: 64];
													
			assign wbLog_writeb_set[SEL] = 
				(alu_writeback_vaild & (alu_rd0 == SEL))
				| 
				;


		end
	end

endgenerate








endmodule

