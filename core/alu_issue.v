/*
* @File name: alu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 19:08:03
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








	//from execute

	input alu_execute_ready,
	output alu_execute_vaild,
	output [ :0] alu_execute_info,





	// from scoreboard 



	//from resFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);



	//check RAW here


	//这里不用fifo，用并行buff以保证可以乱序发射
	wire [ * ALU_ISSUE_DEPTH - 1 : 0] alu_issue_info;
	wire [ ALU_ISSUE_DEPTH - 1 : 0 ] alu_isRAW;

	gen_buffer alu_issue_buffer (
		.DP(ALU_ISSUE_DEPTH)
		.DW()
	) #
	(

		.vaild_a(alu_issue_vaild), 
		.ready_a(alu_issue_ready), 
		.data_a(alu_issue_push),

		.vaild_b(), 
		.ready_b(), 
		.data_b(alu_issue_pop),

		.CLK,
		.RSTn
	);

gen_buffer alu_issueBuffer_vaild (
		.DP(ALU_ISSUE_DEPTH)
		.DW()
	) #
	(

		.data_a(alu_issueBuffer_vaild_dnxt)

		.data_b(alu_issueBuffer_vaild_qout),

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
	wire [(5+RNBIT)*ALU_ISSUE_DEPTH - 1] alu_rd0_index;
	wire [(5+RNBIT)*ALU_ISSUE_DEPTH - 1] alu_rs1_index;
	wire [(5+RNBIT)*ALU_ISSUE_DEPTH - 1] alu_rs2_index;

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

	wire [64*ALU_ISSUE_DEPTH-1 : 0] src1;
	wire [64*ALU_ISSUE_DEPTH-1 : 0] src2;



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
				} = alu_issue_info;

		assign rs1_ready[i] = writeBackBuffer_qout[alu_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = writeBackBuffer_qout[alu_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

		assign alu_isClearRAW[i] = 	( alu_issueBuffer_vaild_out ) & 
										(
										  rv64i_lui[i]
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
										| ( rv64i_and[i] & rs1_ready & rs2_ready )
									);


		assign alu_fun_add[i] = rv64i_lui[i] | rv64i_auipc[i] | rv64i_addi[i] | rv64i_addiw[i] | rv64i_add[i] | rv64i_addw[i];
		assign alu_fun_sub[i] = rv64i_sub[i] | rv64i_subw[i];
		assign alu_fun_slt[i] = rv64i_slti[i] | rv64i_sltiu[i] | rv64i_slt[i] | rv64i_sltu[i];
		assign alu_fun_sll[i] = rv64i_slli[i] | rv64i_slliw[i] | rv64i_sll[i] | rv64i_sllw[i];
		assign alu_fun_srl[i] = rv64i_srli[i] | rv64i_srliw[i] | rv64i_srl[i] | rv64i_srlw[i];
		assign alu_fun_sra[i] = rv64i_srai[i] | rv64i_sraiw[i] | rv64i_sra[i] | rv64i_sraw[i];
		assign alu_fun_xor[i] = rv64i_xori[i] | rv64i_xor[i];
		assign alu_fun_or[i] = rv64i_ori[i] | rv64i_or[i];
		assign alu_fun_and[i] = rv64i_andi[i] | rv64i_and[i];

		assign src1[64*i +: 64] = regFileX_read[alu_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[alu_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]]

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


		assign alu_64n_32[i] = 	rv64i_addiw[i]
								| rv64i_addw[i]
								| rv64i_subw[i]
								| rv64i_slliw[i]
								| rv64i_sllw[i]
								| rv64i_srliw[i]
								| rv64i_srlw[i]
								| rv64i_sraiw[i]
								| rv64i_sraw[i];


		assign alu_fun_isUsi[i] = rv64i_sltiu[i]
								| rv64i_sltu[i];


	end
endgenerate





wire [$clog2(ALU_ISSUE_DEPTH)-1:0] alu_issue_pop_index;
wire alu_all_RAW;

//应该为组合逻辑实现
lzc #(
	.WIDTH(ALU_ISSUE_DEPTH),
	.CNT_WIDTH($clog2(ALU_ISSUE_DEPTH))
) alu_RAWClear(
	.in_i(alu_isClearRAW),
	.cnt_o(alu_issue_pop_index),
	.empty_o(alu_all_RAW)
);


assign alu_execute_info = { 
							alu_fun_add[ alu_issue_pop_index ],
							alu_fun_sub[ alu_issue_pop_index ],
							alu_fun_slt[ alu_issue_pop_index ],
							alu_fun_sll[ alu_issue_pop_index ],
							alu_fun_srl[ alu_issue_pop_index ],
							alu_fun_sra[ alu_issue_pop_index ],
							alu_fun_xor[ alu_issue_pop_index ],
							alu_fun_or[ alu_issue_index ],
							alu_fun_and[ alu_issue_index ],
							alu_rd0_index[(5+RNBIT)*alu_issue_index +: (5+RNBIT)],
							op1[ 64*alu_issue_pop_index +:64 ],
							op2[ 64*alu_issue_pop_index +:64 ],
							alu_64n_32[ alu_issue_pop_index ],
							alu_fun_isUsi[ alu_issue_pop_index ],
							};


assign alu_execute_vaild =  ~alu_all_RAW;



wire alu_issue_in = (alu_issue_vaild & alu_issue_ready);
wire alu_issue_out = ( alu_execute_ready & alu_execute_vaild );



assign alu_issueBuffer_vaild_dnxt = ( 
										{ALU_ISSUE_DEPTH{(alu_issue_in & alu_issue_out) | (~alu_issue_in & ~alu_issue_out)}}
										& alu_issueBuffer_vaild_qout
									)
									| 
									( 
										{ALU_ISSUE_DEPTH{(alu_issue_in & ~alu_issue_out) }}
										& (alu_issueBuffer_vaild_qout | (1'b1 << alu_issue_push_index_pre))
									) 
									| 
									( 
										{ALU_ISSUE_DEPTH{(~alu_issue_in & alu_issue_out)}}
										& (alu_issueBuffer_vaild_qout & ~(1'b1 << alu_issue_pop_index))
									)


& ( alu_execute_ready & alu_execute_vaild ) 
									? alu_issueBuffer_vaild_qout : alu_issueBuffer_vaild_pop;


wire [$clog2(ALU_ISSUE_DEPTH)-1:0] alu_issue_push_index_pre;
wire [$clog2(ALU_ISSUE_DEPTH)-1:0] alu_issue_push_index;

lzc #(
	.WIDTH(ALU_ISSUE_DEPTH),
	.CNT_WIDTH($clog2(ALU_ISSUE_DEPTH))
) alu_empty_buffer(
	.in_i(alu_issueBuffer_vaild_qout),
	.cnt_o(alu_issue_push_index_pre),
	.empty_o()
);


assign alu_issue_push_index = (alu_execute_ready & alu_execute_vaild) ? alu_issue_pop_index : alu_issue_push_index_pre;


















































endmodule
