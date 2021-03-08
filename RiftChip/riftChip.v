/*
* @File name: riftChip
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 16:48:50
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-08 14:19:53
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

	wire [63:0] LSU_AWADDR;
	wire [2:0] LSU_AWPROT;
	wire LSU_AWVALID;
	wire LSU_AWREADY;
	wire [63:0] LSU_WDATA;
	wire [7:0] LSU_WSTRB;
	wire LSU_WVALID;
	wire LSU_WREADY;
	wire [1:0] LSU_BRESP;
	wire LSU_BVALID;
	wire LSU_BREADY;
	wire [63:0] LSU_ARADDR;
	wire [2:0] LSU_ARPROT;
	wire LSU_ARVALID;
	wire LSU_ARREADY;
	wire [63:0] LSU_RDATA;
	wire [1:0] LSU_RRESP;
	wire LSU_RVALID;
	wire LSU_RREADY;

	wire [63:0] MEM_AXI_AWADDR;
	wire MEM_AXI_AWVALID;
	wire MEM_AXI_AWREADY;
	wire [63:0] MEM_AXI_WDATA;
	wire [7:0] MEM_AXI_WSTRB;
	wire MEM_AXI_WVALID;
	wire MEM_AXI_WREADY;
	wire [1:0] MEM_AXI_BRESP;
	wire MEM_AXI_BVALID;
	wire MEM_AXI_BREADY;
	wire [63:0] MEM_AXI_ARADDR;
	wire MEM_AXI_ARVALID;
	wire MEM_AXI_ARREADY;
	wire [63:0] MEM_AXI_RDATA;
	wire [1:0] MEM_AXI_RRESP;
	wire MEM_AXI_RVALID;
	wire MEM_AXI_RREADY;


riftCore i_riftCore(
	
	.isExternInterrupt(1'b0),
	.isRTimerInterrupt(1'b0),
	.isSoftwvInterrupt(1'b0),

	.MEM_AWID         (MEM_AWID),
	.MEM_AWADDR       (MEM_AWADDR),
	.MEM_AWLEN        (MEM_AWLEN),
	.MEM_AWSIZE       (MEM_AWSIZE),
	.MEM_AWBURST      (MEM_AWBURST),
	.MEM_AWLOCK       (MEM_AWLOCK),
	.MEM_AWCACHE      (MEM_AWCACHE),
	.MEM_AWPROT       (MEM_AWPROT),
	.MEM_AWQOS        (MEM_AWQOS),
	.MEM_AWUSER       (MEM_AWUSER),
	.MEM_AWVALID      (MEM_AWVALID),
	.MEM_AWREADY      (MEM_AWREADY),
	.MEM_WDATA        (MEM_WDATA),
	.MEM_WSTRB        (MEM_WSTRB),
	.MEM_WLAST        (MEM_WLAST),
	.MEM_WUSER        (MEM_WUSER),
	.MEM_WVALID       (MEM_WVALID),
	.MEM_WREADY       (MEM_WREADY),
	.MEM_BID          (MEM_BID),
	.MEM_BRESP        (MEM_BRESP),
	.MEM_BUSER        (MEM_BUSER),
	.MEM_BVALID       (MEM_BVALID),
	.MEM_BREADY       (MEM_BREADY),
	.MEM_ARID         (MEM_ARID),
	.MEM_ARADDR       (MEM_ARADDR),
	.MEM_ARLEN        (MEM_ARLEN),
	.MEM_ARSIZE       (MEM_ARSIZE),
	.MEM_ARBURST      (MEM_ARBURST),
	.MEM_ARLOCK       (MEM_ARLOCK),
	.MEM_ARCACHE      (MEM_ARCACHE),
	.MEM_ARPROT       (MEM_ARPROT),
	.MEM_ARQOS        (MEM_ARQOS),
	.MEM_ARUSER       (MEM_ARUSER),
	.MEM_ARVALID      (MEM_ARVALID),
	.MEM_ARREADY      (MEM_ARREADY),
	.MEM_RID          (MEM_RID),
	.MEM_RDATA        (MEM_RDATA),
	.MEM_RRESP        (MEM_RRESP),
	.MEM_RLAST        (MEM_RLAST),
	.MEM_RUSER        (MEM_RUSER),
	.MEM_RVALID       (MEM_RVALID),
	.MEM_RREADY       (MEM_RREADY),

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

	.CLK(CLK),
	.RSTn(RSTn)
	
);


Xbar_wrap i_Xbar_wrap(

	.DM_AWADDR(64'b0),
	.DM_AWPROT(3'b001),
	.DM_AWVALID(1'b0),
	.DM_AWREADY(),
	.DM_WDATA(64'b0),
	.DM_WSTRB(8'b0),
	.DM_WVALID(1'b0),
	.DM_WREADY(),
	.DM_BRESP(),
	.DM_BVALID(),
	.DM_BREADY(1'b1),
	.DM_ARADDR(64'b0),
	.DM_ARPROT(3'b001),
	.DM_ARVALID(1'b0),
	.DM_ARREADY(),
	.DM_RDATA(),
	.DM_RRESP(),
	.DM_RVALID(),
	.DM_RREADY(1'b1),

	.IFU_AWADDR(IFU_AWADDR),
	.IFU_AWPROT(IFU_AWPROT),
	.IFU_AWVALID(IFU_AWVALID),
	.IFU_AWREADY(IFU_AWREADY),
	.IFU_WDATA(IFU_WDATA),
	.IFU_WSTRB(IFU_WSTRB),
	.IFU_WVALID(IFU_WVALID),
	.IFU_WREADY(IFU_WREADY),
	.IFU_BRESP(IFU_BRESP),
	.IFU_BVALID(IFU_BVALID),
	.IFU_BREADY(IFU_BREADY),

	.IFU_ARADDR(IFU_ARADDR),
	.IFU_ARPROT(IFU_ARPROT),
	.IFU_ARVALID(IFU_ARVALID),
	.IFU_ARREADY(IFU_ARREADY),
	.IFU_RDATA(IFU_RDATA),
	.IFU_RRESP(IFU_RRESP),
	.IFU_RVALID(IFU_RVALID),
	.IFU_RREADY(IFU_RREADY),

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

	.CLINT_AXI_AWADDR(),
	.CLINT_AXI_AWVALID(),
	.CLINT_AXI_AWREADY(1'b1),
	.CLINT_AXI_WDATA(),   
	.CLINT_AXI_WSTRB(),
	.CLINT_AXI_WVALID(),
	.CLINT_AXI_WREADY(1'b1),
	.CLINT_AXI_BRESP(2'b1),
	.CLINT_AXI_BVALID(1'b0),
	.CLINT_AXI_BREADY(),
	.CLINT_AXI_ARADDR(),
	.CLINT_AXI_ARVALID(),
	.CLINT_AXI_ARREADY(1'b1),
	.CLINT_AXI_RDATA(64'b0),
	.CLINT_AXI_RRESP(2'b0),
	.CLINT_AXI_RVALID(1'b1),
	.CLINT_AXI_RREADY(),

	.PLIC_AXI_AWADDR(),
	.PLIC_AXI_AWVALID(),
	.PLIC_AXI_AWREADY(1'b1),
	.PLIC_AXI_WDATA(),   
	.PLIC_AXI_WSTRB(),
	.PLIC_AXI_WVALID(),
	.PLIC_AXI_WREADY(1'b1),
	.PLIC_AXI_BRESP(2'b0),
	.PLIC_AXI_BVALID(1'b1),
	.PLIC_AXI_BREADY(),
	.PLIC_AXI_ARADDR(),
	.PLIC_AXI_ARVALID(),
	.PLIC_AXI_ARREADY(1'b1),
	.PLIC_AXI_RDATA(64'b0),
	.PLIC_AXI_RRESP(2'b0),
	.PLIC_AXI_RVALID(1'b1),
	.PLIC_AXI_RREADY(),

	.PREPH_AXI_AWADDR(),
	.PREPH_AXI_AWVALID(),
	.PREPH_AXI_AWREADY(1'b1),
	.PREPH_AXI_WDATA(),   
	.PREPH_AXI_WSTRB(),
	.PREPH_AXI_WVALID(),
	.PREPH_AXI_WREADY(1'b1),
	.PREPH_AXI_BRESP(2'b0),
	.PREPH_AXI_BVALID(1'b1),
	.PREPH_AXI_BREADY(),
	.PREPH_AXI_ARADDR(),
	.PREPH_AXI_ARVALID(),
	.PREPH_AXI_ARREADY(1'b1),
	.PREPH_AXI_RDATA(64'b0),
	.PREPH_AXI_RRESP(2'b0),
	.PREPH_AXI_RVALID(1'b1),
	.PREPH_AXI_RREADY(),

	.SYS_AXI_AWADDR(),
	.SYS_AXI_AWVALID(),
	.SYS_AXI_AWREADY(1'b1),
	.SYS_AXI_WDATA(),   
	.SYS_AXI_WSTRB(),
	.SYS_AXI_WVALID(),
	.SYS_AXI_WREADY(1'b1),
	.SYS_AXI_BRESP(2'b0),
	.SYS_AXI_BVALID(1'b1),
	.SYS_AXI_BREADY(),
	.SYS_AXI_ARADDR(),
	.SYS_AXI_ARVALID(),
	.SYS_AXI_ARREADY(1'b1),
	.SYS_AXI_RDATA(64'b0),
	.SYS_AXI_RRESP(2'b0),
	.SYS_AXI_RVALID(1'b1),
	.SYS_AXI_RREADY(),

	.MEM_AXI_AWADDR(MEM_AXI_AWADDR),
	.MEM_AXI_AWVALID(MEM_AXI_AWVALID),
	.MEM_AXI_AWREADY(MEM_AXI_AWREADY),
	.MEM_AXI_WDATA(MEM_AXI_WDATA),   
	.MEM_AXI_WSTRB(MEM_AXI_WSTRB),
	.MEM_AXI_WVALID(MEM_AXI_WVALID),
	.MEM_AXI_WREADY(MEM_AXI_WREADY),
	.MEM_AXI_BRESP(MEM_AXI_BRESP),
	.MEM_AXI_BVALID(MEM_AXI_BVALID),
	.MEM_AXI_BREADY(MEM_AXI_BREADY),
	.MEM_AXI_ARADDR(MEM_AXI_ARADDR),
	.MEM_AXI_ARVALID(MEM_AXI_ARVALID),
	.MEM_AXI_ARREADY(MEM_AXI_ARREADY),
	.MEM_AXI_RDATA(MEM_AXI_RDATA),
	.MEM_AXI_RRESP(MEM_AXI_RRESP),
	.MEM_AXI_RVALID(MEM_AXI_RVALID),
	.MEM_AXI_RREADY(MEM_AXI_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)


);


axi_ccm i_axi_ccm(

	.S_AXI_AWADDR(MEM_AXI_AWADDR),
	.S_AXI_AWVALID(MEM_AXI_AWVALID),
	.S_AXI_AWREADY(MEM_AXI_AWREADY),
	.S_AXI_WDATA(MEM_AXI_WDATA),   
	.S_AXI_WSTRB(MEM_AXI_WSTRB),
	.S_AXI_WVALID(MEM_AXI_WVALID),
	.S_AXI_WREADY(MEM_AXI_WREADY),
	.S_AXI_BRESP(MEM_AXI_BRESP),
	.S_AXI_BVALID(MEM_AXI_BVALID),
	.S_AXI_BREADY(MEM_AXI_BREADY),

	.S_AXI_ARADDR(MEM_AXI_ARADDR),
	.S_AXI_ARVALID(MEM_AXI_ARVALID),
	.S_AXI_ARREADY(MEM_AXI_ARREADY),
	.S_AXI_RDATA(MEM_AXI_RDATA),
	.S_AXI_RRESP(MEM_AXI_RRESP),
	.S_AXI_RVALID(MEM_AXI_RVALID),
	.S_AXI_RREADY(MEM_AXI_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
);


axi_full_slv_sram i_axi_full_slv_sram
(
	.MEM_AXI_AWADDR (MEM_AXI_AWADDR),
	.MEM_AXI_AWLEN  (MEM_AXI_AWLEN),
	.MEM_AXI_AWSIZE (MEM_AXI_AWSIZE),
	.MEM_AXI_AWBURST(MEM_AXI_AWBURST),
	.MEM_AXI_AWVALID(MEM_AXI_AWVALID),
	.MEM_AXI_AWREADY(MEM_AXI_AWREADY),
	.MEM_AXI_WDATA  (MEM_AXI_WDATA),
	.MEM_AXI_WSTRB  (MEM_AXI_WSTRB),
	.MEM_AXI_WLAST  (MEM_AXI_WLAST),
	.MEM_AXI_WVALID (MEM_AXI_WVALID),
	.MEM_AXI_WREADY (MEM_AXI_WREADY),
	.MEM_AXI_BRESP  (MEM_AXI_BRESP),
	.MEM_AXI_BVALID (MEM_AXI_BVALID),
	.MEM_AXI_BREADY (MEM_AXI_BREADY),
	.MEM_AXI_ARADDR (MEM_AXI_ARADDR),
	.MEM_AXI_ARLEN  (MEM_AXI_ARLEN),
	.MEM_AXI_ARSIZE (MEM_AXI_ARSIZE),
	.MEM_AXI_ARBURST(MEM_AXI_ARBURST),
	.MEM_AXI_ARVALID(MEM_AXI_ARVALID),
	.MEM_AXI_ARREADY(MEM_AXI_ARREADY),
	.MEM_AXI_RDATA  (MEM_AXI_RDATA),
	.MEM_AXI_RRESP  (MEM_AXI_RRESP),
	.MEM_AXI_RLAST  (MEM_AXI_RLAST),
	.MEM_AXI_RVALID (MEM_AXI_RVALID),
	.MEM_AXI_RREADY (MEM_AXI_RREADY),

	.CLK            (CLK),
	.RSTn           (RSTn)
);



endmodule






