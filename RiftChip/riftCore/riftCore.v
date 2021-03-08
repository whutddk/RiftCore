/*
* @File name: riftCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-08 10:56:00
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

	output [0:0] MEM_AWID,
	output [63:0] MEM_AWADDR,
	output [7:0] MEM_AWLEN,
	output [2:0] MEM_AWSIZE,
	output [1:0] MEM_AWBURST,
	output MEM_AWLOCK,
	output [3:0] MEM_AWCACHE,
	output [2:0] MEM_AWPROT,
	output [3:0] MEM_AWQOS,
	output [0:0] MEM_AWUSER,
	output MEM_AWVALID,
	input MEM_AWREADY,

	output [63:0] MEM_WDATA,
	output [7:0] MEM_WSTRB,
	output MEM_WLAST,
	output [0:0] MEM_WUSER,
	output MEM_WVALID,
	input MEM_WREADY,

	input [0:0] MEM_BID,
	input [1:0] MEM_BRESP,
	input [0:0] MEM_BUSER,
	input MEM_BVALID,
	output MEM_BREADY,

	output [0:0] MEM_ARID,
	output [63:0] MEM_ARADDR,
	output [7:0] MEM_ARLEN,
	output [2:0] MEM_ARSIZE,
	output [1:0] MEM_ARBURST,
	output MEM_ARLOCK,
	output [3:0] MEM_ARCACHE,
	output [2:0] MEM_ARPROT,
	output [3:0] MEM_ARQOS,
	output [0:0] MEM_ARUSER,
	output MEM_ARVALID,
	input MEM_ARREADY,

	input [0:0] MEM_RID,
	input [63:0] MEM_RDATA,
	input [1:0] MEM_RRESP,
	input MEM_RLAST,
	input [0:0] MEM_RUSER,
	input MEM_RVALID,
	output MEM_RREADY,



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



wire isMisPredict_set;
wire isMisPredict_rst;
wire isMisPredict_qout;

assign isMisPredict_rst = beflush;
assign isMisPredict_set = feflush & ~beflush;


wire lsu_fencei_valid;


wire ifu_req_valid;
wire ifu_req_ready;
wire [31:0] ifu_addr_req;
wire [63:0] ifu_data_rsp;
wire ifu_rsp_valid;
wire ifu_rsp_ready;




frontEnd i_frontEnd(
	.lsu_fencei_valid(lsu_fencei_valid),

	.ifu_req_valid(ifu_req_valid),
	.ifu_req_ready(ifu_req_ready),
	.ifu_addr_req (ifu_addr_req),
	.ifu_data_rsp (ifu_data_rsp),
	.ifu_rsp_valid(ifu_rsp_valid),
	.ifu_rsp_ready(ifu_rsp_ready),

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

	.lsu_fencei_valid(lsu_fencei_valid),

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





gen_rsffr # (.DW(1)) isFlush_rsffr ( .set_in(isMisPredict_set), .rst_in(isMisPredict_rst), .qout(isMisPredict_qout), .CLK(CLK), .RSTn(RSTn));






	wire lsu_req_valid = 1'b0;
	wire lsu_req_ready;
	wire [31:0] lsu_addr_req = 32'h0;
	wire [63:0] lsu_wdata_req = 64'h0;
	wire [7:0] lsu_wstrb_req = 8'h0;
	wire lsu_wen_req = 1'b0;
	wire [31:0] lsu_rdata_rsp;
	wire lsu_rsp_valid;
	wire lsu_rsp_ready = 1'b1;

	wire il1_fence = 1'b0;
	wire dl1_fence = 1'b0;
	wire dl1_fence_end;
	wire l2c_fence = 1'b0;
	wire l2c_fence_end;
	wire l3c_fence = 1'b0;
	wire l3c_fence_end;




cache i_cache
(
	.ifu_req_valid(ifu_req_valid),
	.ifu_req_ready(ifu_req_ready),
	.ifu_addr_req (ifu_addr_req),
	.ifu_data_rsp (ifu_data_rsp),
	.ifu_rsp_valid(ifu_rsp_valid),
	.ifu_rsp_ready(ifu_rsp_ready),

	.lsu_req_valid(lsu_req_valid),
	.lsu_req_ready(lsu_req_ready),
	.lsu_addr_req (lsu_addr_req),
	.lsu_wdata_req(lsu_wdata_req),
	.lsu_wstrb_req(lsu_wstrb_req),
	.lsu_wen_req  (lsu_wen_req),
	.lsu_rdata_rsp(lsu_rdata_rsp),
	.lsu_rsp_valid(lsu_rsp_valid),
	.lsu_rsp_ready(lsu_rsp_ready),

	.MEM_AWID     (MEM_AWID),
	.MEM_AWADDR   (MEM_AWADDR),
	.MEM_AWLEN    (MEM_AWLEN),
	.MEM_AWSIZE   (MEM_AWSIZE),
	.MEM_AWBURST  (MEM_AWBURST),
	.MEM_AWLOCK   (MEM_AWLOCK),
	.MEM_AWCACHE  (MEM_AWCACHE),
	.MEM_AWPROT   (MEM_AWPROT),
	.MEM_AWQOS    (MEM_AWQOS),
	.MEM_AWUSER   (MEM_AWUSER),
	.MEM_AWVALID  (MEM_AWVALID),
	.MEM_AWREADY  (MEM_AWREADY),
	.MEM_WDATA    (MEM_WDATA),
	.MEM_WSTRB    (MEM_WSTRB),
	.MEM_WLAST    (MEM_WLAST),
	.MEM_WUSER    (MEM_WUSER),
	.MEM_WVALID   (MEM_WVALID),
	.MEM_WREADY   (MEM_WREADY),
	.MEM_BID      (MEM_BID),
	.MEM_BRESP    (MEM_BRESP),
	.MEM_BUSER    (MEM_BUSER),
	.MEM_BVALID   (MEM_BVALID),
	.MEM_BREADY   (MEM_BREADY),
	.MEM_ARID     (MEM_ARID),
	.MEM_ARADDR   (MEM_ARADDR),
	.MEM_ARLEN    (MEM_ARLEN),
	.MEM_ARSIZE   (MEM_ARSIZE),
	.MEM_ARBURST  (MEM_ARBURST),
	.MEM_ARLOCK   (MEM_ARLOCK),
	.MEM_ARCACHE  (MEM_ARCACHE),
	.MEM_ARPROT   (MEM_ARPROT),
	.MEM_ARQOS    (MEM_ARQOS),
	.MEM_ARUSER   (MEM_ARUSER),
	.MEM_ARVALID  (MEM_ARVALID),
	.MEM_ARREADY  (MEM_ARREADY),
	.MEM_RID      (MEM_RID),
	.MEM_RDATA    (MEM_RDATA),
	.MEM_RRESP    (MEM_RRESP),
	.MEM_RLAST    (MEM_RLAST),
	.MEM_RUSER    (MEM_RUSER),
	.MEM_RVALID   (MEM_RVALID),
	.MEM_RREADY   (MEM_RREADY),

	.il1_fence    (il1_fence),
	.il1_fence_end(il1_fence_end),
	.dl1_fence    (dl1_fence),
	.dl1_fence_end(dl1_fence_end),
	.l2c_fence    (l2c_fence),
	.l2c_fence_end(l2c_fence_end),
	.l3c_fence    (l3c_fence),
	.l3c_fence_end(l3c_fence_end),

	.CLK          (CLK),
	.RSTn         (RSTn)
);


















endmodule














