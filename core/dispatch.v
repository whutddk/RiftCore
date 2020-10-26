/*
* @File name: dispatch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-26 16:36:28
*/



module dispatch (

	input [63:0] dispat_pc,
	input [63:0] imm,
	input [5:0] shamt,
	input [5+RNBIT-1:0] rd0,
	input [5+RNBIT-1:0] rs1,
	input [5+RNBIT-1:0] rs2,

	input [:] decode_microInstr,




	output  dispat_vaild,
	input iOrder_ready,
	input issueS_ready,

	output [:] iOrder_info_push,
	output [:] dispat_instr_info,



	output alu_issue_vaild,
	input alu_issue_ready,
	output [:] alu_issue_info,

	output lsu_issue_vaild,
	input lsu_issue_ready,
	output [:] lsu_issue_info,

	output csr_issue_vaild,
	input csr_issue_ready,
	output [:] csr_issue_info,

	output blu_issue_vaild,
	input blu_issue_ready,
	output [:] blu_issue_info,

	output oth_issue_vaild,
	input oth_issue_ready,
	output [:] oth_issue_info,

);




wire [] renaming_instr_info;
wire [] dispatch_instr_info;










gen_fifo dispatch_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(renaming_instr),

	.vaild_b(dispatch_vaild), 
	.ready_b(dispatch_ready), 
	.data_b(dispatch_instr),

	.CLK,
	.RSTn
);




assign {} = dispatch_instr;


assign iOrder_info_push = {dispat_pc, rd};










	wire rv64i_lui;
	wire rv64i_auipc;

	wire rv64i_jal;
	wire rv64i_jalr;
	wire rv64i_beq;
	wire rv64i_bne;
	wire rv64i_blt;
	wire rv64i_bge;
	wire rv64i_bltu;
	wire rv64i_bgeu;

	wire rv64i_lb;
	wire rv64i_lh;
	wire rv64i_lw;
	wire rv64i_lbu;
	wire rv64i_lhu;
	wire rv64i_lwu;
	wire rv64i_ld;

	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;

	wire rv64i_addi;
	wire rv64i_addiw;
	wire rv64i_slti;
	wire rv64i_sltiu;
	wire rv64i_xori;
	wire rv64i_ori;
	wire rv64i_andi;
	wire rv64i_slli;
	wire rv64i_slliw;
	wire rv64i_srli;
	wire rv64i_srliw;
	wire rv64i_srai;
	wire rv64i_sraiw;

	wire rv64i_add;
	wire rv64i_addw;
	wire rv64i_sub;
	wire rv64i_subw;
	wire rv64i_sll;
	wire rv64i_sllw;
	wire rv64i_slt;
	wire rv64i_sltu;
	wire rv64i_xor;
	wire rv64i_srl;
	wire rv64i_srlw;
	wire rv64i_sra;
	wire rv64i_sraw;
	wire rv64i_or;
	wire rv64i_and;

	wire rv64i_fence;
	wire rv64zi_fence_i;

	wire rv64i_ecall;
	wire rv64i_ebreak;
	wire rv64csr_rw;
	wire rv64csr_rs;
	wire rv64csr_rc;
	wire rv64csr_rwi;
	wire rv64csr_rsi;
	wire rv64csr_rci;






	wire [:] decode_microInstr;
	wire [63:0] dispatch_pc;
	wire [63:0] imm;
	wire [5:0] shamt;
	wire [5+RNBIT-1:0:0] rd0;
	wire [5+RNBIT-1:0:0] rs1;
	wire [5+RNBIT-1:0:0] rs2;


	assign { 	rv64i_lui, rv64i_auipc, 
				rv64i_jal, rv64i_jalr, rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu, 
				rv64i_lb, rv64i_lh, rv64i_lw, rv64i_lbu, rv64i_lhu, rv64i_lwu, rv64i_ld,
				rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
				rv64i_addi, rv64i_addiw, rv64i_slti, rv64i_sltiu, rv64i_xori, rv64i_ori, rv64i_andi, rv64i_slli, rv64i_slliw, rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw,
				rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu, rv64i_xor, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, rv64i_or, rv64i_and,
				rv64i_fence, rv64zi_fence_i,
				rv64i_ecall, rv64i_ebreak, rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci
			} = decode_microInstr;







	assign alu_issue_vaild = rv64i_lui | rv64i_auipc 
							| rv64i_addi | rv64i_addiw | rv64i_add | rv64i_addw | rv64i_sub | rv64i_subw 
							| rv64i_slti | rv64i_sltiu | rv64i_slli | rv64i_slliw | rv64i_sll | rv64i_sllw | rv64i_slt | rv64i_sltu
							| rv64i_srli | rv64i_srliw | rv64i_srai | rv64i_sraiw | rv64i_srl | rv64i_srlw | rv64i_sra | rv64i_sraw 
							| rv64i_xori | rv64i_ori | rv64i_andi | rv64i_xor | rv64i_or | rv64i_and;



	assign alu_issue_info = { 	rv64i_lui, rv64i_auipc, 
								rv64i_addi, rv64i_addiw, rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw,
								rv64i_slti, rv64i_sltiu, rv64i_slli, rv64i_slliw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu,
								rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, 
								rv64i_xori, rv64i_ori, rv64i_andi, rv64i_xor, rv64i_or, rv64i_and,
								dispat_pc, imm, shamt, rd0, rs1, rs2
								};








	assign lsu_issue_vaild = rv64i_lb | rv64i_lh | rv64i_lw | rv64i_lbu | rv64i_lhu | rv64i_lwu | rv64i_ld | rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	
	assign lsu_issue_info = {
							rv64i_lb, rv64i_lh, rv64i_lw, rv64i_lbu, rv64i_lhu, rv64i_lwu, rv64i_ld, rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
							dispat_pc, imm, rd0, rs1, rs2
							}




	assign csr_issue_vaild = rv64csr_rw | rv64csr_rs | rv64csr_rc | rv64csr_rwi | rv64csr_rsi | rv64csr_rci;
	
	assign csr_issue_info = {
								rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
								dispat_pc, imm[11:0], rd0, rs1
							}


	assign blu_issue_vaild = rv64i_jal | rv64i_jalr | rv64i_beq | rv64i_bne | rv64i_blt | rv64i_bge | rv64i_bltu | rv64i_bgeu;
	assign blu_issue_info = {
								rv64i_jal, rv64i_jalr, rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu,
								dispat_pc, imm, rd0, rs1, rs2
							}




	assign oth_issue_vaild = {
								rv64i_fence | rv64zi_fence_i
								| rv64i_ecall | rv64i_ebreak
								};		

	assign oth_issue_info = {	rv64i_fence, rv64zi_fence_i,
								rv64i_ecall, rv64i_ebreak,
								dispat_pc, imm, rd0, rs1, rs2
							}









endmodule







