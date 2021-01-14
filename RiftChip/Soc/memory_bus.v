/*
* @File name: memory_bus
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 17:31:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-14 19:47:25
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



module memory_bus #
(
	parameter SRAM_AW = 11
)
(

	input [63:0] S_AXI_AWADDR,
	input [2:0] S_AXI_AWPROT,
	input S_AXI_AWVALID,
	output S_AXI_AWREADY,

	input [63:0] S_AXI_WDATA,   
	input [7 0] S_AXI_WSTRB,
	input S_AXI_WVALID,
	output S_AXI_WREADY,

	output [1:0] S_AXI_BRESP,
	output S_AXI_BVALID,
	input S_AXI_BREADY,

	input [63:0] S_AXI_ARADDR,
	input [2:0] S_AXI_ARPROT,
	input S_AXI_ARVALID,
	output S_AXI_ARREADY,

	output [63:0] S_AXI_RDATA,
	output [1:0] S_AXI_RRESP,
	output S_AXI_RVALID,
	input S_AXI_RREADY,

	// input mem_mstReq_valid,
	// output mem_mstReq_ready,
	// input [63:0] mem_addr,
	// input [63:0] mem_data_w,
	// output [63:0] mem_data_r,
	// input [7:0] mem_wstrb,
	// input mem_wen,
	// output mem_slvRsp_valid,

	input CLK,
	input RSTn
);





wire [63:0] sram_addr;
wire [127:0] sram_data_r;
wire [127:0] sram_data_w;
wire [15:0] sram_wstrb;

wire [10:0] sram_addr_odd;
wire [10:0] sram_addr_eve;

wire [63:0] sram_data_odd_w;
wire [63:0] sram_data_eve_w;

wire [63:0] sram_data_odd_r;
wire [63:0] sram_data_eve_r;

wire [7:0] sram_wstrb_odd;
wire [7:0] sram_wstrb_eve;

wire sram_wen_odd;
wire sram_wen_eve;

wire sram_reAlign_dnxt;
wire sram_reAlign_qout;

wire [2:0] addr_shift_dnxt;
wire [2:0] addr_shift_qout;
wire [5:0] byte_shift_dnxt;
wire [5:0] byte_shift_qout;


assign sram_reAlign_dnxt = mem_addr[3];
assign addr_shift_dnxt = mem_addr[2:0];
assign byte_shift_dnxt = addr_shift_dnxt << 3;
assign byte_shift_qout = addr_shift_qout << 3;

gen_dffren # (.DW(1)) sram_reAlign_dffren ( .dnxt(sram_reAlign_dnxt), .qout(sram_reAlign_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # (.DW(3)) addr_shift_dffren ( .dnxt(addr_shift_dnxt), .qout(addr_shift_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn));


assign mem_data_r = ({64{isSRAM_qout}} & sram_data_r[ byte_shift_qout +: 64]);
assign sram_data_r = (~sram_reAlign_qout) ? {sram_data_odd_r, sram_data_eve_r} : {sram_data_eve_r, sram_data_odd_r};


assign sram_data_w = mem_data_w << (byte_shift_dnxt);
assign sram_data_odd_w = (~sram_reAlign_dnxt) ? sram_data_w[127:64] : sram_data_w[63:0];
assign sram_data_eve_w = (~sram_reAlign_dnxt) ? sram_data_w[63:0] : sram_data_w[127:64];

assign sram_wstrb = mem_wstrb << (addr_shift_dnxt);
assign sram_wstrb_odd = mem_wen ? ((~sram_reAlign_dnxt) ? sram_wstrb[15:8] : sram_wstrb[7:0]) : 8'b0;
assign sram_wstrb_eve = mem_wen ? ((~sram_reAlign_dnxt) ? sram_wstrb[7:0] : sram_wstrb[15:8]) : 8'b0;


assign sram_addr = isSRAM_dnxt ? mem_addr : 64'b0;
assign sram_addr_odd = sram_addr[4 +: SRAM_AW];
assign sram_addr_eve = ( ~sram_reAlign_dnxt ) ? sram_addr[4 +: SRAM_AW] : sram_addr[4 +: SRAM_AW] + 'd1;


gen_sram # ( .DW(64), .AW(SRAM_AW) ) i_sram_odd
(
	.data_w(sram_data_odd_w),
	.data_r(sram_data_odd_r),
	.data_wstrb(sram_wstrb_odd),
	.en(isSRAM_dnxt),
	.addr(sram_addr_odd),

	.CLK(CLK)
);

gen_sram # ( .DW(64), .AW(SRAM_AW) ) i_sram_eve
(
	.data_w(sram_data_eve_w),
	.data_r(sram_data_eve_r),
	.data_wstrb(sram_wstrb_eve),
	.en(isSRAM_dnxt),
	.addr(sram_addr_eve),

	.CLK(CLK)
);




gen_dffr # (.DW(1)) sram_handshake ( .dnxt(mem_mstReq_valid), .qout(mem_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));




wire mem_mstReq_ready_set, mem_mstReq_ready_rst, mem_mstReq_ready_qout;


assign mem_mstReq_ready = ~mem_mstReq_valid;














	assign S_AXI_AWREADY = axi_awready_qout;
	assign S_AXI_WREADY	= axi_wready_qout;
	assign S_AXI_BRESP	= 2'b0;
	assign S_AXI_BVALID	= axi_bvalid_qout;
	assign S_AXI_ARREADY = axi_arready_qout;
	assign S_AXI_RDATA	= axi_rdata_qout;
	assign S_AXI_RRESP	= 2'b0;
	assign S_AXI_RVALID	= axi_rvalid_qout;



	wire axi_awready_set, axi_awready_rst, axi_awready_qout;
	wire aw_en_set, aw_en_rst, aw_en_qout;
	wire [63:0] axi_awaddr_dnxt;
	wire [63:0] axi_awaddr_qout;
	wire axi_awaddr_en;
	wire axi_wready_set, axi_wready_rst, axi_wready_qout;
	wire axi_bvalid_set, axi_bvalid_rst, axi_bvalid_qout;
	wire axi_arready_set, axi_arready_rst, axi_arready_qout;
	wire [63:0] axi_araddr_dnxt;
	wire [63:0] axi_araddr_qout;
	wire axi_araddr_en;
	wire axi_rvalid_set, axi_rvalid_rst, axi_rvalid_qout;

	assign axi_awready_set = ~axi_awready & S_AXI_AWVALID & S_AXI_WVALID & aw_en_qout;
	assign axi_awready_rst = ~axi_awready_set & (S_AXI_BREADY & axi_bvalid);
	assign aw_en_set = axi_awready_rst;
	assign aw_en_rst = axi_awready_set;

	assign axi_awaddr_dnxt = S_AXI_AWADDR;
	assign axi_awaddr_en = ~axi_awready_qout & S_AXI_AWVALID & S_AXI_WVALID & aw_en_qout;

	assign axi_wready_set = ~axi_wready_qout & S_AXI_WVALID & S_AXI_AWVALID & aw_en_qout;
	assign axi_wready_rst = ~axi_wready_set;

	gen_rsffr #(.DW(1)) axi_awready_rsffr (.set_in(axi_awready_set), .rst_in(axi_awready_rst), .qout(axi_awready_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1), .rstValue(1'b1)) aw_en_rsffr (.set_in(aw_en_set), .rst_in(aw_en_rst), .qout(aw_en_qout), .CLK(CLK), .RSTn(RSTn));

	gen_dffren #(.DW(64)) axi_awaddr_dffren (.dnxt(axi_awaddr_dnxt), .qout(axi_awaddr_qout), .en(axi_awaddr_en), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1)) axi_wready_rsffr (.set_in(axi_wready_set), .rst_in(axi_wready_rst), .qout(axi_wready_qout), .CLK(CLK), .RSTn(RSTn));


	assign slv_reg_wren = axi_wready_qout & S_AXI_WVALID & axi_awready_qout & S_AXI_AWVALID;
	assign slv_reg_rden = axi_arready_qout & S_AXI_ARVALID & ~axi_rvalid_qout;



	assign axi_bvalid_set = axi_awready_qout & S_AXI_AWVALID & ~axi_bvalid_qout & axi_wready_qout & S_AXI_WVALID;
	assign axi_bvalid_rst = ~axi_bvalid_set & (S_AXI_BREADY & axi_bvalid_qout);
	assign axi_arready_set = (~axi_arready & S_AXI_ARVALID);
	assign axi_bvalid_rst = ~axi_arready_set;
	assign axi_araddr_dnxt = S_AXI_ARADDR;
	assign axi_araddr_en = (~axi_arready_qout & S_AXI_ARVALID);
	assign axi_rvalid_set = (axi_arready_qout & S_AXI_ARVALID & ~axi_rvalid_qout);
	assign axi_rvalid_rst = ~axi_rvalid_set & (axi_rvalid_qout & S_AXI_RREADY);

	gen_rsffr #(.DW(1)) axi_bvalid_rsffr (.set_in(axi_bvalid_set), .rst_in(axi_bvalid_rst), .qout(axi_bvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1)) axi_arready_rsffr (.set_in(axi_arready_set), .rst_in(axi_arready_rst), .qout(axi_arready_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren #(.DW(64)) axi_araddr_dffren (.dnxt(axi_araddr_dnxt), .qout(axi_araddr_qout), .en(axi_araddr_en), .CLK(CLK), .RSTn(RSTn));

	gen_rsffr #(.DW(1)) axi_rvalid_rsffr (.set_in(axi_rvalid_set), .rst_in(axi_rvalid_rst), .qout(axi_rvalid_qout), .CLK(CLK), .RSTn(RSTn));







endmodule










