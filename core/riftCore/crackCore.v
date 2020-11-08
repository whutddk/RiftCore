/*
* @File name: crackCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-08 14:54:36
*/

`timescale 1 ns / 1 ps

`include "define.vh"
`include "iverilog.vh"
module crackCore (
	
	input CLK,
	input RSTn
	
);


wire instrFifo_push;
wire instrFifo_full;
wire [`DECODE_INFO_DW-1:0] decode_microInstr_push;

wire feflush;
wire beflush;

wire [`DECODE_INFO_DW-1:0] decode_microInstr_pop;
wire instrFifo_pop;
wire instrFifo_empty;
wire jalr_vaild;
wire [63:0] jalr_pc;

wire pcGen_ready;
wire istakenBranch;
wire takenBranch_vaild;

wire isMisPredict_dnxt = (feflush & beflush & isMisPredict_qout)
						| (~feflush & beflush & 1'b0)
						| (feflush & ~beflush & 1'b1);
wire isMisPredict_qout;


frontEnd i_frontEnd(

	.instrFifo_full(instrFifo_full),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr(decode_microInstr_push),

	.isMisPredict(feflush),
	.pcGen_ready(pcGen_ready),

	.bru_res_vaild(takenBranch_vaild&~isMisPredict_qout),
	.bru_takenBranch(istakenBranch),

	.jalr_vaild(jalr_vaild&(~isMisPredict_qout)),
	.jalr_pc(jalr_pc),

	.CLK(CLK),
	.RSTn(RSTn)
	
);


gen_fifo # (.DW(`DECODE_INFO_DW),.AW(4)) 
	instr_fifo (
		.fifo_pop(instrFifo_pop),
		.fifo_push(instrFifo_push),

		.data_push(decode_microInstr_push),
		.data_pop(decode_microInstr_pop),

		.fifo_empty(instrFifo_empty),
		.fifo_full(instrFifo_full),

		.CLK(CLK),
		.RSTn(RSTn&~feflush)
);



backEnd i_backEnd(
	.decode_microInstr_pop(decode_microInstr_pop),
	.instrFifo_pop(instrFifo_pop),
	.instrFifo_empty(instrFifo_empty | isMisPredict_qout),

	// to pcGen
	.jalr_vaild_qout(jalr_vaild),
	.jalr_pc_qout(jalr_pc),
	.isMisPredict(isMisPredict_qout),

	.pcGen_ready(pcGen_ready),
	.takenBranch_qout(istakenBranch),
	.takenBranch_vaild_qout(takenBranch_vaild),

	.isFlush(beflush),

	.CLK(CLK),
	.RSTn(RSTn)

);





gen_dffr # (.DW(1)) isFlush ( .dnxt(isMisPredict_dnxt), .qout(isMisPredict_qout), .CLK(CLK), .RSTn(RSTn));

endmodule














