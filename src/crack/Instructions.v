/*
* @File name: Instructions
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-08-18 17:02:25
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-10 16:42:16
*/













module decoder (
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	

	input  [31:0] instr_i,
);


	wire rv64i_instr;
	wire [6:0] opcode = instr_i[6:0];

	wire opcode_xxxxx00 = (opcode[1:0] == 2'b00);
	wire opcode_xxxxx01 = (opcode[1:0] == 2'b01);
	wire opcode_xxxxx10 = (opcode[1:0] == 2'b10);
	wire opcode_xxxxx11 = (opcode[1:0] == 2'b11);

	wire opcode_xx000xx = (opcode[4:2] == 3'b000);
	wire opcode_xx001xx = (opcode[4:2] == 3'b001);
	wire opcode_xx010xx = (opcode[4:2] == 3'b010);
	wire opcode_xx011xx = (opcode[4:2] == 3'b011);
	wire opcode_xx100xx = (opcode[4:2] == 3'b100);
	wire opcode_xx101xx = (opcode[4:2] == 3'b101);
	wire opcode_xx110xx = (opcode[4:2] == 3'b110);
	wire opcode_xx111xx = (opcode[4:2] == 3'b111);

	wire opcode_00xxxxx = (opcode[6:5] == 2'b00);
	wire opcode_01xxxxx = (opcode[6:5] == 2'b01);
	wire opcode_10xxxxx = (opcode[6:5] == 2'b10);
	wire opcode_11xxxxx = (opcode[6:5] == 2'b11);

	wire instr32 = (~opcode_xx111xx) & opcode_xxxxx11;

	wire op_load 		= opcode_00xxxxx & opcode_xx000xx & opcode_xxxxx11;
	// wire op_load_fp 	= opcode_00xxxxx & opcode_xx001xx & opcode_xxxxx11;
	// wire op_custom_0 	= opcode_00xxxxx & opcode_xx010xx & opcode_xxxxx11;
	wire op_misc_mem 	= opcode_00xxxxx & opcode_xx011xx & opcode_xxxxx11;
	wire op_op_imm 		= opcode_00xxxxx & opcode_xx100xx & opcode_xxxxx11;
	wire op_auipc 		= opcode_00xxxxx & opcode_xx101xx & opcode_xxxxx11;
	wire op_op_imm32 	= opcode_00xxxxx & opcode_xx110xx & opcode_xxxxx11;

	wire op_store 		= opcode_01xxxxx & opcode_xx000xx & opcode_xxxxx11;
	// wire op_store_fp 	= opcode_01xxxxx & opcode_xx001xx & opcode_xxxxx11;
	// wire op_custom_1 	= opcode_01xxxxx & opcode_xx010xx & opcode_xxxxx11;
	// wire op_amo		 	= opcode_01xxxxx & opcode_xx011xx & opcode_xxxxx11;
	wire op_op 			= opcode_01xxxxx & opcode_xx100xx & opcode_xxxxx11;
	wire op_lui 		= opcode_01xxxxx & opcode_xx101xx & opcode_xxxxx11;
	wire op_op_32 		= opcode_01xxxxx & opcode_xx110xx & opcode_xxxxx11;

	wire op_madd 		= opcode_10xxxxx & opcode_xx000xx & opcode_xxxxx11;
	wire op_msub	 	= opcode_10xxxxx & opcode_xx001xx & opcode_xxxxx11;
	wire op_nmsub	 	= opcode_10xxxxx & opcode_xx010xx & opcode_xxxxx11;
	wire op_NMADD		= opcode_10xxxxx & opcode_xx011xx & opcode_xxxxx11;
	// wire op_op_fp 		= opcode_10xxxxx & opcode_xx100xx & opcode_xxxxx11;
	// wire op_reserved 	= opcode_10xxxxx & opcode_xx101xx & opcode_xxxxx11;
	// wire op_custom_2	= opcode_10xxxxx & opcode_xx110xx & opcode_xxxxx11;

	wire op_branch 		= opcode_11xxxxx & opcode_xx000xx & opcode_xxxxx11;
	wire op_jalr	 	= opcode_11xxxxx & opcode_xx001xx & opcode_xxxxx11;
	// wire op_reserved 	= opcode_11xxxxx & opcode_xx010xx & opcode_xxxxx11;
	wire op_jal			= opcode_11xxxxx & opcode_xx011xx & opcode_xxxxx11;
	wire op_system 		= opcode_11xxxxx & opcode_xx100xx & opcode_xxxxx11;
	// wire op_reserved 	= opcode_11xxxxx & opcode_xx101xx & opcode_xxxxx11;
	// wire op_custom_3	= opcode_11xxxxx & opcode_xx110xx & opcode_xxxxx11;








endmodule


















