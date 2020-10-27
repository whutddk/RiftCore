/*
* @File name: blu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:50:36
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 18:01:35
*/


module blu_issue (


	input blu_issue_vaild,
	output blu_issue_ready,
	input [:] blu_issue_info,







);

gen_buffer blu_issue_buffer (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(),

	.vaild_b(), 
	.ready_b(), 
	.data_b(blu_issue_info_pop),

	.CLK,
	.RSTn
);


gen_buffer blu_issueBuffer_vaild (
		.DP(ALU_ISSUE_DEPTH)
		.DW()
	) #
	(

		.data_a(blu_issueBuffer_vaild_dnxt)

		.data_b(blu_issueBuffer_vaild_qout),

		.CLK,
		.RSTn
	);








	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_jal;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_jalr;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_beq;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_bne;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_blt;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_bge;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_bltu;
	wire [`BLU_ISSUE_DEPTH-1:0] rv64i_bgeu;

	wire [64*`BLU_ISSUE_DEPTH-1:0] blu_pc;
	wire [64*`BLU_ISSUE_DEPTH-1:0] blu_imm;
	wire [(5+RNBIT)*`BLU_ISSUE_DEPTH-1:0] blu_rd0;
	wire [(5+RNBIT)*`BLU_ISSUE_DEPTH-1:0] blu_rs1;
	wire [(5+RNBIT)*`BLU_ISSUE_DEPTH-1:0] blu_rs2;


	wire [64*BLU_ISSUE_DEPTH-1 : 0] src1;
	wire [64*BLU_ISSUE_DEPTH-1 : 0] src2;

	wire  [64*BLU_ISSUE_DEPTH-1:0] op1;
	wire  [64*BLU_ISSUE_DEPTH-1:0] op2;

	wire [64*BLU_ISSUE_DEPTH-1:0] cmp1;
	wire [64*BLU_ISSUE_DEPTH-1:0] cmp2;



generate
	for ( genvar i = 0; i < BLU_ISSUE_DEPTH; i = i + 1 ) begin

		assign {
					rv64i_jal[i],
					rv64i_jalr[i],
					rv64i_beq[i],
					rv64i_bne[i],
					rv64i_blt[i],
					rv64i_bge[i],
					rv64i_bltu[i],
					rv64i_bgeu[i],
					blu_pc[64*i +: 64],
					blu_imm[64*i +: 64],
					blu_rd0[(5+RNBIT)*i +: (5+RNBIT)],
					blu_rs1[(5+RNBIT)*i +: (5+RNBIT)],
					blu_rs2[(5+RNBIT)*i +: (5+RNBIT)]
				} = blu_issue_info_pop;


	assign rs1_ready[i] = wbBuf_qout[alu_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
	assign rs2_ready[i] = wbBuf_qout[alu_rs2[(5+RNBIT)*i +: (5+RNBIT)]];

	assign blu_isClearRAW[i] = 	( blu_issueBuffer_vaild_out ) & 
											 rs1_ready  & rs2_ready ;


	assign src1[64*i +: 64] = regFileX_read[alu_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]
	assign src2[64*i +: 64] = regFileX_read[alu_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]]

	assign op1[64*i +:64] = blu_pc
	assign op2[64*i +:64] = blu_imm;

	assign cmp1 = src1;
	assign cmp2 = src2;


	end
endmodule




















endmodule







