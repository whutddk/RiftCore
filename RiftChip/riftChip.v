/*
* @File name: riftChip
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 16:48:50
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-16 18:02:56
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


module riftChip (

	input CLK,
	input RSTn
);

	wire [63:0] CACHE_AWADDR;
	wire [7:0] CACHE_AWLEN;
	wire [2:0] CACHE_AWSIZE;
	wire [1:0] CACHE_AWBURST;
	wire CACHE_AWVALID;
	wire CACHE_AWREADY;
	wire [63:0] CACHE_WDATA;
	wire [7:0] CACHE_WSTRB;
	wire CACHE_WLAST;
	wire CACHE_WVALID;
	wire CACHE_WREADY;
	wire [1:0] CACHE_BRESP;
	wire [0:0] CACHE_BUSER;
	wire CACHE_BVALID;
	wire CACHE_BREADY;
	wire [63:0] CACHE_ARADDR;
	wire [7:0] CACHE_ARLEN;
	wire [2:0] CACHE_ARSIZE;
	wire [1:0] CACHE_ARBURST;
	wire CACHE_ARVALID;
	wire CACHE_ARREADY;
	wire [63:0] CACHE_RDATA;
	wire [1:0] CACHE_RRESP;
	wire CACHE_RLAST;
	wire [0:0] CACHE_RUSER;
	wire CACHE_RVALID;
	wire CACHE_RREADY;



	wire [31:0] MEM_AWADDR;
	wire [7:0] MEM_AWLEN;
	wire [2:0] MEM_AWSIZE;
	wire [1:0] MEM_AWBURST;
	wire MEM_AWVALID;
	wire MEM_AWREADY;
	wire [63:0] MEM_WDATA;
	wire [7:0] MEM_WSTRB;
	wire MEM_WLAST;
	wire MEM_WVALID;
	wire MEM_WREADY;
	wire [1:0] MEM_BRESP;
	wire MEM_BVALID;
	wire MEM_BREADY;
	wire [31:0] MEM_ARADDR;
	wire [7:0] MEM_ARLEN;
	wire [2:0] MEM_ARSIZE;
	wire [1:0] MEM_ARBURST;
	wire MEM_ARVALID;
	wire MEM_ARREADY;
	wire MEM_RLAST;
	wire [63:0] MEM_RDATA;
	wire [1:0] MEM_RRESP;
	wire MEM_RVALID;
	wire MEM_RREADY;


	wire [31:0] SYS_AWADDR;
	wire SYS_AWVALID;
	wire SYS_AWREADY = 1'b1;
	wire [63:0] SYS_WDATA;
	wire [7:0] SYS_WSTRB;
	wire SYS_WVALID;
	wire SYS_WREADY = 1'b1;
	wire [1:0] SYS_BRESP;
	wire SYS_BVALID = 1'b0;
	wire SYS_BREADY = 2'b00;
	wire [31:0] SYS_ARADDR;
	wire SYS_ARVALID;
	wire SYS_ARREADY = 1'b1;
	wire [63:0] SYS_RDATA = 64'b0;
	wire [1:0] SYS_RRESP = 2'b00;
	wire SYS_RVALID = 1'b0;
	wire SYS_RREADY;










riftCore i_riftCore(
	
	.isExternInterrupt(1'b0),
	.isRTimerInterrupt(1'b0),
	.isSoftwvInterrupt(1'b0),

	.MEM_AWID         (),
	.MEM_AWADDR       (CACHE_AWADDR),
	.MEM_AWLEN        (CACHE_AWLEN),
	.MEM_AWSIZE       (CACHE_AWSIZE),
	.MEM_AWBURST      (CACHE_AWBURST),
	.MEM_AWLOCK       (),
	.MEM_AWCACHE      (),
	.MEM_AWPROT       (),
	.MEM_AWQOS        (),
	.MEM_AWUSER       (),
	.MEM_AWVALID      (CACHE_AWVALID),
	.MEM_AWREADY      (CACHE_AWREADY),
	.MEM_WDATA        (CACHE_WDATA),
	.MEM_WSTRB        (CACHE_WSTRB),
	.MEM_WLAST        (CACHE_WLAST),
	.MEM_WUSER        (),
	.MEM_WVALID       (CACHE_WVALID),
	.MEM_WREADY       (CACHE_WREADY),
	.MEM_BID          (1'b0),
	.MEM_BRESP        (CACHE_BRESP),
	.MEM_BUSER        (1'b0),
	.MEM_BVALID       (CACHE_BVALID),
	.MEM_BREADY       (CACHE_BREADY),
	.MEM_ARID         (),
	.MEM_ARADDR       (CACHE_ARADDR),
	.MEM_ARLEN        (CACHE_ARLEN),
	.MEM_ARSIZE       (CACHE_ARSIZE),
	.MEM_ARBURST      (CACHE_ARBURST),
	.MEM_ARLOCK       (),
	.MEM_ARCACHE      (),
	.MEM_ARPROT       (),
	.MEM_ARQOS        (),
	.MEM_ARUSER       (),
	.MEM_ARVALID      (CACHE_ARVALID),
	.MEM_ARREADY      (CACHE_ARREADY),
	.MEM_RID          (1'b0),
	.MEM_RDATA        (CACHE_RDATA),
	.MEM_RRESP        (CACHE_RRESP),
	.MEM_RLAST        (CACHE_RLAST),
	.MEM_RUSER        (CACHE_RUSER),
	.MEM_RVALID       (CACHE_RVALID),
	.MEM_RREADY       (CACHE_RREADY),

	.SYS_AWADDR      (SYS_AWADDR),
	.SYS_AWVALID     (SYS_AWVALID),
	.SYS_AWREADY     (SYS_AWREADY),
	.SYS_WDATA       (SYS_WDATA),
	.SYS_WSTRB       (SYS_WSTRB),
	.SYS_WVALID      (SYS_WVALID),
	.SYS_WREADY      (SYS_WREADY),
	.SYS_BRESP       (SYS_BRESP),
	.SYS_BVALID      (SYS_BVALID),
	.SYS_BREADY      (SYS_BREADY),
	.SYS_ARADDR      (SYS_ARADDR),
	.SYS_ARVALID     (SYS_ARVALID),
	.SYS_ARREADY     (SYS_ARREADY),
	.SYS_RDATA       (SYS_RDATA),
	.SYS_RRESP       (SYS_RRESP),
	.SYS_RVALID      (SYS_RVALID),
	.SYS_RREADY      (SYS_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
	
);




// fxbar_wrap i_fxbar_wrap
// (

// 	.DM_AWADDR(32'b0),
// 	.DM_AWLEN(8'd0),
// 	.DM_AWSIZE(3'b0),
// 	.DM_AWBURST(2'b0),

// 	.DM_AWVALID(1'b0),
// 	.DM_AWREADY(),
// 	.DM_WDATA(64'b0),
// 	.DM_WSTRB(8'b0),
// 	.DM_WLAST(1'b1),
// 	.DM_WVALID(1'b0),
// 	.DM_WREADY(),
// 	.DM_BRESP(),
// 	.DM_BVALID(),
// 	.DM_BREADY(1'b1),

// 	.DM_ARADDR(32'b0),
// 	.DM_ARLEN(8'd0),
// 	.DM_ARSIZE(3'b0),
// 	.DM_ARBURST(2'b0),
// 	.DM_ARVALID(1'b0),
// 	.DM_ARREADY(),

// 	.DM_RDATA(),
// 	.DM_RRESP(),
// 	.DM_RLAST(),
// 	.DM_RVALID(),
// 	.DM_RREADY(1'b1),


// 	.SYS_AWADDR(SYS_AWADDR),
// 	.SYS_AWLEN(8'd0),
// 	.SYS_AWSIZE(3'd3),
// 	.SYS_AWBURST(2'b00),
// 	.SYS_AWVALID(SYS_AWVALID),
// 	.SYS_AWREADY(SYS_AWREADY),
// 	.SYS_WDATA(SYS_WDATA),
// 	.SYS_WSTRB(SYS_WSTRB),
// 	.SYS_WLAST(1'b1),
// 	.SYS_WVALID(SYS_WVALID),
// 	.SYS_WREADY(SYS_WREADY),
// 	.SYS_BRESP(SYS_BRESP),
// 	.SYS_BVALID(SYS_BVALID),
// 	.SYS_BREADY(SYS_BREADY),
// 	.SYS_ARADDR(SYS_ARADDR),
// 	.SYS_ARLEN(8'd0),
// 	.SYS_ARSIZE(3'd3),
// 	.SYS_ARBURST(2'b0),
// 	.SYS_ARVALID(SYS_ARVALID),
// 	.SYS_ARREADY(SYS_ARREADY),
// 	.SYS_RDATA(SYS_RDATA),
// 	.SYS_RRESP(SYS_RRESP),
// 	.SYS_RLAST(),
// 	.SYS_RVALID(SYS_RVALID),
// 	.SYS_RREADY(SYS_RREADY),

// 	.CACHE_AWADDR (CACHE_AWADDR[31:0]),
// 	.CACHE_AWLEN  (CACHE_AWLEN),
// 	.CACHE_AWSIZE (CACHE_AWSIZE),
// 	.CACHE_AWBURST(CACHE_AWBURST),
// 	.CACHE_AWVALID(CACHE_AWVALID),
// 	.CACHE_AWREADY(CACHE_AWREADY),
// 	.CACHE_WDATA  (CACHE_WDATA),
// 	.CACHE_WSTRB  (CACHE_WSTRB),
// 	.CACHE_WLAST  (CACHE_WLAST),
// 	.CACHE_WVALID (CACHE_WVALID),
// 	.CACHE_WREADY (CACHE_WREADY),
// 	.CACHE_BRESP  (CACHE_BRESP),
// 	.CACHE_BVALID (CACHE_BVALID),
// 	.CACHE_BREADY (CACHE_BREADY),
// 	.CACHE_ARADDR (CACHE_ARADDR[31:0]),
// 	.CACHE_ARLEN  (CACHE_ARLEN),
// 	.CACHE_ARSIZE (CACHE_ARSIZE),
// 	.CACHE_ARBURST(CACHE_ARBURST),
// 	.CACHE_ARVALID(CACHE_ARVALID),
// 	.CACHE_ARREADY(CACHE_ARREADY),
// 	.CACHE_RDATA  (CACHE_RDATA),
// 	.CACHE_RRESP  (CACHE_RRESP),
// 	.CACHE_RLAST  (CACHE_RLAST),
// 	.CACHE_RVALID (CACHE_RVALID),
// 	.CACHE_RREADY (CACHE_RREADY),

// 	.CLINT_AWADDR (),
// 	.CLINT_AWLEN  (),
// 	.CLINT_AWSIZE (),
// 	.CLINT_AWBURST(),
// 	.CLINT_AWVALID(),
// 	.CLINT_AWREADY(1'b1),
// 	.CLINT_WDATA  (),
// 	.CLINT_WSTRB  (),
// 	.CLINT_WLAST  (),
// 	.CLINT_WVALID (),
// 	.CLINT_WREADY (1'b1),
// 	.CLINT_BRESP  (2'b0),
// 	.CLINT_BVALID (1'b0),
// 	.CLINT_BREADY (),
// 	.CLINT_ARADDR (),
// 	.CLINT_ARLEN  (),
// 	.CLINT_ARSIZE (),
// 	.CLINT_ARBURST(),
// 	.CLINT_ARVALID(),
// 	.CLINT_ARREADY(1'b1),
// 	.CLINT_RDATA  (64'b0),
// 	.CLINT_RRESP  (2'b0),
// 	.CLINT_RLAST  (1'b1),
// 	.CLINT_RVALID (1'b0),
// 	.CLINT_RREADY (),

// 	.PLIC_AWADDR  (),
// 	.PLIC_AWLEN   (),
// 	.PLIC_AWSIZE  (),
// 	.PLIC_AWBURST (),
// 	.PLIC_AWVALID (),
// 	.PLIC_AWREADY (1'b1),
// 	.PLIC_WDATA   (),
// 	.PLIC_WSTRB   (),
// 	.PLIC_WLAST   (),
// 	.PLIC_WVALID  (),
// 	.PLIC_WREADY  (1'b1),
// 	.PLIC_BRESP   (2'b0),
// 	.PLIC_BVALID  (1'b0),
// 	.PLIC_BREADY  (),
// 	.PLIC_ARADDR  (),
// 	.PLIC_ARLEN   (),
// 	.PLIC_ARSIZE  (),
// 	.PLIC_ARBURST (),
// 	.PLIC_ARVALID (),
// 	.PLIC_ARREADY (1'b1),
// 	.PLIC_RDATA   (64'b0),
// 	.PLIC_RRESP   (2'b0),
// 	.PLIC_RLAST   (1'b1),
// 	.PLIC_RVALID  (1'b0),
// 	.PLIC_RREADY  (),

// 	.PERPH_AWADDR (),
// 	.PERPH_AWLEN  (),
// 	.PERPH_AWSIZE (),
// 	.PERPH_AWVALID(),
// 	.PERPH_AWREADY(1'b1),
// 	.PERPH_WDATA  (),
// 	.PERPH_WSTRB  (),
// 	.PERPH_WLAST  (),
// 	.PERPH_WVALID (),
// 	.PERPH_WREADY (1'b1),
// 	.PERPH_BRESP  (2'b0),
// 	.PERPH_BVALID (1'b0),
// 	.PERPH_BREADY (),
// 	.PERPH_ARADDR (),
// 	.PERPH_ARLEN  (),
// 	.PERPH_ARSIZE (),
// 	.PERPH_ARBURST(),
// 	.PERPH_ARVALID(),
// 	.PERPH_ARREADY(1'b1),
// 	.PERPH_RDATA  (64'b0),
// 	.PERPH_RRESP  (2'b0),
// 	.PERPH_RLAST  (1'b1),
// 	.PERPH_RVALID (1'b0),
// 	.PERPH_RREADY (),

// 	.MEM_AWADDR   (MEM_AWADDR),
// 	.MEM_AWLEN    (MEM_AWLEN),
// 	.MEM_AWSIZE   (MEM_AWSIZE),
// 	.MEM_AWBURST  (MEM_AWBURST),
// 	.MEM_AWVALID  (MEM_AWVALID),
// 	.MEM_AWREADY  (MEM_AWREADY),
// 	.MEM_WDATA    (MEM_WDATA),
// 	.MEM_WSTRB    (MEM_WSTRB),
// 	.MEM_WLAST    (MEM_WLAST),
// 	.MEM_WVALID   (MEM_WVALID),
// 	.MEM_WREADY   (MEM_WREADY),
// 	.MEM_BRESP    (MEM_BRESP),
// 	.MEM_BVALID   (MEM_BVALID),
// 	.MEM_BREADY   (MEM_BREADY),
// 	.MEM_ARADDR   (MEM_ARADDR),
// 	.MEM_ARLEN    (MEM_ARLEN),
// 	.MEM_ARSIZE   (MEM_ARSIZE),
// 	.MEM_ARBURST  (MEM_ARBURST),
// 	.MEM_ARVALID  (MEM_ARVALID),
// 	.MEM_ARREADY  (MEM_ARREADY),
// 	.MEM_RDATA    (MEM_RDATA),
// 	.MEM_RRESP    (MEM_RRESP),
// 	.MEM_RLAST    (MEM_RLAST),
// 	.MEM_RVALID   (MEM_RVALID),
// 	.MEM_RREADY   (MEM_RREADY),



// 	.CLK          (CLK),
// 	.RSTn         (RSTn)


// );





axi_full_slv_sram i_axi_full_slv_sram
(
	.MEM_AWADDR (CACHE_AWADDR[31:0]),
	.MEM_AWLEN  (CACHE_AWLEN),
	.MEM_AWSIZE (CACHE_AWSIZE),
	.MEM_AWBURST(CACHE_AWBURST),
	.MEM_AWVALID(CACHE_AWVALID),
	.MEM_AWREADY(CACHE_AWREADY),
	.MEM_WDATA  (CACHE_WDATA),
	.MEM_WSTRB  (CACHE_WSTRB),
	.MEM_WLAST  (CACHE_WLAST),
	.MEM_WVALID (CACHE_WVALID),
	.MEM_WREADY (CACHE_WREADY),
	.MEM_BRESP  (CACHE_BRESP),
	.MEM_BVALID (CACHE_BVALID),
	.MEM_BREADY (CACHE_BREADY),
	.MEM_ARADDR (CACHE_ARADDR[31:0]),
	.MEM_ARLEN  (CACHE_ARLEN),
	.MEM_ARSIZE (CACHE_ARSIZE),
	.MEM_ARBURST(CACHE_ARBURST),
	.MEM_ARVALID(CACHE_ARVALID),
	.MEM_ARREADY(CACHE_ARREADY),
	.MEM_RDATA  (CACHE_RDATA),
	.MEM_RRESP  (CACHE_RRESP),
	.MEM_RLAST  (CACHE_RLAST),
	.MEM_RVALID (CACHE_RVALID),
	.MEM_RREADY (CACHE_RREADY),

	.CLK            (CLK),
	.RSTn           (RSTn)
);












endmodule






