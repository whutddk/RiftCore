/*
* @File name: alu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-26 19:52:59
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module alu_issue (
	
	//from dispatch
	input  dispat_vaild,
	output issueS_ready,

	input [:] dispat_instr_info,





	input alu_issue_vaild,
	output alu_issue_ready,	
	input [:] alu_issue_info,

	input lsu_issue_vaild,
	output lsu_issue_ready,
	input [:] lsu_issue_info,

	input csr_issue_vaild,
	output csr_issue_ready,
	input [:] csr_issue_info,

	input blu_issue_vaild,
	output blu_issue_ready,
	input [:] blu_issue_info,

	input oth_issue_vaild,
	output oth_issue_ready,
	input [:] oth_issue_info,




	//from execute







	// from scoreboard 





);



	//check RAW here


	//这里不用fifo，用并行buff以保证可以乱序发射


	wire [ * ALU_ISSUE_DEPTH - 1 : 0] alu_execute_info;
	wire [ ALU_ISSUE_DEPTH - 1 : 0 ] alu_isRAW;

	gen_buffer alu_issue_buffer (
		.DP(ALU_ISSUE_DEPTH)
		.DW()
	) #
	(

		.vaild_a(alu_issue_vaild), 
		.ready_a(alu_issue_ready), 
		.data_a(alu_issue_info),

		.vaild_b(), 
		.ready_b(), 
		.data_b(alu_execute_info),

		.CLK,
		.RSTn
	);









	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_lui;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_auipc;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_addi;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_addiw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_slti;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sltiu;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_xori;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_ori;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_andi;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_slli;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_slliw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_srli;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_srliw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_srai;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sraiw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_add;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_addw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sub;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_subw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sll;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sllw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_slt;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sltu;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_xor;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_srl;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_srlw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sra;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_sraw;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_or;
	wire [ALU_ISSUE_DEPTH - 1:0] rv64i_and;

	wire [64*ALU_ISSUE_DEPTH - 1:0] alu_pc;
	wire [64*ALU_ISSUE_DEPTH - 1:0] alu_imm;
	wire [5*ALU_ISSUE_DEPTH - 1:0] alu_shamt;
	wire [5+RNBIT*ALU_ISSUE_DEPTH - 1] alu_rd0_index;
	wire [5+RNBIT*ALU_ISSUE_DEPTH - 1] alu_rs1_index;
	wire [5+RNBIT*ALU_ISSUE_DEPTH - 1] alu_rs2_index;

	wire [ALU_ISSUE_DEPTH - 1] rs1_ready;
	wire [ALU_ISSUE_DEPTH - 1] rs2_ready;

	wire [ALU_ISSUE_DEPTH - 1] alu_fun_add;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_sub;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_slt;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_sll;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_srl;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_sra;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_xor;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_or;
	wire [ALU_ISSUE_DEPTH - 1] alu_fun_and;



	wire  [64*ALU_ISSUE_DEPTH-1:0] op1,
	wire  [64*ALU_ISSUE_DEPTH-1:0] op2,


generate
	for ( genvar i = 0; i < ALU_ISSUE_DEPTH; i = i + 1 ) begin

		assign { rv64i_lui[i], rv64i_auipc[i], 
				rv64i_addi[i], rv64i_addiw[i], rv64i_add[i], rv64i_addw[i], rv64i_sub[i], rv64i_subw[i],
				rv64i_slti[i], rv64i_sltiu[i], rv64i_slli[i], rv64i_slliw[i], rv64i_sll[i], rv64i_sllw[i], rv64i_slt[i], rv64i_sltu[i],
				rv64i_srli[i], rv64i_srliw[i], rv64i_srai[i], rv64i_sraiw[i], rv64i_srl[i], rv64i_srlw[i], rv64i_sra[i], rv64i_sraw[i], 
				rv64i_xori[i], rv64i_ori[i], rv64i_andi[i], rv64i_xor[i], rv64i_or[i], rv64i_and[i],
				alu_pc[64*i +: 64], alu_imm[64*i +: 64], alu_shamt[5*i +: 5], 
				alu_rd0_index[(5+RNBIT)*i +: (5+RNBIT)], 
				alu_rs1_index[(5+RNBIT)*i +: (5+RNBIT)], 
				alu_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]
				} = alu_execute_info;

		assign rs1_ready[i] = writeBackBuffer_qout[alu_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = writeBackBuffer_qout[alu_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

		assign alu_isClearRAW[i] = 	rv64i_lui[i]
								| rv64i_auipc[i]
								| ( rv64i_addi[i] & rs1_ready )
								| ( rv64i_addiw[i] & rs1_ready )
								| ( rv64i_add[i] & rs1_ready & rs2_ready )
								| ( rv64i_addw[i] & rs1_ready & rs2_ready )

								| ( rv64i_sub[i] & rs1_ready & rs2_ready )
								| ( rv64i_subw[i] & rs1_ready & rs2_ready )

								| ( rv64i_slti[i] & rs1_ready )
								| ( rv64i_sltiu[i] & rs1_ready )
								| ( rv64i_slt[i] & rs1_ready & rs2_ready )
								| ( rv64i_sltu[i] & rs1_ready & rs2_ready )

								| ( rv64i_slli[i] & rs1_ready )
								| ( rv64i_slliw[i] & rs1_ready )
								| ( rv64i_sll[i] & rs1_ready & rs2_ready )
								| ( rv64i_sllw[i] & rs1_ready & rs2_ready )

								| ( rv64i_srli[i] & rs1_ready )
								| ( rv64i_srliw[i] & rs1_ready )
								| ( rv64i_srl[i] & rs1_ready & rs2_ready )
								| ( rv64i_srlw[i] & rs1_ready & rs2_ready )

								| ( rv64i_srai[i] & rs1_ready )
								| ( rv64i_sraiw[i] & rs1_ready )
								| ( rv64i_sra[i] & rs1_ready & rs2_ready )
								| ( rv64i_sraw[i] & rs1_ready & rs2_ready )

								| ( rv64i_xori[i] & rs1_ready & rs2_ready )
								| ( rv64i_xor[i] & rs1_ready & rs2_ready )

								| ( rv64i_ori[i] & rs1_ready  )
								| ( rv64i_or[i] & rs1_ready & rs2_ready )

								| ( rv64i_andi[i] & rs1_ready )
								| ( rv64i_and[i] & rs1_ready & rs2_ready );


		assign alu_fun_add[i] = rv64i_lui[i] | rv64i_auipc[i] | rv64i_addi[i] | rv64i_addiw[i] | rv64i_add[i] | rv64i_addw[i];
		assign alu_fun_sub[i] = rv64i_sub[i] | rv64i_subw[i];
		assign alu_fun_slt[i] = rv64i_slti[i] | rv64i_sltiu[i] | rv64i_slt[i] | rv64i_sltu[i];
		assign alu_fun_sll[i] = rv64i_slli[i] | rv64i_slliw[i] | rv64i_sll[i] | rv64i_sllw[i];
		assign alu_fun_srl[i] = rv64i_srli[i] | rv64i_srliw[i] | rv64i_srl[i] | rv64i_srlw[i];
		assign alu_fun_sra[i] = rv64i_srai[i] | rv64i_sraiw[i] | rv64i_sra[i] | rv64i_sraw[i];
		assign alu_fun_xor[i] = rv64i_xori[i] | rv64i_xor[i];
		assign alu_fun_or[i] = rv64i_ori[i] | rv64i_or[i];
		assign alu_fun_and[i] = rv64i_andi[i] | rv64i_and[i];

		assign src1 = 
		assign src2 = 

		assign op1[64*i +:64] = ( {64{rv64i_lui[i]}} & 64'h0)
								| ( {64{rv64i_auipc[i]}} & alu_pc[64*i +: 64] )
								| ( {64{rv64i_addi[i]}} & src1 )
								| ( rv64i_addiw[i] & src1 )
								| ( rv64i_add[i] & src1 )
								| ( rv64i_addw[i] & src1 )

								| ( rv64i_sub[i] & src1 )
								| ( rv64i_subw[i] & src1 )

								| ( rv64i_slti[i] & src1 )
								| ( rv64i_sltiu[i] & src1 )
								| ( rv64i_slt[i] & src1 )
								| ( rv64i_sltu[i] & src1 )

								| ( rv64i_slli[i] & src1 )
								| ( rv64i_slliw[i] & src1 )
								| ( rv64i_sll[i] & src1 )
								| ( rv64i_sllw[i] & src1 )

								| ( rv64i_srli[i] & src1 )
								| ( rv64i_srliw[i] & src1 )
								| ( rv64i_srl[i] & src1 )
								| ( rv64i_srlw[i] & src1 )

								| ( rv64i_srai[i] & src1 )
								| ( rv64i_sraiw[i] & src1 )
								| ( rv64i_sra[i] & src1 )
								| ( rv64i_sraw[i] & src1 )

								| ( rv64i_xori[i] & src1 )
								| ( rv64i_xor[i] & src1 )

								| ( rv64i_ori[i] & src1 )
								| ( rv64i_or[i] & src1 )

								| ( rv64i_andi[i] & src1 )
								| ( rv64i_and[i] & src1 );

		assign op2[64*i +:64] = ( {64{rv64i_lui[i]}} & alu_imm[64*i +: 64])
								| ( {64{rv64i_auipc[i]}} & alu_imm[64*i +: 64])
								| ( {64{rv64i_addi[i]}} & alu_imm[64*i +: 64] )
								| ( rv64i_addiw[i] & alu_imm[64*i +: 64] )
								| ( rv64i_add[i] & src2 )
								| ( rv64i_addw[i] & src2 )

								| ( rv64i_sub[i] & src2 )
								| ( rv64i_subw[i] & src2 )

								| ( rv64i_slti[i] & alu_imm[64*i +: 64] )
								| ( rv64i_sltiu[i] & alu_imm[64*i +: 64] )
								| ( rv64i_slt[i] & src2 )
								| ( rv64i_sltu[i] & src2 )

								| ( rv64i_slli[i] & alu_imm[64*i +: 64] )
								| ( rv64i_slliw[i] & alu_imm[64*i +: 64] )
								| ( rv64i_sll[i] & { 59'b0, alu_shamt[5*i +: 5]} )
								| ( rv64i_sllw[i] & { 59'b0, alu_shamt[5*i +: 5]} )

								| ( rv64i_srli[i] & alu_imm[64*i +: 64] )
								| ( rv64i_srliw[i] & alu_imm[64*i +: 64] )
								| ( rv64i_srl[i] & { 59'b0, alu_shamt[5*i +: 5]} )
								| ( rv64i_srlw[i] & { 59'b0, alu_shamt[5*i +: 5]} )

								| ( rv64i_srai[i] & alu_imm[64*i +: 64] )
								| ( rv64i_sraiw[i] & alu_imm[64*i +: 64] )
								| ( rv64i_sra[i] & { 59'b0, alu_shamt[5*i +: 5]} )
								| ( rv64i_sraw[i] & { 59'b0, alu_shamt[5*i +: 5]} )

								| ( rv64i_xori[i] & alu_imm[64*i +: 64] )
								| ( rv64i_xor[i] & src2 )

								| ( rv64i_ori[i] & alu_imm[64*i +: 64] )
								| ( rv64i_or[i] & src2 )

								| ( rv64i_andi[i] & alu_imm[64*i +: 64] )
								| ( rv64i_and[i] & src2 );


		assign alu_fun_is32w = 	rv64i_addiw[i]
								| rv64i_addw[i]
								| rv64i_subw[i]
								| rv64i_slliw[i]
								| rv64i_sllw[i]
								| rv64i_srliw[i]
								| rv64i_srlw[i]
								| rv64i_sraiw[i]
								| rv64i_sraw[i];


		assign alu_fun_isUsi = rv64i_sltiu[i]
								| rv64i_sltu[i];


	end



lzc



endgenerate






































gen_fifo lsu_issue_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(),

	.vaild_b(), 
	.ready_b(), 
	.data_b(),

	.CLK,
	.RSTn
);


gen_fifo csr_issue_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(),

	.vaild_b(), 
	.ready_b(), 
	.data_b(),

	.CLK,
	.RSTn
);



gen_fifo blu_issue_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(),

	.vaild_b(), 
	.ready_b(), 
	.data_b(),

	.CLK,
	.RSTn
);

















endmodule
