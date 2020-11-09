/*
* @File name: dispatch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-09 16:05:18
*/

`timescale 1 ns / 1 ps
`include "define.vh"

module dispatch (

	//for rename
	output [ `RB*32 - 1 :0 ] rnAct_X_dnxt,
	input [ `RB*32 - 1 :0 ] rnAct_X_qout,

	output [32*`RP-1 : 0] rnBufU_rename_set,
	input [32*`RP-1 : 0] rnBufU_qout,


	//from instr fifo
	input [`DECODE_INFO_DW-1:0] decode_microInstr_pop,
	output instrFifo_pop,
	input instrFifo_empty,

	output [`REORDER_INFO_DW-1:0] dispat_info,
	output reOrder_fifo_push,
	input reOrder_fifo_full,

	//to issue
	output adder_buffer_push,
	input adder_buffer_full,
	output [`ADDER_ISSUE_INFO_DW-1:0] adder_dispat_info,

	output logCmp_buffer_push,
	input logCmp_buffer_full,
	output [`LOGCMP_ISSUE_INFO_DW-1:0] logCmp_dispat_info,

	output shift_buffer_push,
	input shift_buffer_full,
	output [`SHIFT_ISSUE_INFO_DW-1:0] shift_dispat_info,

	output jal_buffer_push,
	input jal_buffer_full,
	output [`JAL_ISSUE_INFO_DW-1:0] jal_dispat_info,


	output bru_fifo_push,
	input bru_fifo_full,
	output [`BRU_ISSUE_INFO_DW-1:0] bru_dispat_info,

	output su_fifo_push,
	input su_fifo_full,
	output [`SU_ISSUE_INFO_DW-1:0] su_dispat_info,
	input su_fifo_empty,


	output lu_buffer_push,
	input lu_buffer_full,
	output [`LU_ISSUE_INFO_DW-1:0] lu_dispat_info,
	input [`LU_ISSUE_INFO_DP-1:0] lu_buffer_malloc,

	output csr_fifo_push,
	input csr_fifo_full,
	output [`CSR_ISSUE_INFO_DW-1:0] csr_dispat_info

);


wire [4:0] rd0_raw;
wire [4:0] rs1_raw;
wire [4:0] rs2_raw;

wire [5+`RB-1:0] rs1_reName;
wire [5+`RB-1:0] rs2_reName;
wire [5+`RB-1:0] rd0_reName;

initial $warning("fifo保持最后一个数据可见，先读再pop");
wire dispat_vaild = (~instrFifo_empty) & (~rd0_runOut) & (~reOrder_fifo_full);

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

	wire [63:0] pc;
	wire [63:0] imm;
	wire [5:0] shamt;
	wire rd0_runOut;

	wire fence_dispat;

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


	wire isBranch = rv64i_beq | rv64i_bne | rv64i_blt | rv64i_bge | rv64i_bltu | rv64i_bgeu;
	wire isSu = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	wire isCsr = rv64csr_rw | rv64csr_rs | rv64csr_rc | rv64csr_rwi | rv64csr_rsi | rv64csr_rci;


	assign dispat_info = {pc, rd0_reName, isBranch, isSu, isCsr};
	assign reOrder_fifo_push = adder_buffer_push
								| logCmp_buffer_push
								| shift_buffer_push
								| jal_buffer_push
								| bru_fifo_push
								| su_fifo_push
								| lu_buffer_push
								| fence_dispat
								| csr_fifo_push;
	assign instrFifo_pop = reOrder_fifo_push;



	assign adder_buffer_push = ( rv64i_lui | rv64i_auipc 
									| rv64i_addi | rv64i_addiw | rv64i_add | rv64i_addw | rv64i_sub | rv64i_subw ) & dispat_vaild & (~adder_buffer_full);
	
	assign adder_dispat_info = { rv64i_lui, rv64i_auipc, 
								rv64i_addi, rv64i_addiw, rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw,
								pc, imm, rd0_reName, rs1_reName, rs2_reName
								};


	assign logCmp_buffer_push = ( rv64i_slti | rv64i_sltiu | rv64i_slt | rv64i_sltu
									| rv64i_xori | rv64i_ori | rv64i_andi | rv64i_xor | rv64i_or | rv64i_and ) & dispat_vaild & (~logCmp_buffer_full);

	assign logCmp_dispat_info = { 
								rv64i_slti, rv64i_sltiu, rv64i_slt, rv64i_sltu,
								rv64i_xori, rv64i_ori, rv64i_andi, rv64i_xor, rv64i_or, rv64i_and,
								pc, imm, rd0_reName, rs1_reName, rs2_reName
								};



	assign shift_buffer_push =  ( rv64i_slli | rv64i_slliw | rv64i_sll | rv64i_sllw
									| rv64i_srli | rv64i_srliw | rv64i_srl | rv64i_srlw
									| rv64i_srai | rv64i_sraiw | rv64i_sra | rv64i_sraw ) & dispat_vaild & (~shift_buffer_full);

	assign shift_dispat_info = { 
								rv64i_slli, rv64i_slliw, rv64i_sll, rv64i_sllw,
								rv64i_srli, rv64i_srliw, rv64i_srl, rv64i_srlw,
								rv64i_srai, rv64i_sraiw, rv64i_sra, rv64i_sraw,
								pc, shamt, rd0_reName, rs1_reName, rs2_reName
								};

	assign jal_buffer_push = ( rv64i_jal | rv64i_jalr ) & dispat_vaild & (~jal_buffer_full);
	assign jal_dispat_info = {
								rv64i_jal, rv64i_jalr,
								pc, rd0_reName, rs1_reName,
								is_rvc
							};


	assign bru_fifo_push = (rv64i_beq | rv64i_bne | rv64i_blt | rv64i_bge | rv64i_bltu | rv64i_bgeu) & dispat_vaild & (~bru_fifo_full);
	assign bru_dispat_info = {
								rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu,
								rs1_reName, rs2_reName
							};

	assign csr_fifo_push = ( rv64csr_rw | rv64csr_rs | rv64csr_rc | rv64csr_rwi | rv64csr_rsi | rv64csr_rci ) & dispat_vaild & (~csr_fifo_full);
	assign csr_dispat_info = {
								rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
								pc, imm[11:0], rd0_reName, rs1_reName
							};


	assign lu_buffer_push = ( rv64i_lb | rv64i_lh | rv64i_lw | rv64i_ld | rv64i_lbu | rv64i_lhu | rv64i_lwu ) & dispat_vaild & (~lu_buffer_full);
	assign lu_dispat_info = { 
								rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu, 
								imm,
								rd0_reName,
								rs1_reName
							};



	assign su_fifo_push = (rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd) & dispat_vaild & (~su_fifo_full);
	assign su_dispat_info = {
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
								imm,
								rs1_reName,
								rs2_reName
							};

	assign fence_dispat = (rv64zi_fence_i | rv64i_fence) & dispat_vaild 
							& ~(fencing);

	initial $warning("暂不支持TSO,暂不区分io和memory");
	initial $warning("在派遣阶段做fence将会导致其它计算指令一同被fence");

	wire [3:0] predecessor = imm[7:4];
	wire [3:0] successor = imm[3:0];

	wire fenceS = (successor & 4'b0100) || (successor & 4'b0001);
	wire fenceL = (successor & 4'b1000) || (successor & 4'b0010);
	wire afterS = (predecessor & 4'b0100) || (predecessor & 4'b0001);
	wire afterL = (predecessor & 4'b1000) || (predecessor & 4'b0010);

	wire fence_SAS = rv64i_fence & fenceS & afterS;
	wire fence_SAL = rv64i_fence & fenceS & afterL;
	wire fence_LAS = rv64i_fence & fenceL & afterS;
	wire fence_LAL = rv64i_fence & fenceL & afterL;
	wire fence_ALL = rv64zi_fence_i;

	// wire fence_lu_dispat = ~( fence_LAS & ~su_fifo_empty )
	// 						&
	// 						~( fence_LAL & (| lu_buffer_malloc) )
	// 						& 
	// 						~( fence_ALL & ~su_fifo_empty & (| lu_buffer_malloc) );

	// wire fence_su_dispat = ~(fence_SAS & ~su_fifo_empty)
	// 						&
	// 						~(fence_SAL & (| lu_buffer_malloc))
	// 						&
	// 						~(fence_ALL & ~su_fifo_empty & (|lu_buffer_malloc) );

	wire fencing = ( fence_LAS & ~su_fifo_empty ) 
					| ( fence_LAL & (| lu_buffer_malloc) )
					| (fence_SAS & ~su_fifo_empty)
					| (fence_SAL & (| lu_buffer_malloc))
					| (fence_ALL & ~su_fifo_empty & (|lu_buffer_malloc) );


	wire rd0_raw_vaild = | {rv64i_lui, rv64i_auipc, 
							rv64i_jal, rv64i_jalr, 
							rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
							rv64i_addi, rv64i_addiw, rv64i_slti, rv64i_sltiu, rv64i_xori, rv64i_ori, rv64i_andi, rv64i_slli, rv64i_slliw, rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw,
							rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu, rv64i_xor, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, rv64i_or, rv64i_and,		
							rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci};



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
	.rd0_runOut(rd0_runOut)

);




endmodule







