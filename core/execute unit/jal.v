/*
* @File name: jal
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 17:21:08
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-29 20:01:29
*/

module jal (
	//from jal issue
	output jal_execute_ready,
	input jal_execute_vaild,
	input [ :0] jal_execute_info, 


	// to branch predict
	output jalr_vaild,
	output [63:0] jump_pc,

	// to writeback
	output jal_writeback_vaild,
	output [(5+RNBIT-1):0] rd0,
	output [63:0] jal_result


);

	wire bru_jal;
	wire bru_jalr;

	wire [63:0] pc,
	
	wire [63:0] src1;	

	assign { 
			bru_jal,
			bru_jalr,

			rd0,
			src1,
			pc,

			is_rvc
			} = bru_execute_info;


assign jalr_pc = pc + src1;

assign jal_result = {64{(blu_jal | blu_jalr)}} & ( pc + ( is_rvc ? 64'd2 : 64'd4 ) );

assign jalr_vaild = blu_jalr;

endmodule






