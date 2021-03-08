/*
* @File name: axi_register_slice_v2_1_21_axi_register_slice
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-03-08 19:49:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-08 19:50:21
*/



//  (c) Copyright 2010-2017 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES. 
//-----------------------------------------------------------------------------
//
// AXI Register Slice
//   Register selected channels on the forward and/or reverse signal paths.
//   5-channel memory-mapped AXI4 interfaces.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi_register_slice
//      axic_register_slice
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps

module axi_register_slice_v2_1_21_axi_register_slice #
  (
   parameter C_FAMILY                            = "virtex6",
   parameter C_AXI_PROTOCOL                      = 0,
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_AWUSER_WIDTH          = 1,
   parameter integer C_AXI_ARUSER_WIDTH          = 1,
   parameter integer C_AXI_WUSER_WIDTH           = 1,
   parameter integer C_AXI_RUSER_WIDTH           = 1,
   parameter integer C_AXI_BUSER_WIDTH           = 1,
   // C_REG_CONFIG_*:
   //   0 => BYPASS    = The channel is just wired through the module.
   //   1 => FWD_REV   = Both FWD and REV (fully-registered)
   //   2 => FWD       = The master VALID and payload signals are registrated. 
   //   3 => REV       = The slave ready signal is registrated
   //   4 => SLAVE_FWD = All slave side signals and master VALID and payload are registrated.
   //   5 => SLAVE_RDY = All slave side signals and master READY are registrated.
   //   6 => INPUTS    = Slave and Master side inputs are registrated.
   //   7 => LIGHT_WT  = 1-stage pipeline register with bubble cycle, both FWD and REV pipelining
   //   9 => SI/MI_REG = Source side completely registered (including S_VALID input)
   //   12 => SLR Crossing (source->dest flops, full-width payload, single clock)
   //   13 => TDM SLR Crossing (source->dest flops, half-width payload, dual clock)
   //   15 => Variable SLR Crossings (single clock)
   //   16 -> Auto-pipelining
   parameter integer C_REG_CONFIG_AW = 7,
   parameter integer C_REG_CONFIG_W  = 1,
   parameter integer C_REG_CONFIG_B  = 7,
   parameter integer C_REG_CONFIG_AR = 7,
   parameter integer C_REG_CONFIG_R  = 1,
   parameter integer C_RESERVE_MODE = 0,
   parameter integer C_NUM_SLR_CROSSINGS = 0,
   parameter integer C_PIPELINES_MASTER_AW = 0,
   parameter integer C_PIPELINES_MASTER_W  = 0,
   parameter integer C_PIPELINES_MASTER_B  = 0,
   parameter integer C_PIPELINES_MASTER_AR = 0,
   parameter integer C_PIPELINES_MASTER_R  = 0,
   parameter integer C_PIPELINES_SLAVE_AW = 0,
   parameter integer C_PIPELINES_SLAVE_W  = 0,
   parameter integer C_PIPELINES_SLAVE_B  = 0,
   parameter integer C_PIPELINES_SLAVE_AR = 0,
   parameter integer C_PIPELINES_SLAVE_R  = 0,
   parameter integer C_PIPELINES_MIDDLE_AW = 0,
   parameter integer C_PIPELINES_MIDDLE_W  = 0,
   parameter integer C_PIPELINES_MIDDLE_B  = 0,
   parameter integer C_PIPELINES_MIDDLE_AR = 0,
   parameter integer C_PIPELINES_MIDDLE_R  = 0
   )   
  (
   // System Signals
   input wire aclk,
   input wire aclk2x,
   input wire aresetn,

   // Slave Interface Write Address Ports
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
   input  wire [3-1:0]                  s_axi_awsize,
   input  wire [2-1:0]                  s_axi_awburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_awlock,
   input  wire [4-1:0]                  s_axi_awcache,
   input  wire [3-1:0]                  s_axi_awprot,
   input  wire [4-1:0]                  s_axi_awregion,
   input  wire [4-1:0]                  s_axi_awqos,
   input  wire [C_AXI_AWUSER_WIDTH-1:0] s_axi_awuser,
   input  wire                          s_axi_awvalid,
   output wire                          s_axi_awready,

   // Slave Interface Write Data Ports
   input wire [C_AXI_ID_WIDTH-1:0]      s_axi_wid,
   input  wire [C_AXI_DATA_WIDTH-1:0]   s_axi_wdata,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
   input  wire                          s_axi_wlast,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  s_axi_wuser,
   input  wire                          s_axi_wvalid,
   output wire                          s_axi_wready,

   // Slave Interface Write Response Ports
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_bid,
   output wire [2-1:0]                 s_axi_bresp,
   output wire [C_AXI_BUSER_WIDTH-1:0] s_axi_buser,
   output wire                         s_axi_bvalid,
   input  wire                         s_axi_bready,

   // Slave Interface Read Address Ports
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
   input  wire [3-1:0]                  s_axi_arsize,
   input  wire [2-1:0]                  s_axi_arburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_arlock,
   input  wire [4-1:0]                  s_axi_arcache,
   input  wire [3-1:0]                  s_axi_arprot,
   input  wire [4-1:0]                  s_axi_arregion,
   input  wire [4-1:0]                  s_axi_arqos,
   input  wire [C_AXI_ARUSER_WIDTH-1:0] s_axi_aruser,
   input  wire                          s_axi_arvalid,
   output wire                          s_axi_arready,

   // Slave Interface Read Data Ports
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_rid,
   output wire [C_AXI_DATA_WIDTH-1:0]  s_axi_rdata,
   output wire [2-1:0]                 s_axi_rresp,
   output wire                         s_axi_rlast,
   output wire [C_AXI_RUSER_WIDTH-1:0] s_axi_ruser,
   output wire                         s_axi_rvalid,
   input  wire                         s_axi_rready,
   
   // Master Interface Write Address Port
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_awid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_awlen,
   output wire [3-1:0]                  m_axi_awsize,
   output wire [2-1:0]                  m_axi_awburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_awlock,
   output wire [4-1:0]                  m_axi_awcache,
   output wire [3-1:0]                  m_axi_awprot,
   output wire [4-1:0]                  m_axi_awregion,
   output wire [4-1:0]                  m_axi_awqos,
   output wire [C_AXI_AWUSER_WIDTH-1:0] m_axi_awuser,
   output wire                          m_axi_awvalid,
   input  wire                          m_axi_awready,
   
   // Master Interface Write Data Ports
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_wid,
   output wire [C_AXI_DATA_WIDTH-1:0]   m_axi_wdata,
   output wire [C_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
   output wire                          m_axi_wlast,
   output wire [C_AXI_WUSER_WIDTH-1:0]  m_axi_wuser,
   output wire                          m_axi_wvalid,
   input  wire                          m_axi_wready,
   
   // Master Interface Write Response Ports
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_bid,
   input  wire [2-1:0]                 m_axi_bresp,
   input  wire [C_AXI_BUSER_WIDTH-1:0] m_axi_buser,
   input  wire                         m_axi_bvalid,
   output wire                         m_axi_bready,
   
   // Master Interface Read Address Port
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_arid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_arlen,
   output wire [3-1:0]                  m_axi_arsize,
   output wire [2-1:0]                  m_axi_arburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_arlock,
   output wire [4-1:0]                  m_axi_arcache,
   output wire [3-1:0]                  m_axi_arprot,
   output wire [4-1:0]                  m_axi_arregion,
   output wire [4-1:0]                  m_axi_arqos,
   output wire [C_AXI_ARUSER_WIDTH-1:0] m_axi_aruser,
   output wire                          m_axi_arvalid,
   input  wire                          m_axi_arready,
   
   // Master Interface Read Data Ports
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_rid,
   input  wire [C_AXI_DATA_WIDTH-1:0]  m_axi_rdata,
   input  wire [2-1:0]                 m_axi_rresp,
   input  wire                         m_axi_rlast,
   input  wire [C_AXI_RUSER_WIDTH-1:0] m_axi_ruser,
   input  wire                         m_axi_rvalid,
   output wire                         m_axi_rready
  );

  wire reset;

  localparam integer C_AXI_SUPPORTS_REGION_SIGNALS = (C_AXI_PROTOCOL == 0) ? 1 : 0;
  localparam integer P_FORWARD = 0;
  localparam integer P_RESPONSE = 1;
  `include "axi_infrastructure_v1_1_0.vh"

  wire [G_AXI_AWPAYLOAD_WIDTH-1:0] s_awpayload;
  wire [G_AXI_AWPAYLOAD_WIDTH-1:0] m_awpayload;
  wire [G_AXI_WPAYLOAD_WIDTH-1:0] s_wpayload;
  wire [G_AXI_WPAYLOAD_WIDTH-1:0] m_wpayload;
  wire [G_AXI_BPAYLOAD_WIDTH-1:0] s_bpayload;
  wire [G_AXI_BPAYLOAD_WIDTH-1:0] m_bpayload;
  wire [G_AXI_ARPAYLOAD_WIDTH-1:0] s_arpayload;
  wire [G_AXI_ARPAYLOAD_WIDTH-1:0] m_arpayload;
  wire [G_AXI_RPAYLOAD_WIDTH-1:0] s_rpayload;
  wire [G_AXI_RPAYLOAD_WIDTH-1:0] m_rpayload;

  assign reset = ~aresetn;
  
  generate
  
  if (C_RESERVE_MODE==1) begin : gen_reserve_si
  
    axi_register_slice_v2_1_21_test_slave #(
      .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
      .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
      .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
      .C_AXI_PROTOCOL(C_AXI_PROTOCOL),
      .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH),
      .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH),
      .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH),
      .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH),
      .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH)
    ) inst (
      .s_axi_awaddr(s_axi_awaddr),
      .s_axi_awprot(s_axi_awprot),
      .s_axi_awvalid(s_axi_awvalid),
      .s_axi_awready(s_axi_awready),
      .s_axi_awsize(s_axi_awsize),
      .s_axi_awburst(s_axi_awburst),
      .s_axi_awcache(s_axi_awcache),
      .s_axi_awlen(s_axi_awlen),
      .s_axi_awlock(s_axi_awlock),
      .s_axi_awqos(s_axi_awqos),
      .s_axi_awregion(s_axi_awregion),
      .s_axi_awid(s_axi_awid),
      .s_axi_awuser(s_axi_awuser),
      .s_axi_wdata(s_axi_wdata),
      .s_axi_wstrb(s_axi_wstrb),
      .s_axi_wvalid(s_axi_wvalid),
      .s_axi_wready(s_axi_wready),
      .s_axi_wlast(s_axi_wlast),
      .s_axi_wid(s_axi_wid),
      .s_axi_wuser(s_axi_wuser),
      .s_axi_bresp(s_axi_bresp),
      .s_axi_bvalid(s_axi_bvalid),
      .s_axi_bready(s_axi_bready),
      .s_axi_buser(s_axi_buser),
      .s_axi_bid(s_axi_bid),
      .s_axi_araddr(s_axi_araddr),
      .s_axi_arprot(s_axi_arprot),
      .s_axi_arvalid(s_axi_arvalid),
      .s_axi_arready(s_axi_arready),
      .s_axi_arsize(s_axi_arsize),
      .s_axi_arburst(s_axi_arburst),
      .s_axi_arcache(s_axi_arcache),
      .s_axi_arlock(s_axi_arlock),
      .s_axi_arlen(s_axi_arlen),
      .s_axi_arqos(s_axi_arqos),
      .s_axi_arregion(s_axi_arregion),
      .s_axi_aruser(s_axi_aruser),
      .s_axi_arid(s_axi_arid),
      .s_axi_rdata(s_axi_rdata),
      .s_axi_rresp(s_axi_rresp),
      .s_axi_rvalid(s_axi_rvalid),
      .s_axi_rready(s_axi_rready),
      .s_axi_rlast(s_axi_rlast),
      .s_axi_ruser(s_axi_ruser),
      .s_axi_rid(s_axi_rid),
      .aclk(aclk),
      .aresetn(aresetn)
    );
    
     assign m_axi_awid     = 0;
     assign m_axi_awaddr   = 0;
     assign m_axi_awlen    = 0;
     assign m_axi_awsize   = 0;
     assign m_axi_awburst  = 0;
     assign m_axi_awlock   = 0;
     assign m_axi_awcache  = 0;
     assign m_axi_awprot   = 0;
     assign m_axi_awregion = 0;
     assign m_axi_awqos    = 0;
     assign m_axi_awuser   = 0;
     assign m_axi_awvalid  = 0;
     assign m_axi_wid      = 0;
     assign m_axi_wdata    = 0;
     assign m_axi_wstrb    = 0;
     assign m_axi_wlast    = 0;
     assign m_axi_wuser    = 0;
     assign m_axi_wvalid   = 0;
     assign m_axi_bready   = 0;
     assign m_axi_arid     = 0;
     assign m_axi_araddr   = 0;
     assign m_axi_arlen    = 0;
     assign m_axi_arsize   = 0;
     assign m_axi_arburst  = 0;
     assign m_axi_arlock   = 0;
     assign m_axi_arcache  = 0;
     assign m_axi_arprot   = 0;
     assign m_axi_arregion = 0;
     assign m_axi_arqos    = 0;
     assign m_axi_aruser   = 0;
     assign m_axi_arvalid  = 0;
     assign m_axi_rready   = 0;
      
  end else if (C_RESERVE_MODE==2) begin : gen_reserve_mi
    
    axi_register_slice_v2_1_21_test_master #(
    .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
    .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
    .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
    .C_AXI_PROTOCOL(C_AXI_PROTOCOL),
    .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH),
    .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH),
    .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH),
    .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH),
    .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH)
    ) inst (
      .m_axi_awaddr(m_axi_awaddr),
      .m_axi_awprot(m_axi_awprot),
      .m_axi_awvalid(m_axi_awvalid),
      .m_axi_awready(m_axi_awready),
      .m_axi_awsize(m_axi_awsize),
      .m_axi_awburst(m_axi_awburst),
      .m_axi_awcache(m_axi_awcache),
      .m_axi_awlen(m_axi_awlen),
      .m_axi_awlock(m_axi_awlock),
      .m_axi_awqos(m_axi_awqos),
      .m_axi_awid(m_axi_awid),
      .m_axi_awuser(m_axi_awuser),
      .m_axi_wid(m_axi_wid),
      .m_axi_wdata(m_axi_wdata),
      .m_axi_wstrb(m_axi_wstrb),
      .m_axi_wvalid(m_axi_wvalid),
      .m_axi_wready(m_axi_wready),
      .m_axi_wlast(m_axi_wlast),
      .m_axi_wuser(m_axi_wuser),
      .m_axi_bresp(m_axi_bresp),
      .m_axi_bvalid(m_axi_bvalid),
      .m_axi_bready(m_axi_bready),
      .m_axi_buser(m_axi_buser),
      .m_axi_bid(m_axi_bid),
      .m_axi_araddr(m_axi_araddr),
      .m_axi_arprot(m_axi_arprot),
      .m_axi_arvalid(m_axi_arvalid),
      .m_axi_arready(m_axi_arready),
      .m_axi_arsize(m_axi_arsize),
      .m_axi_arburst(m_axi_arburst),
      .m_axi_arcache(m_axi_arcache),
      .m_axi_arlen(m_axi_arlen),
      .m_axi_arlock(m_axi_arlock),
      .m_axi_arqos(m_axi_arqos),
      .m_axi_arid(m_axi_arid),
      .m_axi_aruser(m_axi_aruser),
      .m_axi_rdata(m_axi_rdata),
      .m_axi_rresp(m_axi_rresp),
      .m_axi_rvalid(m_axi_rvalid),
      .m_axi_rready(m_axi_rready),
      .m_axi_rlast(m_axi_rlast),
      .m_axi_ruser(m_axi_ruser),
      .m_axi_rid(m_axi_rid),
      .aclk(aclk),
      .aresetn(aresetn)
    );
    
     assign s_axi_awready = 0;
     assign s_axi_wready  = 0;
     assign s_axi_bid     = 0;
     assign s_axi_bresp   = 0;
     assign s_axi_buser   = 0;
     assign s_axi_bvalid  = 0;
     assign s_axi_arready = 0;
     assign s_axi_rid     = 0;
     assign s_axi_rdata   = 0;
     assign s_axi_rresp   = 0;
     assign s_axi_rlast   = 0;
     assign s_axi_ruser   = 0;
     assign s_axi_rvalid  = 0;

  end else begin : gen_reg_slice  // Any normal reg-slice mode

    axi_infrastructure_v1_1_0_axi2vector #( 
      .C_AXI_PROTOCOL                ( C_AXI_PROTOCOL                ) ,
      .C_AXI_ID_WIDTH                ( C_AXI_ID_WIDTH                ) ,
      .C_AXI_ADDR_WIDTH              ( C_AXI_ADDR_WIDTH              ) ,
      .C_AXI_DATA_WIDTH              ( C_AXI_DATA_WIDTH              ) ,
      .C_AXI_SUPPORTS_USER_SIGNALS   ( C_AXI_SUPPORTS_USER_SIGNALS   ) ,
      .C_AXI_SUPPORTS_REGION_SIGNALS ( C_AXI_SUPPORTS_REGION_SIGNALS ) ,
      .C_AXI_AWUSER_WIDTH            ( C_AXI_AWUSER_WIDTH            ) ,
      .C_AXI_ARUSER_WIDTH            ( C_AXI_ARUSER_WIDTH            ) ,
      .C_AXI_WUSER_WIDTH             ( C_AXI_WUSER_WIDTH             ) ,
      .C_AXI_RUSER_WIDTH             ( C_AXI_RUSER_WIDTH             ) ,
      .C_AXI_BUSER_WIDTH             ( C_AXI_BUSER_WIDTH             ) ,
      .C_AWPAYLOAD_WIDTH             ( G_AXI_AWPAYLOAD_WIDTH         ) ,
      .C_WPAYLOAD_WIDTH              ( G_AXI_WPAYLOAD_WIDTH          ) ,
      .C_BPAYLOAD_WIDTH              ( G_AXI_BPAYLOAD_WIDTH          ) ,
      .C_ARPAYLOAD_WIDTH             ( G_AXI_ARPAYLOAD_WIDTH         ) ,
      .C_RPAYLOAD_WIDTH              ( G_AXI_RPAYLOAD_WIDTH          ) 
    )
    axi2vector_0 ( 
      .s_axi_awid      ( s_axi_awid      ) ,
      .s_axi_awaddr    ( s_axi_awaddr    ) ,
      .s_axi_awlen     ( s_axi_awlen     ) ,
      .s_axi_awsize    ( s_axi_awsize    ) ,
      .s_axi_awburst   ( s_axi_awburst   ) ,
      .s_axi_awlock    ( s_axi_awlock    ) ,
      .s_axi_awcache   ( s_axi_awcache   ) ,
      .s_axi_awprot    ( s_axi_awprot    ) ,
      .s_axi_awqos     ( s_axi_awqos     ) ,
      .s_axi_awuser    ( s_axi_awuser    ) ,
      .s_axi_awregion  ( s_axi_awregion  ) ,
      .s_axi_wid       ( s_axi_wid       ) ,
      .s_axi_wdata     ( s_axi_wdata     ) ,
      .s_axi_wstrb     ( s_axi_wstrb     ) ,
      .s_axi_wlast     ( s_axi_wlast     ) ,
      .s_axi_wuser     ( s_axi_wuser     ) ,
      .s_axi_bid       ( s_axi_bid       ) ,
      .s_axi_bresp     ( s_axi_bresp     ) ,
      .s_axi_buser     ( s_axi_buser     ) ,
      .s_axi_arid      ( s_axi_arid      ) ,
      .s_axi_araddr    ( s_axi_araddr    ) ,
      .s_axi_arlen     ( s_axi_arlen     ) ,
      .s_axi_arsize    ( s_axi_arsize    ) ,
      .s_axi_arburst   ( s_axi_arburst   ) ,
      .s_axi_arlock    ( s_axi_arlock    ) ,
      .s_axi_arcache   ( s_axi_arcache   ) ,
      .s_axi_arprot    ( s_axi_arprot    ) ,
      .s_axi_arqos     ( s_axi_arqos     ) ,
      .s_axi_aruser    ( s_axi_aruser    ) ,
      .s_axi_arregion  ( s_axi_arregion  ) ,
      .s_axi_rid       ( s_axi_rid       ) ,
      .s_axi_rdata     ( s_axi_rdata     ) ,
      .s_axi_rresp     ( s_axi_rresp     ) ,
      .s_axi_rlast     ( s_axi_rlast     ) ,
      .s_axi_ruser     ( s_axi_ruser     ) ,
      .s_awpayload ( s_awpayload ) ,
      .s_wpayload  ( s_wpayload  ) ,
      .s_bpayload  ( s_bpayload  ) ,
      .s_arpayload ( s_arpayload ) ,
      .s_rpayload  ( s_rpayload  ) 
    );
    
    axi_infrastructure_v1_1_0_vector2axi #( 
      .C_AXI_PROTOCOL                ( C_AXI_PROTOCOL                ) ,
      .C_AXI_ID_WIDTH                ( C_AXI_ID_WIDTH                ) ,
      .C_AXI_ADDR_WIDTH              ( C_AXI_ADDR_WIDTH              ) ,
      .C_AXI_DATA_WIDTH              ( C_AXI_DATA_WIDTH              ) ,
      .C_AXI_SUPPORTS_USER_SIGNALS   ( C_AXI_SUPPORTS_USER_SIGNALS   ) ,
      .C_AXI_SUPPORTS_REGION_SIGNALS ( C_AXI_SUPPORTS_REGION_SIGNALS ) ,
      .C_AXI_AWUSER_WIDTH            ( C_AXI_AWUSER_WIDTH            ) ,
      .C_AXI_ARUSER_WIDTH            ( C_AXI_ARUSER_WIDTH            ) ,
      .C_AXI_WUSER_WIDTH             ( C_AXI_WUSER_WIDTH             ) ,
      .C_AXI_RUSER_WIDTH             ( C_AXI_RUSER_WIDTH             ) ,
      .C_AXI_BUSER_WIDTH             ( C_AXI_BUSER_WIDTH             ) ,
      .C_AWPAYLOAD_WIDTH             ( G_AXI_AWPAYLOAD_WIDTH         ) ,
      .C_WPAYLOAD_WIDTH              ( G_AXI_WPAYLOAD_WIDTH          ) ,
      .C_BPAYLOAD_WIDTH              ( G_AXI_BPAYLOAD_WIDTH          ) ,
      .C_ARPAYLOAD_WIDTH             ( G_AXI_ARPAYLOAD_WIDTH         ) ,
      .C_RPAYLOAD_WIDTH              ( G_AXI_RPAYLOAD_WIDTH          ) 
    )
    vector2axi_0 ( 
      .m_awpayload    ( m_awpayload    ) ,
      .m_wpayload     ( m_wpayload     ) ,
      .m_bpayload     ( m_bpayload     ) ,
      .m_arpayload    ( m_arpayload    ) ,
      .m_rpayload     ( m_rpayload     ) ,
      .m_axi_awid     ( m_axi_awid     ) ,
      .m_axi_awaddr   ( m_axi_awaddr   ) ,
      .m_axi_awlen    ( m_axi_awlen    ) ,
      .m_axi_awsize   ( m_axi_awsize   ) ,
      .m_axi_awburst  ( m_axi_awburst  ) ,
      .m_axi_awlock   ( m_axi_awlock   ) ,
      .m_axi_awcache  ( m_axi_awcache  ) ,
      .m_axi_awprot   ( m_axi_awprot   ) ,
      .m_axi_awqos    ( m_axi_awqos    ) ,
      .m_axi_awuser   ( m_axi_awuser   ) ,
      .m_axi_awregion ( m_axi_awregion ) ,
      .m_axi_wid      ( m_axi_wid      ) ,
      .m_axi_wdata    ( m_axi_wdata    ) ,
      .m_axi_wstrb    ( m_axi_wstrb    ) ,
      .m_axi_wlast    ( m_axi_wlast    ) ,
      .m_axi_wuser    ( m_axi_wuser    ) ,
      .m_axi_bid      ( m_axi_bid      ) ,
      .m_axi_bresp    ( m_axi_bresp    ) ,
      .m_axi_buser    ( m_axi_buser    ) ,
      .m_axi_arid     ( m_axi_arid     ) ,
      .m_axi_araddr   ( m_axi_araddr   ) ,
      .m_axi_arlen    ( m_axi_arlen    ) ,
      .m_axi_arsize   ( m_axi_arsize   ) ,
      .m_axi_arburst  ( m_axi_arburst  ) ,
      .m_axi_arlock   ( m_axi_arlock   ) ,
      .m_axi_arcache  ( m_axi_arcache  ) ,
      .m_axi_arprot   ( m_axi_arprot   ) ,
      .m_axi_arqos    ( m_axi_arqos    ) ,
      .m_axi_aruser   ( m_axi_aruser   ) ,
      .m_axi_arregion ( m_axi_arregion ) ,
      .m_axi_rid      ( m_axi_rid      ) ,
      .m_axi_rdata    ( m_axi_rdata    ) ,
      .m_axi_rresp    ( m_axi_rresp    ) ,
      .m_axi_rlast    ( m_axi_rlast    ) ,
      .m_axi_ruser    ( m_axi_ruser    ) 
    );
    
  end  // Reserve SI/MI branch

  if ((C_REG_CONFIG_AW <= 9) && (C_RESERVE_MODE==0)) begin : aw
    axi_register_slice_v2_1_21_axic_register_slice # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_AWPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AW       ) 
    )
    aw_pipe (
      // System Signals
      .ACLK(aclk),
      .ARESET(reset),

      // Slave side
      .S_PAYLOAD_DATA(s_awpayload),
      .S_VALID(s_axi_awvalid),
      .S_READY(s_axi_awready),

      // Master side
      .M_PAYLOAD_DATA(m_awpayload),
      .M_VALID(m_axi_awvalid),
      .M_READY(m_axi_awready)
    );
    
  end else if ((C_REG_CONFIG_AW == 15) && (C_RESERVE_MODE==0)) begin : aw15
    
    axi_register_slice_v2_1_21_multi_slr # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_AWPAYLOAD_WIDTH ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_NUM_SLR_CROSSINGS (C_NUM_SLR_CROSSINGS) ,
      .C_PIPELINES_MASTER  (C_PIPELINES_MASTER_AW) ,
      .C_PIPELINES_SLAVE   (C_PIPELINES_SLAVE_AW) ,
      .C_PIPELINES_MIDDLE  (C_PIPELINES_MIDDLE_AW) 
    )
    aw_multi (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_awpayload),
      .S_VALID(s_axi_awvalid),
      .S_READY(s_axi_awready),

      // Master side
      .M_PAYLOAD_DATA(m_awpayload),
      .M_VALID(m_axi_awvalid),
      .M_READY(m_axi_awready)
    );
    
  end else if ((C_REG_CONFIG_AW == 16) && (C_RESERVE_MODE==0)) begin : aw16
    
    axi_register_slice_v2_1_21_auto_slr # (
      .C_DATA_WIDTH ( G_AXI_AWPAYLOAD_WIDTH ) 
    )
    aw_auto (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_awpayload),
      .S_VALID(s_axi_awvalid),
      .S_READY(s_axi_awready),

      // Master side
      .M_PAYLOAD_DATA(m_awpayload),
      .M_VALID(m_axi_awvalid),
      .M_READY(m_axi_awready)
    );
    
  end else if (C_RESERVE_MODE==0) begin : aw12
    
    localparam integer P_AW_EVEN_WIDTH = G_AXI_AWPAYLOAD_WIDTH[0] ? (G_AXI_AWPAYLOAD_WIDTH+1) : G_AXI_AWPAYLOAD_WIDTH;
    localparam integer P_AW_TDM_WIDTH = P_AW_EVEN_WIDTH/2;
    localparam integer P_AW_SLR_WIDTH = (C_REG_CONFIG_AW == 13) ? P_AW_TDM_WIDTH : G_AXI_AWPAYLOAD_WIDTH;
    
    wire [P_AW_SLR_WIDTH-1:0] slr_awpayload;
    wire slr_awhandshake;
    wire slr_awready;
        
    axi_register_slice_v2_1_21_source_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AW       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_AWPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_AW_SLR_WIDTH ),
      .C_PIPELINES  (0)
    )
    slr_master_aw (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .S_PAYLOAD_DATA ( s_awpayload ) ,
      .S_VALID        ( s_axi_awvalid   ) ,
      .S_READY        ( s_axi_awready   ) ,
      .laguna_m_reset_in  ( 1'b0 ) ,
      .laguna_m_reset_out  (  ) ,
      .laguna_m_payload   ( slr_awpayload ) , 
      .laguna_m_handshake ( slr_awhandshake   ) ,
      .laguna_m_ready     ( slr_awready   )
    );

    axi_register_slice_v2_1_21_dest_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AW       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_AWPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_AW_SLR_WIDTH ),
      .C_PIPELINES  (0),
      .C_SOURCE_LATENCY (2)
    )
    slr_slave_aw (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .laguna_s_reset_in  ( 1'b0 ) ,
      .laguna_s_reset_out  (  ) ,
      .laguna_s_payload   ( slr_awpayload ) ,
      .laguna_s_handshake ( slr_awhandshake   ) ,
      .laguna_s_ready     ( slr_awready   ) ,
      .M_PAYLOAD_DATA ( m_awpayload ) , 
      .M_VALID        ( m_axi_awvalid   ) ,
      .M_READY        ( m_axi_awready   )
    );
  end  // gen_aw
    
  if ((C_REG_CONFIG_W <= 9) && (C_RESERVE_MODE==0)) begin : w
    axi_register_slice_v2_1_21_axic_register_slice # (
      .C_FAMILY     ( C_FAMILY             ) ,
      .C_DATA_WIDTH ( G_AXI_WPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_W       ) 
    )
    w_pipe (
      // System Signals
      .ACLK(aclk),
      .ARESET(reset),

      // Slave side
      .S_PAYLOAD_DATA(s_wpayload),
      .S_VALID(s_axi_wvalid),
      .S_READY(s_axi_wready),

      // Master side
      .M_PAYLOAD_DATA(m_wpayload),
      .M_VALID(m_axi_wvalid),
      .M_READY(m_axi_wready)
    );
    
  end else if ((C_REG_CONFIG_W == 15) && (C_RESERVE_MODE==0)) begin : w15
    
    axi_register_slice_v2_1_21_multi_slr # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_WPAYLOAD_WIDTH ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_NUM_SLR_CROSSINGS (C_NUM_SLR_CROSSINGS) ,
      .C_PIPELINES_MASTER  (C_PIPELINES_MASTER_W) ,
      .C_PIPELINES_SLAVE   (C_PIPELINES_SLAVE_W) ,
      .C_PIPELINES_MIDDLE  (C_PIPELINES_MIDDLE_W) 
    )
    w_multi (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_wpayload),
      .S_VALID(s_axi_wvalid),
      .S_READY(s_axi_wready),

      // Master side
      .M_PAYLOAD_DATA(m_wpayload),
      .M_VALID(m_axi_wvalid),
      .M_READY(m_axi_wready)
    );
    
  end else if ((C_REG_CONFIG_W == 16) && (C_RESERVE_MODE==0)) begin : w16
    
    axi_register_slice_v2_1_21_auto_slr # (
      .C_DATA_WIDTH ( G_AXI_WPAYLOAD_WIDTH ) 
    )
    w_auto (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_wpayload),
      .S_VALID(s_axi_wvalid),
      .S_READY(s_axi_wready),

      // Master side
      .M_PAYLOAD_DATA(m_wpayload),
      .M_VALID(m_axi_wvalid),
      .M_READY(m_axi_wready)
    );
    
  end else if (C_RESERVE_MODE==0) begin : w12
    
    localparam integer P_W_EVEN_WIDTH = G_AXI_WPAYLOAD_WIDTH[0] ? (G_AXI_WPAYLOAD_WIDTH+1) : G_AXI_WPAYLOAD_WIDTH;
    localparam integer P_W_TDM_WIDTH = P_W_EVEN_WIDTH/2;
    localparam integer P_W_SLR_WIDTH = (C_REG_CONFIG_W == 13) ? P_W_TDM_WIDTH : G_AXI_WPAYLOAD_WIDTH;
    
    wire [P_W_SLR_WIDTH-1:0] slr_wpayload;
    wire slr_whandshake;
    wire slr_wready;
        
    axi_register_slice_v2_1_21_source_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_W       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_WPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_W_SLR_WIDTH ),
      .C_PIPELINES  (0)
    )
    slr_master_w (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .S_PAYLOAD_DATA ( s_wpayload ) ,
      .S_VALID        ( s_axi_wvalid   ) ,
      .S_READY        ( s_axi_wready   ) ,
      .laguna_m_reset_in  ( 1'b0 ) ,
      .laguna_m_reset_out  (  ) ,
      .laguna_m_payload   ( slr_wpayload ) , 
      .laguna_m_handshake ( slr_whandshake   ) ,
      .laguna_m_ready     ( slr_wready   )
    );

    axi_register_slice_v2_1_21_dest_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_W       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_WPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_W_SLR_WIDTH ),
      .C_PIPELINES  (0),
      .C_SOURCE_LATENCY (2)
    )
    slr_slave_w (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .laguna_s_reset_in  ( 1'b0 ) ,
      .laguna_s_reset_out  (  ) ,
      .laguna_s_payload   ( slr_wpayload ) ,
      .laguna_s_handshake ( slr_whandshake   ) ,
      .laguna_s_ready     ( slr_wready   ) ,
      .M_PAYLOAD_DATA ( m_wpayload ) , 
      .M_VALID        ( m_axi_wvalid   ) ,
      .M_READY        ( m_axi_wready   )
    );
  end  // gen_w

  if ((C_REG_CONFIG_B <= 9) && (C_RESERVE_MODE==0)) begin : b
    axi_register_slice_v2_1_21_axic_register_slice # (
      .C_FAMILY     ( C_FAMILY             ) ,
      .C_DATA_WIDTH ( G_AXI_BPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_B       ) 
    )
    b_pipe (
      // System Signals
      .ACLK(aclk),
      .ARESET(reset),

      // Slave side
      .S_PAYLOAD_DATA(m_bpayload),
      .S_VALID(m_axi_bvalid),
      .S_READY(m_axi_bready),

      // Master side
      .M_PAYLOAD_DATA(s_bpayload),
      .M_VALID(s_axi_bvalid),
      .M_READY(s_axi_bready)
    );
 
  end else if ((C_REG_CONFIG_B == 15) && (C_RESERVE_MODE==0)) begin : b15
    
    axi_register_slice_v2_1_21_multi_slr # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_BPAYLOAD_WIDTH ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_NUM_SLR_CROSSINGS (C_NUM_SLR_CROSSINGS) ,
      .C_PIPELINES_MASTER  (C_PIPELINES_MASTER_B) ,
      .C_PIPELINES_SLAVE   (C_PIPELINES_SLAVE_B) ,
      .C_PIPELINES_MIDDLE  (C_PIPELINES_MIDDLE_B) 
    )
    b_multi (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(m_bpayload),
      .S_VALID(m_axi_bvalid),
      .S_READY(m_axi_bready),

      // Master side
      .M_PAYLOAD_DATA(s_bpayload),
      .M_VALID(s_axi_bvalid),
      .M_READY(s_axi_bready)
    );
    
  end else if ((C_REG_CONFIG_B == 16) && (C_RESERVE_MODE==0)) begin : b16
    
    axi_register_slice_v2_1_21_auto_slr # (
      .C_DATA_WIDTH ( G_AXI_BPAYLOAD_WIDTH ) 
    )
    b_auto (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(m_bpayload),
      .S_VALID(m_axi_bvalid),
      .S_READY(m_axi_bready),

      // Master side
      .M_PAYLOAD_DATA(s_bpayload),
      .M_VALID(s_axi_bvalid),
      .M_READY(s_axi_bready)
    );
    
  end else if (C_RESERVE_MODE==0) begin : b12
    
    localparam integer P_B_EVEN_WIDTH = G_AXI_BPAYLOAD_WIDTH[0] ? (G_AXI_BPAYLOAD_WIDTH+1) : G_AXI_BPAYLOAD_WIDTH;
    localparam integer P_B_TDM_WIDTH = P_B_EVEN_WIDTH/2;
    localparam integer P_B_SLR_WIDTH = (C_REG_CONFIG_B == 13) ? P_B_TDM_WIDTH : G_AXI_BPAYLOAD_WIDTH;
    
    wire [P_B_SLR_WIDTH-1:0] slr_bpayload;
    wire slr_bhandshake;
    wire slr_bready;
        
    axi_register_slice_v2_1_21_source_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_B       ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_DATA_WIDTH ( G_AXI_BPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_B_SLR_WIDTH ),
      .C_PIPELINES  (0)
    )
    slr_slave_b (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .S_PAYLOAD_DATA ( m_bpayload ) ,
      .S_VALID        ( m_axi_bvalid   ) ,
      .S_READY        ( m_axi_bready   ) ,
      .laguna_m_reset_in  ( 1'b0 ) ,
      .laguna_m_reset_out  (  ) ,
      .laguna_m_payload   ( slr_bpayload ) , 
      .laguna_m_handshake ( slr_bhandshake   ) ,
      .laguna_m_ready     ( slr_bready   )
    );

    axi_register_slice_v2_1_21_dest_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_B       ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_DATA_WIDTH ( G_AXI_BPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_B_SLR_WIDTH ),
      .C_PIPELINES  (0),
      .C_SOURCE_LATENCY (2)
    )
    slr_master_b (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .laguna_s_reset_in  ( 1'b0 ) ,
      .laguna_s_reset_out  (  ) ,
      .laguna_s_payload   ( slr_bpayload ) ,
      .laguna_s_handshake ( slr_bhandshake   ) ,
      .laguna_s_ready     ( slr_bready   ) ,
      .M_PAYLOAD_DATA ( s_bpayload ) , 
      .M_VALID        ( s_axi_bvalid   ) ,
      .M_READY        ( s_axi_bready   )
    );
  end  // gen_b

  if ((C_REG_CONFIG_AR <= 9) && (C_RESERVE_MODE==0)) begin : ar
    axi_register_slice_v2_1_21_axic_register_slice # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_ARPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AR       ) 
    )
    ar_pipe (
      // System Signals
      .ACLK(aclk),
      .ARESET(reset),

      // Slave side
      .S_PAYLOAD_DATA(s_arpayload),
      .S_VALID(s_axi_arvalid),
      .S_READY(s_axi_arready),

      // Master side
      .M_PAYLOAD_DATA(m_arpayload),
      .M_VALID(m_axi_arvalid),
      .M_READY(m_axi_arready)
    );
    
  end else if ((C_REG_CONFIG_AR == 15) && (C_RESERVE_MODE==0)) begin : ar15
    
    axi_register_slice_v2_1_21_multi_slr # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_ARPAYLOAD_WIDTH ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_NUM_SLR_CROSSINGS (C_NUM_SLR_CROSSINGS) ,
      .C_PIPELINES_MASTER  (C_PIPELINES_MASTER_AR) ,
      .C_PIPELINES_SLAVE   (C_PIPELINES_SLAVE_AR) ,
      .C_PIPELINES_MIDDLE  (C_PIPELINES_MIDDLE_AR) 
    )
    ar_multi (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_arpayload),
      .S_VALID(s_axi_arvalid),
      .S_READY(s_axi_arready),

      // Master side
      .M_PAYLOAD_DATA(m_arpayload),
      .M_VALID(m_axi_arvalid),
      .M_READY(m_axi_arready)
    );
    
  end else if ((C_REG_CONFIG_AR == 16) && (C_RESERVE_MODE==0)) begin : ar16
    
    axi_register_slice_v2_1_21_auto_slr # (
      .C_DATA_WIDTH ( G_AXI_ARPAYLOAD_WIDTH ) 
    )
    ar_auto (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(s_arpayload),
      .S_VALID(s_axi_arvalid),
      .S_READY(s_axi_arready),

      // Master side
      .M_PAYLOAD_DATA(m_arpayload),
      .M_VALID(m_axi_arvalid),
      .M_READY(m_axi_arready)
    );
    
  end else if (C_RESERVE_MODE==0) begin : ar12
    
    localparam integer P_AR_EVEN_WIDTH = G_AXI_ARPAYLOAD_WIDTH[0] ? (G_AXI_ARPAYLOAD_WIDTH+1) : G_AXI_ARPAYLOAD_WIDTH;
    localparam integer P_AR_TDM_WIDTH = P_AR_EVEN_WIDTH/2;
    localparam integer P_AR_SLR_WIDTH = (C_REG_CONFIG_AR == 13) ? P_AR_TDM_WIDTH : G_AXI_ARPAYLOAD_WIDTH;
    
    wire [P_AR_SLR_WIDTH-1:0] slr_arpayload;
    wire slr_arhandshake;
    wire slr_arready;
        
    axi_register_slice_v2_1_21_source_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AR       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_ARPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_AR_SLR_WIDTH ),
      .C_PIPELINES  (0)
    )
    slr_master_ar (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .S_PAYLOAD_DATA ( s_arpayload ) ,
      .S_VALID        ( s_axi_arvalid   ) ,
      .S_READY        ( s_axi_arready   ) ,
      .laguna_m_reset_in  ( 1'b0 ) ,
      .laguna_m_reset_out  (  ) ,
      .laguna_m_payload   ( slr_arpayload ) , 
      .laguna_m_handshake ( slr_arhandshake   ) ,
      .laguna_m_ready     ( slr_arready   )
    );

    axi_register_slice_v2_1_21_dest_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_AR       ) ,
      .C_CHANNEL    ( P_FORWARD ),
      .C_DATA_WIDTH ( G_AXI_ARPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_AR_SLR_WIDTH ),
      .C_PIPELINES  (0),
      .C_SOURCE_LATENCY (2)
    )
    slr_slave_ar (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .laguna_s_reset_in  ( 1'b0 ) ,
      .laguna_s_reset_out  (  ) ,
      .laguna_s_payload   ( slr_arpayload ) ,
      .laguna_s_handshake ( slr_arhandshake   ) ,
      .laguna_s_ready     ( slr_arready   ) ,
      .M_PAYLOAD_DATA ( m_arpayload ) , 
      .M_VALID        ( m_axi_arvalid   ) ,
      .M_READY        ( m_axi_arready   )
    );
  end  // gen_ar
        
  if ((C_REG_CONFIG_R <= 9) && (C_RESERVE_MODE==0)) begin : r
    axi_register_slice_v2_1_21_axic_register_slice # (
      .C_FAMILY     ( C_FAMILY             ) ,
      .C_DATA_WIDTH ( G_AXI_RPAYLOAD_WIDTH ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_R       ) 
    )
    r_pipe (
      // System Signals
      .ACLK(aclk),
      .ARESET(reset),

      // Slave side
      .S_PAYLOAD_DATA(m_rpayload),
      .S_VALID(m_axi_rvalid),
      .S_READY(m_axi_rready),

      // Master side
      .M_PAYLOAD_DATA(s_rpayload),
      .M_VALID(s_axi_rvalid),
      .M_READY(s_axi_rready)
    );
    
  end else if ((C_REG_CONFIG_R == 15) && (C_RESERVE_MODE==0)) begin : r15
    
    axi_register_slice_v2_1_21_multi_slr # (
      .C_FAMILY     ( C_FAMILY              ) ,
      .C_DATA_WIDTH ( G_AXI_RPAYLOAD_WIDTH ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_NUM_SLR_CROSSINGS (C_NUM_SLR_CROSSINGS) ,
      .C_PIPELINES_MASTER  (C_PIPELINES_MASTER_R) ,
      .C_PIPELINES_SLAVE   (C_PIPELINES_SLAVE_R) ,
      .C_PIPELINES_MIDDLE  (C_PIPELINES_MIDDLE_R) 
    )
    r_multi (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(m_rpayload),
      .S_VALID(m_axi_rvalid),
      .S_READY(m_axi_rready),

      // Master side
      .M_PAYLOAD_DATA(s_rpayload),
      .M_VALID(s_axi_rvalid),
      .M_READY(s_axi_rready)
    );
    
  end else if ((C_REG_CONFIG_R == 16) && (C_RESERVE_MODE==0)) begin : r16
    
    axi_register_slice_v2_1_21_auto_slr # (
      .C_DATA_WIDTH ( G_AXI_RPAYLOAD_WIDTH ) 
    )
    r_auto (
      // System Signals
      .ACLK(aclk),
      .ARESETN(aresetn),

      // Slave side
      .S_PAYLOAD_DATA(m_rpayload),
      .S_VALID(m_axi_rvalid),
      .S_READY(m_axi_rready),

      // Master side
      .M_PAYLOAD_DATA(s_rpayload),
      .M_VALID(s_axi_rvalid),
      .M_READY(s_axi_rready)
    );
    
  end else if (C_RESERVE_MODE==0) begin : r12
    
    localparam integer P_R_EVEN_WIDTH = G_AXI_RPAYLOAD_WIDTH[0] ? (G_AXI_RPAYLOAD_WIDTH+1) : G_AXI_RPAYLOAD_WIDTH;
    localparam integer P_R_TDM_WIDTH = P_R_EVEN_WIDTH/2;
    localparam integer P_R_SLR_WIDTH = (C_REG_CONFIG_R == 13) ? P_R_TDM_WIDTH : G_AXI_RPAYLOAD_WIDTH;
    
    wire [P_R_SLR_WIDTH-1:0] slr_rpayload;
    wire slr_rhandshake;
    wire slr_rready;
        
    axi_register_slice_v2_1_21_source_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_R       ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_DATA_WIDTH ( G_AXI_RPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_R_SLR_WIDTH ),
      .C_PIPELINES  (0)
    )
    slr_slave_r (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .S_PAYLOAD_DATA ( m_rpayload ) ,
      .S_VALID        ( m_axi_rvalid   ) ,
      .S_READY        ( m_axi_rready   ) ,
      .laguna_m_reset_in  ( 1'b0 ) ,
      .laguna_m_reset_out  (  ) ,
      .laguna_m_payload   ( slr_rpayload ) , 
      .laguna_m_handshake ( slr_rhandshake   ) ,
      .laguna_m_ready     ( slr_rready   )
    );

    axi_register_slice_v2_1_21_dest_region_slr #(
      .C_FAMILY     ( C_FAMILY         ) ,
      .C_REG_CONFIG ( C_REG_CONFIG_R       ) ,
      .C_CHANNEL    ( P_RESPONSE ),
      .C_DATA_WIDTH ( G_AXI_RPAYLOAD_WIDTH ) ,
      .C_SLR_WIDTH  ( P_R_SLR_WIDTH ),
      .C_PIPELINES  (0),
      .C_SOURCE_LATENCY (2)
    )
    slr_master_r (
      .ACLK           ( aclk            ) ,
      .ACLK2X         ( aclk2x            ) ,
      .ARESETN        ( aresetn        ) ,
      .laguna_s_reset_in  ( 1'b0 ) ,
      .laguna_s_reset_out  (  ) ,
      .laguna_s_payload   ( slr_rpayload ) ,
      .laguna_s_handshake ( slr_rhandshake   ) ,
      .laguna_s_ready     ( slr_rready   ) ,
      .M_PAYLOAD_DATA ( s_rpayload ) , 
      .M_VALID        ( s_axi_rvalid   ) ,
      .M_READY        ( s_axi_rready   )
    );
  end  // gen_r

endgenerate
endmodule // axi_register_slice


