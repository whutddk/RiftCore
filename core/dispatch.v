/*
* @File name: dispatch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-23 17:41:28
*/



module dispatch (


	wire [63:0] imm,
	wire [5:0] shamt,
	wire [4:0] rd,
	wire [4:0] rs1,
	wire [4:0] rs2,

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


wire alu_fun = dispatch_vaild &
wire lsu_fun = dispatch_vaild &
wire csr_fun = dispatch_vaild &
wire blu_fun = dispatch_vaild &


wire alu_issue_vaild = alu_issue_ready & alu_fun;
wire lsu_issue_vaild = lsu_issue_ready & lsu_fun;
wire csr_issue_vaild = csr_issue_ready & csr_fun;
wire blu_issue_vaild = blu_issue_ready & blu_fun;

assign dispatch_ready = alu_issue_vaild | lsu_issue_vaild | csr_issue_vaild | blu_issue_vaild;



endmodule







