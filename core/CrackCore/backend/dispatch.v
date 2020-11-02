/*
* @File name: dispatch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 19:23:01
*/



module dispatch (

	//for rename

	output [ RNBIT*32 - 1 :0 ] rnAct_X_dnxt,
	input [ RNBIT*32 - 1 :0 ] rnAct_X_qout,

	output [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	input [32*RNDEPTH-1 : 0] rnBufU_qout,



	input [DECODE_INFO_DW-1:0] decode_microInstr_pop,
	output instrFifo_pop,
	input instrFifo_empty,


	output dispat_vaild,
	input reOrder_ready,
	input issueS_ready,

	output [:] reOrder_info_push,
	output [:] dispat_instr_info,



	output adder_issue_vaild,
	input adder_issue_ready,
	output [:] adder_issue_info,

	output logCmp_issue_vaild,
	input logCmp_issue_ready,
	output [:] logCmp_issue_info,

	output shift_issue_vaild,
	input shift_issue_ready,
	output [:] shift_issue_info,

	output jal_issue_vaild,
	input jal_issue_ready,
	output [:] jal_issue_info,


	output bru_issue_vaild,
	input bru_issue_ready,
	output [:] bru_issue_info,

	output su_issue_vaild,
	input su_issue_ready,
	output [:] su_issue_info,

	output lu_issue_vaild,
	input lu_issue_ready,
	output [:] lu_issue_info,

	output fence_execute_ready,
	input fence_execute_vaild,
	input [ :0] fence_execute_info,


	output csr_issue_vaild,
	input csr_issue_ready,
	output [:] csr_issue_info,



);


wire [4:0] rd0_raw;
wire [4:0] rs1_raw;
wire [4:0] rs2_raw;

wire [RNBIT-1:0] rs1_reName;
wire [RNBIT-1:0] rs2_reName;
wire [RNBIT-1:0] rd0_reName;




wire [] renaming_instr_info;
wire [] dispatch_instr_info;




assign {} = dispatch_instr;


assign reOrder_info_push = {dispat_pc, rd0, branch, ex0};










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

	wire is_rvc;




	wire [63:0] dispatch_pc;
	wire [63:0] imm;
	wire [5:0] shamt;
	wire [5+RNBIT-1:0:0] rd0;
	wire [5+RNBIT-1:0:0] rs1;
	wire [5+RNBIT-1:0:0] rs2;


	assign { 	rv64i_lui, rv64i_auipc, 
				rv64i_jal, rv64i_jalr, rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu, 
				rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
				rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
				rv64i_addi, rv64i_addiw, rv64i_slti, rv64i_sltiu, rv64i_xori, rv64i_ori, rv64i_andi, rv64i_slli, rv64i_slliw, rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw,
				rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu, rv64i_xor, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, rv64i_or, rv64i_and,
				rv64i_fence, rv64zi_fence_i,
				rv64i_ecall, rv64i_ebreak, rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
				is_rvc,
				pc, imm, shamt, rd0_raw, rs1_raw, rs2_raw
			} = decode_microInstr_pop;








	assign adder_issue_vaild = rv64i_lui | rv64i_auipc 
							| rv64i_addi | rv64i_addiw | rv64i_add | rv64i_addw | rv64i_sub | rv64i_subw ;
	assign adder_issue_info = { rv64i_lui, rv64i_auipc, 
								rv64i_addi, rv64i_addiw, rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw,
								dispat_pc, imm, rd0_reName, rs1_reName, rs2_reName
								};









	assign logCmp_issue_vaild = rv64i_slti | rv64i_sltiu | rv64i_slt | rv64i_sltu
								| rv64i_xori | rv64i_ori | rv64i_andi | rv64i_xor | rv64i_or | rv64i_and;
	assign logCmp_issue_info = { 
								rv64i_slti, rv64i_sltiu, rv64i_slt, rv64i_sltu,
								rv64i_xori, rv64i_ori, rv64i_andi, rv64i_xor, rv64i_or, rv64i_and,
								dispat_pc, imm, rd0_reName, rs1_reName, rs2_reName
								};



	assign shift_issue_vaild =  rv64i_slli | rv64i_slliw | rv64i_sll | rv64i_sllw
								| rv64i_srli | rv64i_srliw | rv64i_srl | rv64i_srlw
								| rv64i_srai | rv64i_sraiw | rv64i_sra | rv64i_sraw;
							

	assign shift_issue_info = { 
								rv64i_slli, rv64i_slliw, rv64i_sll, rv64i_sllw,
								rv64i_srli, rv64i_srliw, rv64i_srl, rv64i_srlw,
								rv64i_srai, rv64i_sraiw, rv64i_sra, rv64i_sraw,
								dispat_pc, imm, shamt, rd0_reName, rs1_reName, rs2_reName
								};





	assign jal_issue_vaild = rv64i_jal | rv64i_jalr;
	assign jal_issue_info = {
								rv64i_jal, rv64i_jalr,
								dispat_pc, imm, rd0_reName, rs1_reName,
								is_rvc
							};


	assign blu_issue_vaild = rv64i_beq | rv64i_bne | rv64i_blt | rv64i_bge | rv64i_bltu | rv64i_bgeu;
	assign blu_issue_info = {
								rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu,
								rs1, rs2
							};



	assign lu_issue_vaild = rv64i_lb | rv64i_lh | rv64i_lw | rv64i_ld | rv64i_lbu | rv64i_lhu | rv64i_lwu;
	assign lu_issue_info = { 
							rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu, 
							imm,
							rd0_reName,
							rs1_reName
							};



	assign su_issue_vaild = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	assign su_issue_info = {
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
								imm,
								rs1_reName,
								rs2_reName
								};

	assign fence_execute_vaild = rv64zi_fence_i | rv64i_fence;
	assign fence_execute_info = {
								rv64zi_fence_i, rv64i_fence,
								fence_imm
								};


	assign csr_issue_vaild = rv64csr_rw | rv64csr_rs | rv64csr_rc | rv64csr_rwi | rv64csr_rsi | rv64csr_rci;
	assign csr_issue_info = {
								rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
								imm[11:0], rd0_reName, rs1_reName
							}





wire rd0_raw_vaild = adder_issue_vaild
					| logCmp_issue_vaild
					| shift_issue_vaild
					| jal_issue_vaild
					| lu_issue_vaild
					| csr_issue_vaild;

rename i_rename(

	.rnAct_X_dnxt(rnAct_X_dnxt),
	.rnAct_X_qout(rnAct_X_qout),	

	.rnBufU_rename_set(rnBufU_rename_set),
	.rnBufU_qout(rnBufU_qout),

	.rs1_raw(rs1_raw),
	.rs1_reName(rs1_reName),

	.rs2_raw(rs2_raw),
	.rs2_reName(rs2_reName),
	
	.rd0_raw_vaild(rd0_raw_vaild),
	.rd0_raw(rd0_raw),
	.rd0_reName(rd0_reName),
	output rd0_runOut

);




endmodule







