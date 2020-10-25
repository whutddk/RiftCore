/*
* @File name: issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-25 14:19:48
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module issue (
	
	//from dispatch


	wire rv64i_lui,
	wire rv64i_auipc,
	wire rv64i_jal,
	wire rv64i_jalr,

	wire rv64i_beq,
	wire rv64i_bne,
	wire rv64i_blt,
	wire rv64i_bge,
	wire rv64i_bltu,
	wire rv64i_bgeu,

	wire rv64i_lb,
	wire rv64i_lh,
	wire rv64i_lw,
	wire rv64i_lbu,
	wire rv64i_lhu,
	wire rv64i_lwu,
	wire rv64i_ld,

	wire rv64i_sb,
	wire rv64i_sh,
	wire rv64i_sw,
	wire rv64i_sd,

	wire rv64i_addi,
	wire rv64i_addiw,
	wire rv64i_slti,
	wire rv64i_sltiu,
	wire rv64i_xori,
	wire rv64i_ori,
	wire rv64i_andi,
	wire rv64i_slli,
	wire rv64i_slliw,
	wire rv64i_srli,
	wire rv64i_srliw,
	wire rv64i_srai,
	wire rv64i_sraiw,

	wire rv64i_add,
	wire rv64i_addw,
	wire rv64i_sub,
	wire rv64i_subw,
	wire rv64i_sll,
	wire rv64i_sllw,
	wire rv64i_slt,
	wire rv64i_sltu,
	wire rv64i_xor,
	wire rv64i_srl,
	wire rv64i_srlw,
	wire rv64i_sra,
	wire rv64i_sraw,
	wire rv64i_or,
	wire rv64i_and,

	wire rv64i_fence,
	wire rv64zi_fence_i,

	wire rv64i_ecall,
	wire rv64i_ebreak,
	wire rv64csr_rw,
	wire rv64csr_rs,
	wire rv64csr_rc,
	wire rv64csr_rwi,
	wire rv64csr_rsi,
	wire rv64csr_rci,










	output alu_issue_vaild,
	output lsu_issue_vaild,
	output csr_issue_vaild,
	output blu_issue_vaild,



	//from execute







	// from scoreboard 





);



	assign decode_microInstr = { rv64i_lui, rv64i_auipc, rv64i_jal, rv64i_jalr,
								rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu, 
								rv64i_lb, rv64i_lh, rv64i_lw, rv64i_lbu, rv64i_lhu, rv64i_lwu, rv64i_ld,
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
								rv64i_addi, rv64i_addiw, rv64i_slti, rv64i_sltiu, rv64i_xori, rv64i_ori, rv64i_andi, rv64i_slli, rv64i_slliw, rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw,
								rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu, rv64i_xor, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, rv64i_or, rv64i_and,
								rv64i_fence, rv64zi_fence_i,
								rv64i_ecall, rv64i_ebreak, rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci
								};
















gen_fifo alu_issue_fifo (
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
