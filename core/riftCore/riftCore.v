/*
* @File name: riftCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-18 16:41:02
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
`include "iverilog.vh"
module riftCore (
	
	input isExternInterrupt,
	input isRTimerInterrupt,
	input isSoftwvInterrupt,

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

wire istakenBranch;
wire takenBranch_vaild;

wire [63:0] privileged_pc;
wire privileged_vaild;


wire isMisPredict_dnxt = (feflush & beflush & 1'b0)
						| (~feflush & beflush & 1'b0)
						| (feflush & ~beflush & 1'b1)
						| (~feflush & ~beflush & isMisPredict_qout);
wire isMisPredict_qout;


frontEnd i_frontEnd(

	.instrFifo_full(instrFifo_full&(~feflush)),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr(decode_microInstr_push),

	.flush(feflush),

	.bru_res_vaild(takenBranch_vaild&~isMisPredict_qout),
	.bru_takenBranch(istakenBranch),

	.jalr_vaild(jalr_vaild&(~isMisPredict_qout)),
	.jalr_pc(jalr_pc),

	.privileged_pc(privileged_pc),
	.privileged_vaild(privileged_vaild),

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

		.flush(feflush),
		.CLK(CLK),
		.RSTn(RSTn)
);



backEnd i_backEnd(
	.decode_microInstr_pop(decode_microInstr_pop),
	.instrFifo_pop(instrFifo_pop),
	.instrFifo_empty(instrFifo_empty | isMisPredict_qout),

	// to pcGen
	.jalr_vaild_qout(jalr_vaild),
	.jalr_pc_qout(jalr_pc),
	.isMisPredict(isMisPredict_qout),

	.takenBranch_qout(istakenBranch),
	.takenBranch_vaild_qout(takenBranch_vaild),

	.isFlush(beflush),

	.isExternInterrupt(isExternInterrupt),
	.isRTimerInterrupt(isRTimerInterrupt),
	.isSoftwvInterrupt(isSoftwvInterrupt),

	.privileged_pc(privileged_pc),
	.privileged_vaild(privileged_vaild),

	.CLK(CLK),
	.RSTn(RSTn)

);





gen_dffr # (.DW(1)) isFlush ( .dnxt(isMisPredict_dnxt), .qout(isMisPredict_qout), .CLK(CLK), .RSTn(RSTn));

endmodule














