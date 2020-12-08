/*
* @File name: decoder16
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-08-18 17:02:25
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-08 19:47:12
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

`timescale 1 ns / 1 ps
`include "define.vh"


module decoder16 
	(

	input [15:0] instr,
	input fetch_decode_vaild,
	input [63:0] pc,
	input is_rvc,

	input instrFifo_full,
	output [`DECODE_INFO_DW-1:0] decode_microInstr,
	output instrFifo_push

);
//RV64I + RV64ZIfencei +RV64ZICSR + isRVC+  pc + imm + shamt+rd0+rs1+rs2






	wire [15:0] instr_16 = instr;


	wire [1:0] opcode = instr_16[1:0];
	wire [2:0] funct3 = instr_16[15:13]

	wire opcode_00 = opcode == 2'b00;
	wire opcode_01 = opcode == 2'b01;	
	wire opcode_10 = opcode == 2'b10;

	wire funct3_000 = funct3 == 3'b000;
	wire funct3_001 = funct3 == 3'b001;
	wire funct3_010 = funct3 == 3'b010;
	wire funct3_011 = funct3 == 3'b011;
	wire funct3_100 = funct3 == 3'b100;
	wire funct3_101 = funct3 == 3'b101;
	wire funct3_110 = funct3 == 3'b110;
	wire funct3_111 = funct3 == 3'b111;

	wire [4:0] rd0;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [63:0] imm;



wire ADDI4SPN = opcode_00 & funct3_000;
wire LW = opcode_00 & funct3_010;
wire LD       = opcode_00 & funct3_011;
wire SW       = opcode_00 & funct3_110;
wire SD       = opcode_00 & funct3_111;

wire NOP = opcode_01 & funct3_000 & (&(~instr_16[12:2]));
wire ADDI = opcode_01 & funct3_000 & (|instr_16[11:7]);
wire ADDIW = opcode_01 & funct3_001 & (|instr_16[11:7]);

wire LI = opcode_01 & funct3_010 & (|instr_16[11:7]);

wire ADDI16SP = opcode_01 & funct3_011 & (instr_16[11:7] == 5'd2);
wire LUI = opcode_01 & funct3_011 & (instr_16[11:7] != 5'd2 | instr_16[11:7] != 5'd0);

wire SRLI = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b00) & ( | {instr_16[12,instr_16[6:2]]} );
wire SRLI64 = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b00) & ( &(~{instr_16[12,instr_16[6:2]]}) );
wire SRAI = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b01) & ( | {instr_16[12,instr_16[6:2]]} );
wire SRAI64 = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b01) & ( &(~{instr_16[12,instr_16[6:2]]}) );
wire ANDI = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b10);
wire SUB = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & ~instr_16[12] & (instr_16[6:5] == 2'b00);
wire XOR = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & ~instr_16[12] & (instr_16[6:5] == 2'b01);
wire OR = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & ~instr_16[12] & (instr_16[6:5] == 2'b10);
wire AND = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & ~instr_16[12] & (instr_16[6:5] == 2'b11);
wire SUBW = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & instr_16[12] & (instr_16[6:5] == 2'b00);
wire ADDW = opcode_01 & funct3_100 & (instr_16[11:10] == 2'b11) & instr_16[12] & (instr_16[6:5] == 2'b01);

wire J = opcode_01 & funct3_101;

wire BEQZ       = opcode_01 & funct3_110;
wire BNEZ       = opcode_01 & funct3_111;

wire SLLI = opcode_10 & funct3_000 & (|instr_16[11:7]) & ( | {instr_16[12,instr_16[6:2]]} );
wire SLLI64 = opcode_10 & funct3_000 & (|instr_16[11:7]) & ( & (~{instr_16[12,instr_16[6:2]]}) );

wire LWSP = opcode_10 & funct3_010 & (|instr_16[11:7]);
wire LDSP = opcode_10 & funct3_011 & (|instr_16[11:7]);

wire JR = opcode_10 & funct3_100 & ~instr_16[12] & (instr_16[6:2] == 0);
wire MV = opcode_10 & funct3_100 & ~instr_16[12] & (| instr_16[6:2]);
wire EBREAK = opcode_10 & funct3_100 & (instr_16[12:2] == 11'b10000000000);
wire JALR = opcode_10 & funct3_100 & instr_16[12] & (|instr_16[11:7]) & (&(~instr_16[6:2]));
wire ADD = opcode_10 & funct3_100 & instr_16[12] & (|instr_16[11:7]) & (| instr_16[6:2]);

wire SWSP = opcode_10 & funct3_110;
wire SDSP = opcode_10 & funct3_111;

assign rd0 = ({5{SW | SD}} & 5'd0)
			|
			({5{ADDI4SPN | LW | LD}} & {2'b01,instr_16[4:2]} )
			|
			( {5{ADDI|ADDIW|LI|SLLI|LWSP|LDSP|}} & {instr_16[11:7]} )
			|
			({5{}} & {2'b01, instr_16[9:7]})


assign rs1 = ({5{ADDI4SPN}} & 5'd2)
			|
			({5{LW | LD | SW | SD | MISCALU | BEQZ | BNEZ}} & {2'b01, instr_16[9:7]})
			|
			({5{}} & instr_16[11:7])

assign rs2 = ( {5{SW | ( MISCALU & (instr_16[11:10]==2'B11) ) }} &  {2'b01,instr_16[4:2]} )
			|
			({5{}}& instr_16[6:2]);


assign imm = ({64{ADDI4SPN}} & {54'b0, instr_16[10:7],instr_16[12:11],instr_16[5],instr_16[6],2'b0})
			|
			({64{LW | SW}} & {'b0, instr_16[5],instr_16[12:10], instr_16[6],2'b0})
			|
			({64{LD | SD}} & {'b0, instr_16[6:5],instr_16[12:10], 3'b0})



	wire rv64i_lui 		= 
	wire rv64i_auipc 	= 
	wire rv64i_jal 		= 
	wire rv64i_jalr 	= 

	wire rv64i_beq 		= 
	wire rv64i_bne 		= 
	wire rv64i_blt 		= 
	wire rv64i_bge 		= 
	wire rv64i_bltu 	= 	
	wire rv64i_bgeu 	= 

	wire rv64i_lb 		= 
	wire rv64i_lh 		= 
	wire rv64i_lw 		= LW;
	wire rv64i_lbu 		= 
	wire rv64i_lhu 		= 
	wire rv64i_lwu 		= 
	wire rv64i_ld 		= LD;

	wire rv64i_sb 		= 
	wire rv64i_sh 		= 
	wire rv64i_sw 		= SW;
	wire rv64i_sd 		= SD;

	wire rv64i_addi 	= (ADDI4SPN & (|instr_16[12:5]))
						| (ADDI & (instr_16[12:2] == 11'd0))
						| (ADDI & (|instr_16[11:7]));
	wire rv64i_addiw 	= 
	wire rv64i_slti 	= 
	wire rv64i_sltiu 	= 
	wire rv64i_xori 	= 
	wire rv64i_ori 		= 
	wire rv64i_andi 	= 
	wire rv64i_slli 	= 
	wire rv64i_slliw 	= 
	wire rv64i_srli 	= 
	wire rv64i_srliw 	= 
	wire rv64i_srai 	= 
	wire rv64i_sraiw 	= 

	wire rv64i_add 		= 
	wire rv64i_addw 	= 
	wire rv64i_sub 		= 
	wire rv64i_subw 	= 
	wire rv64i_sll 		= 
	wire rv64i_sllw 	= 
	wire rv64i_slt 		= 
	wire rv64i_sltu 	= 
	wire rv64i_xor 		= 
	wire rv64i_srl 		= 
	wire rv64i_srlw 	= 
	wire rv64i_sra 		= 
	wire rv64i_sraw 	= 
	wire rv64i_or 		= 
	wire rv64i_and 		= 

	wire rv64i_fence 	= 
	wire rv64zi_fence_i = 


	wire rv64csr_rw 	= 
	wire rv64csr_rs 	= 
	wire rv64csr_rc 	= 
	wire rv64csr_rwi 	= 
	wire rv64csr_rsi 	= 
	wire rv64csr_rci 	= 

	wire rv64i_ecall 	= 
	wire rv64i_ebreak 	= 


	wire privil_mret 	= 




	wire rType = rv64i_add | rv64i_addw | rv64i_sub | rv64i_subw | rv64i_sll | rv64i_sllw | rv64i_slt | rv64i_sltu 
					| rv64i_xor | rv64i_srl | rv64i_srlw | rv64i_sra | rv64i_sraw | rv64i_or | rv64i_and;
	wire iType = rv64i_jalr 
					| rv64i_lb | rv64i_lh | rv64i_lw | rv64i_lbu | rv64i_lhu | rv64i_lwu | rv64i_ld
					| rv64i_addi | rv64i_addiw | rv64i_slti | rv64i_sltiu | rv64i_xori | rv64i_ori | rv64i_andi
					| rv64i_fence | rv64zi_fence_i
					| rv64csr_rw | rv64csr_rs | rv64csr_rc | rv64csr_rwi | rv64csr_rsi | rv64csr_rci;
	wire sType = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	wire bType = rv64i_beq | rv64i_bne | rv64i_blt | rv64i_bge | rv64i_bltu | rv64i_bgeu;
	wire uType = rv64i_lui | op_auipc;
	wire jType = op_jal;

	wire [63:0] imm = 64'b0
					| {64{iType}} & iType_imm
					| {64{sType}} & sType_imm
					| {64{bType}} & bType_imm
					| {64{uType}} & uType_imm
					| {64{jType}} & jType_imm;



	wire [5:0] shamt = instr_32[25:20];


 

	assign decode_microInstr = 
		{ rv64i_lui, rv64i_auipc, rv64i_jal, rv64i_jalr,
		rv64i_beq, rv64i_bne, rv64i_blt, rv64i_bge, rv64i_bltu, rv64i_bgeu, 
		rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
		rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
		rv64i_addi, rv64i_addiw, rv64i_slti, rv64i_sltiu, rv64i_xori, rv64i_ori, rv64i_andi, rv64i_slli, rv64i_slliw, rv64i_srli, rv64i_srliw, rv64i_srai, rv64i_sraiw,
		rv64i_add, rv64i_addw, rv64i_sub, rv64i_subw, rv64i_sll, rv64i_sllw, rv64i_slt, rv64i_sltu, rv64i_xor, rv64i_srl, rv64i_srlw, rv64i_sra, rv64i_sraw, rv64i_or, rv64i_and,
		rv64i_fence, rv64zi_fence_i,
		rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
		rv64i_ecall, rv64i_ebreak, privil_mret,
		is_rvc,
		pc, imm, shamt, rd0,rs1,rs2
		};




	assign instrFifo_push = fetch_decode_vaild & ~instrFifo_full;


endmodule


















