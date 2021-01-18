// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:axi_crossbar:2.1
// IP Revision: 22


module inner_crossBar (
  aclk,
  aresetn,
  s_axi_awaddr,
  s_axi_awprot,
  s_axi_awvalid,
  s_axi_awready,
  s_axi_wdata,
  s_axi_wstrb,
  s_axi_wvalid,
  s_axi_wready,
  s_axi_bresp,
  s_axi_bvalid,
  s_axi_bready,
  s_axi_araddr,
  s_axi_arprot,
  s_axi_arvalid,
  s_axi_arready,
  s_axi_rdata,
  s_axi_rresp,
  s_axi_rvalid,
  s_axi_rready,
  m_axi_awaddr,
  m_axi_awprot,
  m_axi_awvalid,
  m_axi_awready,
  m_axi_wdata,
  m_axi_wstrb,
  m_axi_wvalid,
  m_axi_wready,
  m_axi_bresp,
  m_axi_bvalid,
  m_axi_bready,
  m_axi_araddr,
  m_axi_arprot,
  m_axi_arvalid,
  m_axi_arready,
  m_axi_rdata,
  m_axi_rresp,
  m_axi_rvalid,
  m_axi_rready
);

input wire aclk;
input wire aresetn;
input wire [191 : 0] s_axi_awaddr;
input wire [8 : 0] s_axi_awprot;
input wire [2 : 0] s_axi_awvalid;
output wire [2 : 0] s_axi_awready;
input wire [191 : 0] s_axi_wdata;
input wire [23 : 0] s_axi_wstrb;
input wire [2 : 0] s_axi_wvalid;
output wire [2 : 0] s_axi_wready;
output wire [5 : 0] s_axi_bresp;
output wire [2 : 0] s_axi_bvalid;
input wire [2 : 0] s_axi_bready;
input wire [191 : 0] s_axi_araddr;
input wire [8 : 0] s_axi_arprot;
input wire [2 : 0] s_axi_arvalid;
output wire [2 : 0] s_axi_arready;
output wire [191 : 0] s_axi_rdata;
output wire [5 : 0] s_axi_rresp;
output wire [2 : 0] s_axi_rvalid;
input wire [2 : 0] s_axi_rready;
output wire [319 : 0] m_axi_awaddr;
output wire [14 : 0] m_axi_awprot;
output wire [4 : 0] m_axi_awvalid;
input wire [4 : 0] m_axi_awready;
output wire [319 : 0] m_axi_wdata;
output wire [39 : 0] m_axi_wstrb;
output wire [4 : 0] m_axi_wvalid;
input wire [4 : 0] m_axi_wready;
input wire [9 : 0] m_axi_bresp;
input wire [4 : 0] m_axi_bvalid;
output wire [4 : 0] m_axi_bready;
output wire [319 : 0] m_axi_araddr;
output wire [14 : 0] m_axi_arprot;
output wire [4 : 0] m_axi_arvalid;
input wire [4 : 0] m_axi_arready;
input wire [319 : 0] m_axi_rdata;
input wire [9 : 0] m_axi_rresp;
input wire [4 : 0] m_axi_rvalid;
output wire [4 : 0] m_axi_rready;

  axi_crossbar_v2_1_22_axi_crossbar #(
    .C_FAMILY("rtl"),
    .C_NUM_SLAVE_SLOTS(3),
    .C_NUM_MASTER_SLOTS(5),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(64),
    .C_AXI_DATA_WIDTH(64),
    .C_AXI_PROTOCOL(2),
    .C_NUM_ADDR_RANGES(1),
    .C_M_AXI_BASE_ADDR(320'H00000000800000000000000040000000000000002000000000000000030000000000000002000000),
    .C_M_AXI_ADDR_WIDTH(160'H0000001f00000014000000140000001400000014),
    .C_S_AXI_BASE_ID(96'H000000020000000100000000),
    .C_S_AXI_THREAD_ID_WIDTH(96'H000000000000000000000000),
    .C_AXI_SUPPORTS_USER_SIGNALS(0),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_M_AXI_WRITE_CONNECTIVITY(160'H0000000700000007000000070000000700000007),
    .C_M_AXI_READ_CONNECTIVITY(160'H0000000700000007000000070000000700000007),
    .C_R_REGISTER(0),
    .C_S_AXI_SINGLE_THREAD(96'H000000010000000100000001),
    .C_S_AXI_WRITE_ACCEPTANCE(96'H000000010000000100000001),
    .C_S_AXI_READ_ACCEPTANCE(96'H000000010000000100000001),
    .C_M_AXI_WRITE_ISSUING(160'H0000000100000001000000010000000100000001),
    .C_M_AXI_READ_ISSUING(160'H0000000100000001000000010000000100000001),
    .C_S_AXI_ARB_PRIORITY(96'H000000020000000100000000),
    .C_M_AXI_SECURE(160'H0000000000000000000000000000000000000000),
    .C_CONNECTIVITY_MODE(0)
  ) inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axi_awid(3'H0),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awlen(24'H000000),
    .s_axi_awsize(9'H000),
    .s_axi_awburst(6'H00),
    .s_axi_awlock(3'H0),
    .s_axi_awcache(12'H000),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awqos(12'H000),
    .s_axi_awuser(3'H0),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wid(3'H0),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wlast(3'H7),
    .s_axi_wuser(3'H0),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bid(),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_buser(),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_arid(3'H0),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arlen(24'H000000),
    .s_axi_arsize(9'H000),
    .s_axi_arburst(6'H00),
    .s_axi_arlock(3'H0),
    .s_axi_arcache(12'H000),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arqos(12'H000),
    .s_axi_aruser(3'H0),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rid(),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    .m_axi_awid(),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(m_axi_awprot),
    .m_axi_awregion(),
    .m_axi_awqos(),
    .m_axi_awuser(),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_awready(m_axi_awready),
    .m_axi_wid(),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wlast(),
    .m_axi_wuser(),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_bid(5'H00),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_buser(5'H00),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready),
    .m_axi_arid(),
    .m_axi_araddr(m_axi_araddr),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(m_axi_arprot),
    .m_axi_arregion(),
    .m_axi_arqos(),
    .m_axi_aruser(),
    .m_axi_arvalid(m_axi_arvalid),
    .m_axi_arready(m_axi_arready),
    .m_axi_rid(5'H00),
    .m_axi_rdata(m_axi_rdata),
    .m_axi_rresp(m_axi_rresp),
    .m_axi_rlast(5'H1F),
    .m_axi_ruser(5'H00),
    .m_axi_rvalid(m_axi_rvalid),
    .m_axi_rready(m_axi_rready)
  );
endmodule
