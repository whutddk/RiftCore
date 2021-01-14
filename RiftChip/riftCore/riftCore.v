/*
* @File name: riftCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-14 15:28:59
*/



/*
  Copyright (c) 2020 - 2021 Ruige Lee <wut.ruigeli@gmail.com>

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
	output ifu_req_kill,
	output ifu_mstReq_valid,
	input ifu_mstReq_ready,
	output [63:0] ifu_addr,
	input [63:0] ifu_data_r,
	input ifu_slvRsp_valid,

	output lsu_req_kill,
	output lsu_mstReq_valid,
	input lsu_mstReq_ready,
	output [63:0] lsu_addr,
	output [63:0] lsu_data_w,
	input [63:0] lsu_data_r,
	output [7:0] lsu_wstrb,
	output lsu_wen,
	input lsu_slvRsp_valid,
	
	input isExternInterrupt,
	input isRTimerInterrupt,
	input isSoftwvInterrupt,



	input CLK,
	input RSTn
	
);


wire instrFifo_push;
wire instrFifo_reject;
wire [`DECODE_INFO_DW-1:0] decode_microInstr_push;

wire feflush;
wire beflush;

wire [`DECODE_INFO_DW-1:0] decode_microInstr_pop;
wire instrFifo_pop;
wire instrFifo_empty;
wire jalr_valid;
wire [63:0] jalr_pc;

wire istakenBranch;
wire takenBranch_valid;

wire [63:0] privileged_pc;
wire privileged_valid;

// wire isMisPredict_dnxt = (feflush & beflush & 1'b0)
// 						| (~feflush & beflush & 1'b0)
// 						| (feflush & ~beflush & 1'b1)
// 						| (~feflush & ~beflush & isMisPredict_qout);

wire isMisPredict_set;
wire isMisPredict_rst;
wire isMisPredict_qout;

assign isMisPredict_rst = beflush;
assign isMisPredict_set = feflush & ~beflush;






frontEnd i_frontEnd(

	.instrFifo_reject(instrFifo_reject),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr(decode_microInstr_push),

	.bru_res_valid(takenBranch_valid&~isMisPredict_qout),
	.bru_takenBranch(istakenBranch),

	.jalr_valid(jalr_valid&(~isMisPredict_qout)),
	.jalr_pc(jalr_pc),

	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

	.ifu_req_kill(ifu_req_kill),
	.ifu_mstReq_valid(ifu_mstReq_valid),
	.ifu_mstReq_ready(ifu_mstReq_ready),
	.ifu_addr(ifu_addr),
	.ifu_data_r(ifu_data_r),
	.ifu_slvRsp_valid(ifu_slvRsp_valid),

	.flush(feflush),
	.CLK(CLK),
	.RSTn(RSTn)
	
);



instr_fifo #(.DW(`DECODE_INFO_DW),.AW(3)) i_instr_fifo(

	.instrFifo_pop(instrFifo_pop),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr_push(decode_microInstr_push),

	.instrFifo_empty(instrFifo_empty),
	.instrFifo_reject(instrFifo_reject), 
	.decode_microInstr_pop(decode_microInstr_pop),

	.feflush(feflush),
	.CLK(CLK),
	.RSTn(RSTn)
);



backEnd i_backEnd(
	.lsu_req_kill(lsu_req_kill),
	.lsu_mstReq_valid(lsu_mstReq_valid),
	.lsu_mstReq_ready(lsu_mstReq_ready),
	.lsu_addr(lsu_addr),
	.lsu_data_w(lsu_data_w),
	.lsu_data_r(lsu_data_r),
	.lsu_wstrb(lsu_wstrb),
	.lsu_wen(lsu_wen),
	.lsu_slvRsp_valid(lsu_slvRsp_valid),

	.decode_microInstr_pop(decode_microInstr_pop),
	.instrFifo_pop(instrFifo_pop),
	.instrFifo_empty(instrFifo_empty | isMisPredict_qout),

	// to pcGen
	.jalr_valid_qout(jalr_valid),
	.jalr_pc_qout(jalr_pc),
	.isMisPredict(isMisPredict_qout),

	.takenBranch_qout(istakenBranch),
	.takenBranch_valid_qout(takenBranch_valid),

	.isFlush(beflush),

	.isExternInterrupt(isExternInterrupt),
	.isRTimerInterrupt(isRTimerInterrupt),
	.isSoftwvInterrupt(isSoftwvInterrupt),

	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

	.CLK(CLK),
	.RSTn(RSTn)

);





gen_rsffr # (.DW(1)) isFlush_rs ( .set_in(isMisPredict_set), .rst_in(isMisPredict_rst), .qout(isMisPredict_qout), .CLK(CLK), .RSTn(RSTn));

endmodule














