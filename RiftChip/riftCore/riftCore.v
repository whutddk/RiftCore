/*
* @File name: riftCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-18 17:53:42
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

module riftCore (
	output [63:0] IFU_ARADDR,
	output [2:0] IFU_ARPROT,
	output IFU_ARVALID,
	input IFU_ARREADY,
	input [63:0] IFU_RDATA,
	input [1:0] IFU_RRESP,
	input IFU_RVALID,
	output IFU_RREADY,

	output [63:0] LSU_AWADDR,
	output [2:0] LSU_AWPROT,
	output LSU_AWVALID,
	input LSU_AWREADY,
	output [63:0] LSU_WDATA,
	output [7:0] LSU_WSTRB,
	output LSU_WVALID,
	input LSU_WREADY,
	input [1:0] LSU_BRESP,
	input LSU_BVALID,
	output LSU_BREADY,
	output [63:0] LSU_ARADDR,
	output [2:0] LSU_ARPROT,
	output LSU_ARVALID,
	input LSU_ARREADY,
	input [63:0] LSU_RDATA,
	input [1:0] LSU_RRESP,
	input LSU_RVALID,
	output LSU_RREADY,
	
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
	.IFU_ARADDR(IFU_ARADDR),
	.IFU_ARPROT(IFU_ARPROT),
	.IFU_ARVALID(IFU_ARVALID),
	.IFU_ARREADY(IFU_ARREADY),
	.IFU_RDATA(IFU_RDATA),
	.IFU_RRESP(IFU_RRESP),
	.IFU_RVALID(IFU_RVALID),
	.IFU_RREADY(IFU_RREADY),

	.instrFifo_reject(instrFifo_reject),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr(decode_microInstr_push),

	.bru_res_valid(takenBranch_valid&~isMisPredict_qout),
	.bru_takenBranch(istakenBranch),

	.jalr_valid(jalr_valid&(~isMisPredict_qout)),
	.jalr_pc(jalr_pc),

	.privileged_pc(privileged_pc),
	.privileged_valid(privileged_valid),

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
	.LSU_AWADDR(LSU_AWADDR),
	.LSU_AWPROT(LSU_AWPROT),
	.LSU_AWVALID(LSU_AWVALID),
	.LSU_AWREADY(LSU_AWREADY),
	.LSU_WDATA(LSU_WDATA),
	.LSU_WSTRB(LSU_WSTRB),
	.LSU_WVALID(LSU_WVALID),
	.LSU_WREADY(LSU_WREADY),
	.LSU_BRESP(LSU_BRESP),
	.LSU_BVALID(LSU_BVALID),
	.LSU_BREADY(LSU_BREADY),
	.LSU_ARADDR(LSU_ARADDR),
	.LSU_ARPROT(LSU_ARPROT),
	.LSU_ARVALID(LSU_ARVALID),
	.LSU_ARREADY(LSU_ARREADY),
	.LSU_RDATA(LSU_RDATA),
	.LSU_RRESP(LSU_RRESP),
	.LSU_RVALID(LSU_RVALID),
	.LSU_RREADY(LSU_RREADY),

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














