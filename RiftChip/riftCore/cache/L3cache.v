/*
* @File name: L3cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-19 10:11:07
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-19 19:27:02
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

module L3cache
(
	parameter DATA_WIDTH = 4096,
	// parameter CACHE_BLOCK = 1,
	parameter CACHE_LINE = 256,

	//from L2C
	parameter L2C_DW = 64,
	parameter L2C_AW = 32,
	parameter L2C_ID_W = 1,

	//from DDR
	parameter MEM_DW = 64,
	parameter MEM_AW = 64,
	parameter MEM_MEM_ID_W = 1,
	parameter MEM_USER_W = 1

)
(

	//form L2cache
	input [L2C_ID_W-1:0] L2C_AXI_AWID,
	input [L2C_AW-1:0] L2C_AXI_AWADDR,
	input [7:0] L2C_AXI_AWLEN,
	input [2:0] L2C_AXI_AWSIZE,
	input [1:0] L2C_AXI_AWBURST,
	input [2:0] L2C_AXI_AWPROT,
	input L2C_AXI_AWVALID,
	output L2C_AXI_AWREADY,

	input [L2C_DW-1:0] L2C_AXI_WDATA,
	input [(L2C_DW/8)-1:0] L2C_AXI_WSTRB,
	input L2C_AXI_WLAST,
	input L2C_AXI_WVALID,
	output L2C_AXI_WREADY,

	output [L2C_ID_W-1:0] L2C_AXI_BID,
	output [1:0] L2C_AXI_BRESP,
	output L2C_AXI_BVALID,
	input L2C_AXI_BREADY,

	input [L2C_ID_W-1:0] L2C_AXI_ARID,
	input [L2C_AW-1:0] L2C_AXI_ARADDR,
	input [7:0] L2C_AXI_ARLEN,
	input [2:0] L2C_AXI_ARSIZE,
	input [1:0] L2C_AXI_ARBURST,
	input [2:0] L2C_AXI_ARPROT,
	input L2C_AXI_ARVALID,
	output L2C_AXI_ARREADY,

	output [L2C_ID_W-1:0] L2C_AXI_RID,
	output [L2C_DW-1:0] L2C_AXI_RDATA,
	output [1:0] L2C_AXI_RRESP,
	output L2C_AXI_RLAST,
	output L2C_AXI_RVALID,
	input L2C_AXI_RREADY,


	//from DDR
	output [MEM_ID_W-1:0] MEM_AXI_AWID,
	output [MEM_AW-1:0] MEM_AXI_AWADDR,
	output [7:0] MEM_AXI_AWLEN,
	output [2:0] MEM_AXI_AWSIZE,
	output [1:0] MEM_AXI_AWBURST,
	output MEM_AXI_AWLOCK,
	output [3:0] MEM_AXI_AWCACHE,
	output [2:0] MEM_AXI_AWPROT,
	output [3:0] MEM_AXI_AWQOS,
	output [MEM_USER_W-1:0] MEM_AXI_AWUSER,
	output MEM_AXI_AWVALID,
	input MEM_AXI_AWREADY,

	output [MEM_DW-1:0] MEM_AXI_WDATA,
	output [MEM_DW/8-1:0] MEM_AXI_WSTRB,
	output MEM_AXI_WLAST,
	output [MEM_USER_W-1:0] MEM_AXI_WUSER,
	output MEM_AXI_WVALID,
	input MEM_AXI_WREADY,

	input [MEM_ID_W-1:0] MEM_AXI_BID,
	input [1:0] MEM_AXI_BRESP,
	input [MEM_USER_W-1:0] MEM_AXI_BUSER,
	input MEM_AXI_BVALID,
	output MEM_AXI_BREADY,

	output [MEM_ID_W-1:0] MEM_AXI_ARID,
	output [MEM_AW-1:0] MEM_AXI_ARADDR,
	output [7:0] MEM_AXI_ARLEN,
	output [2:0] MEM_AXI_ARSIZE,
	output [1:0] MEM_AXI_ARBURST,
	output MEM_AXI_ARLOCK,
	output [3:0] MEM_AXI_ARCACHE,
	output [2:0] MEM_AXI_ARPROT,
	output [3:0] MEM_AXI_ARQOS,
	output [MEM_USER_W-1:0] MEM_AXI_ARUSER,
	output MEM_AXI_ARVALID,
	input MEM_AXI_ARREADY,

	input [MEM_ID_W-1:0] MEM_AXI_RID,
	input [MEM_DW-1:0] MEM_AXI_RDATA,
	input [1:0] MEM_AXI_RRESP,
	input MEM_AXI_RLAST,
	input [MEM_USER_W-1:0] MEM_AXI_RUSER,
	input MEM_AXI_RVALID,
	output MEM_AXI_RREADY,


	input CLK,
	input RSTn

);

	localparam ADDR_LSB = $clog2(DATA_WIDTH/8)
	localparam LINE_W = $clog2(CACHE_LINE);
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;
	localparam BANK = 4;
	localparam BANK_WIDTH = DATA_WIDTH / BANK;


wire [31:0] addr_req;


wire [$clog2(BANK)-1:0] bank_sel = addr_req[ ADDR_LSB-1 -:  $clog2(BANK)];
wire [LINE_W-1:0] address_sel = addr_req[ADDR_LSB +: LINE_W];
wire [TAG_W-1:0] tag_sel = addr_req[31 -: TAG_W];




wire tag_valid;
wire [ TAG_W - 1 : 0] tag_info;
wire isTagHit;
wire [ DATA_WIDTH - 1 : 0] data_hit;

wire [(TAG_W+8) / 8 -1 : 0] tag_data_wstrb;
wire [DATA_WIDTH/8-1] bank_data_wstrb;

wire [ BANK - 1 : 0 ] bank_en_w;
wire [ BANK - 1 : 0 ] bank_en_r;
wire tag_en_w;
wire tag_en_r;

wire [ DATA_WIDTH - 1 : 0 ] bank_data_w;
wire [ DATA_WIDTH - 1 : 0 ] bank_data_r;
wire [ (TAG_W+1) - 1 : 0 ] tag_data_w;
wire [ (TAG_W+1) - 1 : 0 ] tag_data_r;

wire [LINE_W-1:0] tag_addr_r;
wire [LINE_W-1:0] tag_addr_w;
wire [LINE_W-1:0] bank_addr_r;
wire [LINE_W-1:0] bank_addr_w;



	gen_sram # ( .DW((TAG_W+1)), .AW(LINE_W)) tag_ram
	(
		.data_w(tag_data_w),
		.addr_w(tag_addr_w),
		.data_wstrb(tag_data_wstrb),
		.en_w(tag_en_w),

		.data_r(tag_data_r),
		.addr_r(tag_addr_r),
		.en_r(tag_en_r),

		.CLK(CLK)		
	);





	for ( genvar j = 0; j < BANK; j = j + 1 ) begin
		gen_sram # ( .DW(BANK_WIDTH), .AW(LINE_W)) data_bank_ram
		(
			.data_w(bank_data_w[BANK_WIDTH*j +: BANK_WIDTH]),
			.addr_w(bank_addr_w),
			.data_wstrb(bank_data_wstrb[BANK_WIDTH/8 * j +: BANK_WIDTH/8]),
			.en_w(bank_en_w[j]),

			.data_r(bank_data_r[BANK_WIDTH*j +: BANK_WIDTH]),
			.addr_r(bank_addr_r),
			.en_r(bank_en_r[j]),

			.CLK(CLK)		
		);

	end























// LLLLLLLLLLL              222222222222222           CCCCCCCCCCCCC                        PPPPPPPPPPPPPPPPP        OOOOOOOOO     RRRRRRRRRRRRRRRRR   TTTTTTTTTTTTTTTTTTTTTTT
// L:::::::::L             2:::::::::::::::22      CCC::::::::::::C                        P::::::::::::::::P     OO:::::::::OO   R::::::::::::::::R  T:::::::::::::::::::::T
// L:::::::::L             2::::::222222:::::2   CC:::::::::::::::C                        P::::::PPPPPP:::::P  OO:::::::::::::OO R::::::RRRRRR:::::R T:::::::::::::::::::::T
// LL:::::::LL             2222222     2:::::2  C:::::CCCCCCCC::::C                        PP:::::P     P:::::PO:::::::OOO:::::::ORR:::::R     R:::::RT:::::TT:::::::TT:::::T
//   L:::::L                           2:::::2 C:::::C       CCCCCC                          P::::P     P:::::PO::::::O   O::::::O  R::::R     R:::::RTTTTTT  T:::::T  TTTTTT
//   L:::::L                           2:::::2C:::::C                                        P::::P     P:::::PO:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   L:::::L                        2222::::2 C:::::C                                        P::::PPPPPP:::::P O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   L:::::L                   22222::::::22  C:::::C                                        P:::::::::::::PP  O:::::O     O:::::O  R:::::::::::::RR          T:::::T        
//   L:::::L                 22::::::::222    C:::::C                                        P::::PPPPPPPPP    O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   L:::::L                2:::::22222       C:::::C                                        P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   L:::::L               2:::::2            C:::::C                                        P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   L:::::L         LLLLLL2:::::2             C:::::C       CCCCCC                          P::::P            O::::::O   O::::::O  R::::R     R:::::R        T:::::T        
// LL:::::::LLLLLLLLL:::::L2:::::2       222222 C:::::CCCCCCCC::::C                        PP::::::PP          O:::::::OOO:::::::ORR:::::R     R:::::R      TT:::::::TT      
// L::::::::::::::::::::::L2::::::2222222:::::2  CC:::::::::::::::C                        P::::::::P           OO:::::::::::::OO R::::::R     R:::::R      T:::::::::T      
// L::::::::::::::::::::::L2::::::::::::::::::2    CCC::::::::::::C                        P::::::::P             OO:::::::::OO   R::::::R     R:::::R      T:::::::::T      
// LLLLLLLLLLLLLLLLLLLLLLLL22222222222222222222       CCCCCCCCCCCCC                        PPPPPPPPPP               OOOOOOOOO     RRRRRRRR     RRRRRRR      TTTTTTTTTTT      
//                                                                 ________________________                                                                                  
//                                                                 _::::::::::::::::::::::_                                                                                  
//                                                                 ________________________                                                                                  



	localparam ADDR_LSB = $clog2(L2C_DW/8);


	wire [L2C_AW-1:0] aw_wrap_size; 
	wire [L2C_AW-1:0] ar_wrap_size; 
	wire aw_wrap_en, ar_wrap_en;

	wire axi_awready_set, axi_awready_rst, axi_awready_qout;
	wire axi_awv_awr_flag_set, axi_awv_awr_flag_rst, axi_awv_awr_flag_qout;
	wire [L2C_AW-1:0] axi_awaddr_dnxta;
	wire [L2C_AW-1:0] axi_awaddr_dnxtb;
	wire [L2C_AW-1:0] axi_awaddr_qout;
	wire axi_awaddr_ena, axi_awaddr_enb;
	wire axi_awburst_en;
	wire [1:0] axi_awburst_dnxt;
	wire [1:0] axi_awburst_qout;
	wire axi_awlen_en;
	wire [7:0] axi_awlen_dnxt;
	wire [7:0] axi_awlen_qout;
	wire [7:0] axi_awlen_cnt_dnxta;
	wire [7:0] axi_awlen_cnt_dnxtb;
	wire [7:0] axi_awlen_cnt_qout;
	wire axi_awlen_cnt_ena, axi_awlen_cnt_enb;
	wire axi_wready_set, axi_wready_rst, axi_wready_qout;
	wire axi_bvalid_set, axi_bvalid_rst, axi_bvalid_qout;
	wire axi_arready_set, axi_arready_rst, axi_arready_qout;
	wire axi_arv_arr_flag_set, axi_arv_arr_flag_rst, axi_arv_arr_flag_qout;
	wire [L2C_AW-1:0] axi_araddr_dnxta;
	wire [L2C_AW-1:0] axi_araddr_dnxtb;
	wire [L2C_AW-1:0] axi_araddr_qout;
	wire axi_araddr_ena, axi_araddr_enb, axi_arburst_en;
	wire [1:0] axi_arburst_dnxt;
	wire [1:0] axi_arburst_qout;
	wire axi_arlen_en;
	wire [7:0] axi_arlen_dnxt;
	wire [7:0] axi_arlen_qout;
	wire [7:0] axi_arlen_cnt_dnxta;
	wire [7:0] axi_arlen_cnt_dnxtb;
	wire [7:0] axi_arlen_cnt_qout;
	wire axi_arlen_cnt_ena, axi_arlen_cnt_enb;
	wire axi_rvalid_set, axi_rvalid_rst, axi_rvalid_qout;
	wire axi_rlast_set, axi_rlast_rst, axi_rlast_qout;


	assign L2C_AXI_AWREADY = axi_awready_qout;
	assign L2C_AXI_WREADY	= axi_wready_qout;
	assign L2C_AXI_BRESP = 2'b00;
	assign L2C_AXI_BUSER = 'b0;
	assign L2C_AXI_BVALID	= axi_bvalid_qout;
	assign L2C_AXI_ARREADY = axi_arready_qout;
	assign L2C_AXI_RDATA = ;
	assign L2C_AXI_RRESP = 2'b00;
	assign L2C_AXI_RLAST = axi_rlast_qout;
	assign L2C_AXI_RUSER = 'd0;
	assign L2C_AXI_RVALID	= axi_rvalid_qout;
	assign L2C_AXI_BID = L2C_AXI_AWID;
	assign L2C_AXI_RID = L2C_AXI_ARID;
	assign aw_wrap_size = (L2C_DW/8 * (axi_awlen_qout)); 
	assign ar_wrap_size = (L2C_DW/8 * (axi_arlen_qout)); 
	assign aw_wrap_en = ((axi_awaddr_qout & aw_wrap_size) == aw_wrap_size) ? 1'b1 : 1'b0;
	assign ar_wrap_en = ((axi_araddr_qout & ar_wrap_size) == ar_wrap_size) ? 1'b1 : 1'b0;





	assign axi_awready_set =  (~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout);
	assign axi_awready_rst = ~(~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout) & ~(L2C_AXI_WLAST & axi_wready_qout);
	gen_rsffr axi_awready_rsffr (.set_in(axi_awready_set), .rst_in(axi_awready_rst), .qout(axi_awready_qout), .CLK(CLK), .RSTn(RSTn));

	assign axi_awv_awr_flag_set = (~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout);
	assign axi_awv_awr_flag_rst = ( axi_awready_qout | ~L2C_AXI_AWVALID | axi_awv_awr_flag_qout |  axi_arv_arr_flag_qout) & (L2C_AXI_WLAST & axi_wready_qout);
	gen_rsffr axi_awv_awr_flag_rsffr (.set_in(axi_awv_awr_flag_set), .rst_in(axi_awv_awr_flag_rst), .qout(axi_awv_awr_flag_qout), .CLK(CLK), .RSTn(RSTn));

	assign axi_awaddr_dnxta = L2C_AXI_AWADDR;
	assign axi_awaddr_dnxtb = ( {L2C_AW{axi_awburst == 2'b00}} & axi_awaddr_qout )
							| 
							( {L2C_AW{axi_awburst == 2'b01}} & axi_awaddr_qout + (1<<ADDR_LSB) )
							|
							( {L2C_AW{axi_awburst == 2'b10}} & 
								(
									{L2C_AW{ aw_wrap_en}} & (axi_awaddr_qout - aw_wrap_size)
									|
									{L2C_AW{~aw_wrap_en}} & (axi_awaddr_qout + (1<<ADDR_LSB) )
								)
							);
	assign axi_awaddr_ena = ~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout;
	assign axi_awaddr_enb = (axi_awlen_cnt_qout <= axi_awlen_qout) & axi_wready_qout & L2C_AXI_WVALID;
	gen_dpdffren # (.DW(L2C_AW)) axi_awaddr_dpdffren( .dnxta(axi_awaddr_dnxta), .ena(axi_awaddr_ena), .dnxtb(axi_awaddr_dnxtb), .enb(axi_awaddr_enb), .qout(axi_awaddr_qout), .CLK(CLK), .RSTn(RSTn) );

	assign axi_awburst_en = (~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout);
	assign axi_awburst_dnxt = L2C_AXI_AWBURST;
	gen_dffren # (.DW(2)) axi_awburst_dffren (.dnxt(axi_awburst_dnxt), .qout(axi_awburst_qout), .en(axi_awburst_en), .CLK(CLK), .RSTn(RSTn));




	assign axi_awlen_en = ~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout;
	assign axi_awlen_dnxt = L2C_AXI_AWLEN;
	gen_dffren # (.DW(8)) axi_awlen_dffren (.dnxt(axi_awlen_dnxt), .qout(axi_awlen_qout), .en(axi_awlen_en), .CLK(CLK), .RSTn(RSTn));


	assign axi_awlen_cnt_dnxta = 8'd0;
	assign axi_awlen_cnt_dnxtb = axi_awlen_cnt_qout + 8'd1;
	assign axi_awlen_cnt_ena = ~axi_awready_qout & L2C_AXI_AWVALID & ~axi_awv_awr_flag_qout;
	assign axi_awlen_cnt_enb = (axi_awlen_cnt_qout <= axi_awlen_qout) & axi_wready_qout & L2C_AXI_WVALID;
	gen_dpdffren # (.DW(8)) axi_awlen_cnt_dpdffren( .dnxta(axi_awlen_cnt_dnxta), .ena(axi_awlen_cnt_ena), .dnxtb(axi_awlen_cnt_dnxtb), .enb(axi_awlen_cnt_enb), .qout(axi_awlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );


	assign axi_wready_set = ~axi_wready_qout & L2C_AXI_WVALID & axi_awv_awr_flag_qout;
	assign axi_wready_rst =  axi_wready_qout & L2C_AXI_WLAST;
	gen_rsffr axi_wready_rsffr (.set_in(axi_wready_set), .rst_in(axi_wready_rst), .qout(axi_wready_qout), .CLK(CLK), .RSTn(RSTn));



	assign axi_bvalid_set = ~axi_bvalid_qout & axi_awv_awr_flag_qout & axi_wready_qout & L2C_AXI_WVALID & L2C_AXI_WLAST;
	assign axi_bvalid_rst =  axi_bvalid_qout & L2C_AXI_BREADY;
	gen_rsffr axi_bvalid_rsffr (.set_in(axi_bvalid_set), .rst_in(axi_bvalid_rst), .qout(axi_bvalid_qout), .CLK(CLK), .RSTn(RSTn));




	
	assign axi_arready_set = (~axi_arready & L2C_AXI_ARVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout);
	assign axi_arready_rst = ~(~axi_arready & L2C_AXI_ARVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout) & ~(axi_rvalid_qout & L2C_AXI_RREADY & axi_arlen_cnt_qout == axi_arlen_qout);
	gen_rsffr axi_arready_rsffr (.set_in(axi_arready_set), .rst_in(axi_arready_rst), .qout(axi_arready_qout), .CLK(CLK), .RSTn(RSTn));

	assign axi_arv_arr_flag_set = (~axi_arready_qout &  L2C_AXI_ARVALID & ~axi_awv_awr_flag_qout & ~axi_arv_arr_flag_qout);
	assign axi_arv_arr_flag_rst = ( axi_arready_qout | ~L2C_AXI_ARVALID |  axi_awv_awr_flag_qout |  axi_arv_arr_flag_qout) & (axi_rvalid_qout & L2C_AXI_RREADY & axi_arlen_cnt_qout == axi_arlen_qout);
	gen_rsffr axi_arv_arr_flag_rsffr (.set_in(axi_arv_arr_flag_set), .rst_in(axi_arv_arr_flag_rst), .qout(axi_arv_arr_flag_qout), .CLK(CLK), .RSTn(RSTn));



	assign axi_araddr_dnxta = L2C_AXI_ARADDR;
	assign axi_araddr_dnxtb = ({L2C_AW{axi_arburst_qout == 2'b00}} & axi_araddr_qout)
							|
							({L2C_AW{axi_arburst_qout == 2'b01}} & axi_araddr_qout + (1<<ADDR_LSB))
							|
							({L2C_AW{axi_arburst_qout == 2'b10}} & 
								(
									({L2C_AW{ ar_wrap_en}} & (axi_araddr_qout - ar_wrap_size) )
									|
									({L2C_AW{~ar_wrap_en}} & (axi_araddr_qout + (1<<ADDR_LSB)))
								)
							);
	assign axi_araddr_ena = (~axi_arready_qout & L2C_AXI_ARVALID & ~axi_arv_arr_flag_qout);
	assign axi_araddr_enb = ((axi_arlen_cnt_qout <= axi_arlen_qout) & axi_rvalid_qout & L2C_AXI_RREADY);
	gen_dpdffren # (.DW(L2C_AW)) axi_araddr_dpdffren( .dnxta(axi_araddr_dnxta), .ena(axi_araddr_ena), .dnxtb(axi_araddr_dnxtb), .enb(axi_araddr_enb), .qout(axi_araddr_qout), .CLK(CLK), .RSTn(RSTn) );

	
	assign axi_arburst_en = (~axi_arready_qout & L2C_AXI_ARVALID & ~axi_arv_arr_flag_qout);
	assign axi_arburst_dnxt = L2C_AXI_ARBURST;
	gen_dffren # (.DW(2)) axi_arburst_dffren (.dnxt(axi_arburst_dnxt), .qout(axi_arburst_qout), .en(axi_arburst_en), .CLK(CLK), .RSTn(RSTn));


	assign axi_arlen_en = (~axi_arready_qout && L2C_AXI_ARVALID && ~axi_arv_arr_flag_qout);
	assign axi_arlen_dnxt = L2C_AXI_ARLEN;
	gen_dffren # (.DW(8)) axi_arlen_dffren (.dnxt(axi_arlen_dnxt), .qout(axi_arlen_qout), .en(axi_arlen_en), .CLK(CLK), .RSTn(RSTn));


	assign axi_rlast_set = ((axi_arlen_cnt_qout == axi_arlen_qout) & ~axi_rlast_qout & axi_arv_arr_flag_qout )  ;
	assign axi_rlast_rst = (~axi_arready_qout & L2C_AXI_ARVALID & ~axi_arv_arr_flag_qout) | (((axi_arlen_cnt_qout <= axi_arlen_qout) | axi_rlast_qout | ~axi_arv_arr_flag_qout ) & (L2C_AXI_RREADY));
	gen_rsffr axi_rlast_rsffr (.set_in(axi_rlast_set), .rst_in(axi_rlast_rst), .qout(axi_rlast_qout), .CLK(CLK), .RSTn(RSTn));



	assign axi_arlen_cnt_dnxta = 8'd0;
	assign axi_arlen_cnt_dnxtb = axi_arlen_cnt_qout + 8'd1;
	assign axi_arlen_cnt_ena = (~axi_arready_qout & L2C_AXI_ARVALID & ~axi_arv_arr_flag_qout);
	assign axi_arlen_cnt_enb = ((axi_arlen_cnt_qout <= axi_arlen_qout) & axi_rvalid_qout & L2C_AXI_RREADY);
	gen_dpdffren # (.DW(8)) axi_arlen_cnt_dpdffren( .dnxta(axi_arlen_cnt_dnxta), .ena(axi_arlen_cnt_ena), .dnxtb(axi_arlen_cnt_dnxtb), .enb(axi_arlen_cnt_enb), .qout(axi_arlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );



	assign axi_rvalid_set = ~axi_rvalid_qout & axi_arv_arr_flag_qout;
	assign axi_rvalid_rst =  axi_rvalid_qout & L2C_AXI_RREADY;
	gen_rsffr axi_rvalid_rsffr (.set_in(axi_rvalid_set), .rst_in(axi_rvalid_rst), .qout(axi_rvalid_qout), .CLK(CLK), .RSTn(RSTn));





















// MMMMMMMM               MMMMMMMMEEEEEEEEEEEEEEEEEEEEEEMMMMMMMM               MMMMMMMM                        PPPPPPPPPPPPPPPPP        OOOOOOOOO     RRRRRRRRRRRRRRRRR   TTTTTTTTTTTTTTTTTTTTTTT
// M:::::::M             M:::::::ME::::::::::::::::::::EM:::::::M             M:::::::M                        P::::::::::::::::P     OO:::::::::OO   R::::::::::::::::R  T:::::::::::::::::::::T
// M::::::::M           M::::::::ME::::::::::::::::::::EM::::::::M           M::::::::M                        P::::::PPPPPP:::::P  OO:::::::::::::OO R::::::RRRRRR:::::R T:::::::::::::::::::::T
// M:::::::::M         M:::::::::MEE::::::EEEEEEEEE::::EM:::::::::M         M:::::::::M                        PP:::::P     P:::::PO:::::::OOO:::::::ORR:::::R     R:::::RT:::::TT:::::::TT:::::T
// M::::::::::M       M::::::::::M  E:::::E       EEEEEEM::::::::::M       M::::::::::M                          P::::P     P:::::PO::::::O   O::::::O  R::::R     R:::::RTTTTTT  T:::::T  TTTTTT
// M:::::::::::M     M:::::::::::M  E:::::E             M:::::::::::M     M:::::::::::M                          P::::P     P:::::PO:::::O     O:::::O  R::::R     R:::::R        T:::::T        
// M:::::::M::::M   M::::M:::::::M  E::::::EEEEEEEEEE   M:::::::M::::M   M::::M:::::::M                          P::::PPPPPP:::::P O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
// M::::::M M::::M M::::M M::::::M  E:::::::::::::::E   M::::::M M::::M M::::M M::::::M                          P:::::::::::::PP  O:::::O     O:::::O  R:::::::::::::RR          T:::::T        
// M::::::M  M::::M::::M  M::::::M  E:::::::::::::::E   M::::::M  M::::M::::M  M::::::M                          P::::PPPPPPPPP    O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
// M::::::M   M:::::::M   M::::::M  E::::::EEEEEEEEEE   M::::::M   M:::::::M   M::::::M                          P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
// M::::::M    M:::::M    M::::::M  E:::::E             M::::::M    M:::::M    M::::::M                          P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
// M::::::M     MMMMM     M::::::M  E:::::E       EEEEEEM::::::M     MMMMM     M::::::M                          P::::P            O::::::O   O::::::O  R::::R     R:::::R        T:::::T        
// M::::::M               M::::::MEE::::::EEEEEEEE:::::EM::::::M               M::::::M                        PP::::::PP          O:::::::OOO:::::::ORR:::::R     R:::::R      TT:::::::TT      
// M::::::M               M::::::ME::::::::::::::::::::EM::::::M               M::::::M                        P::::::::P           OO:::::::::::::OO R::::::R     R:::::R      T:::::::::T      
// M::::::M               M::::::ME::::::::::::::::::::EM::::::M               M::::::M                        P::::::::P             OO:::::::::OO   R::::::R     R:::::R      T:::::::::T      
// MMMMMMMM               MMMMMMMMEEEEEEEEEEEEEEEEEEEEEEMMMMMMMM               MMMMMMMM                        PPPPPPPPPP               OOOOOOOOO     RRRRRRRR     RRRRRRR      TTTTTTTTTTT      
//                                                                                     ________________________                                                                                  
//                                                                                     _::::::::::::::::::::::_                                                                                  
//                                                                                     ________________________  














	wire axi_awvalid_set, axi_awvalid_rst, axi_awvalid_qout;
	wire axi_wvalid_set, axi_wvalid_rst, axi_wvalid_qout;
	wire axi_wlast_set, axi_wlast_rst, axi_wlast_qout;
	wire [7:0] write_index_dnxt;
	wire [7:0] write_index_qout;
	wire axi_bready_set, axi_bready_rst, axi_bready_qout;
	wire axi_arvalid_set, axi_arvalid_rst, axi_arvalid_qout;
	wire [7:0] read_index_dnxt;
	wire [7:0] read_index_qout;
	wire axi_rready_set, axi_rready_rst, axi_rready_qout;
	wire wnext, rnext;
	wire write_resp_error, read_resp_error;
	wire start_single_burst_read, start_single_burst_write;


	assign MEMEM_AXI_AWID = 'b0;
	assign MEMEM_AXI_AWADDR	= ;
	assign MEMEM_AXI_AWLEN = 8'd63;
	assign MEMEM_AXI_AWSIZE	= $clog2(MEM_DW/8);
	assign MEMEM_AXI_AWBURST = 2'b01;
	assign MEMEM_AXI_AWLOCK	= 1'b0;
	assign MEMEM_AXI_AWCACHE = 4'b0000;
	assign MEM_AXI_AWPROT	= 3'h0;
	assign MEM_AXI_AWQOS = 4'h0;
	assign MEM_AXI_AWUSER	= 'b1;
	assign MEM_AXI_AWVALID = axi_awvalid_qout;

	assign MEM_AXI_WDATA = ;
	assign MEM_AXI_WSTRB = {(MEM_DW/8){1'b1}};
	assign MEM_AXI_WLAST = axi_wlast_qout;
	assign MEM_AXI_WUSER = 'b0;
	assign MEM_AXI_WVALID = axi_wvalid_qout;

	assign MEM_AXI_BREADY = axi_bready_qout;


	assign MEM_AXI_ARID = 'b0;
	assign MEM_AXI_ARADDR = ;
	
	assign MEM_AXI_ARLEN = 8'd63;
	assign MEM_AXI_ARSIZE = $clog2(MEM_DW/8);
	assign MEM_AXI_ARBURST = 2'b01;
	assign MEM_AXI_ARLOCK = 1'b0;
	
	assign MEM_AXI_ARCACHE = 4'b0000;
	assign MEM_AXI_ARPROT = 3'h0;
	assign MEM_AXI_ARQOS = 4'h0;
	assign MEM_AXI_ARUSER = 'b1;
	assign MEM_AXI_ARVALID = axi_arvalid_qout;
	
	assign MEM_AXI_RREADY = axi_rready_qout;



	assign axi_awvalid_set = ~axi_awvalid_qout & start_single_burst_write;
	assign axi_awvalid_rst =  axi_awvalid_qout & MEM_AXI_AWREADY ;
	gen_rsffr axi_awvalid_rsffr (.set_in(axi_awvalid_set), .rst_in(axi_awvalid_rst), .qout(axi_awvalid_qout), .CLK(CLK), .RSTn(RSTn));



	assign wnext = MEM_AXI_WREADY & axi_wvalid_qout;


	assign axi_wvalid_set = (~axi_wvalid_qout & start_single_burst_write);
	assign axi_wvalid_rst = (wnext & axi_wlast_qout) ;
	gen_rsffr axi_wvalid_rsffr (.set_in(axi_wvalid_set), .rst_in(axi_wvalid_rst), .qout(axi_wvalid_qout), .CLK(CLK), .RSTn(RSTn));




	assign axi_wlast_set = ((write_index_qout == C_MEM_AXI_BURST_LEN-2 && C_MEM_AXI_BURST_LEN >= 2) && wnext) || (C_MEM_AXI_BURST_LEN == 1 );
	assign axi_wlast_rst = ~axi_wlast_set & ( wnext | (axi_wlast_qout && C_MEM_AXI_BURST_LEN == 1) );
	gen_rsffr axi_wlast_rsffr (.set_in(axi_wlast_set), .rst_in(axi_wlast_rst), .qout(axi_wlast_qout), .CLK(CLK), .RSTn(RSTn));


	assign write_index_dnxt = start_single_burst_write ? 8'd0 :
								(
									(wnext && (write_index_qout != C_MEM_AXI_BURST_LEN-1)) ? (write_index_qout + 8'd1) : write_index_qout
								);							
	gen_dffr # (.DW(8)) write_index_dffr (.dnxt(write_index_dnxt), .qout(write_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign axi_bready_set = (MEM_AXI_BVALID && ~axi_bready_qout);
	assign axi_bready_rst = axi_bready_qout;
	gen_rsffr axi_bready_rsffr (.set_in(axi_bready_set), .rst_in(axi_bready_rst), .qout(axi_bready_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign write_resp_error = axi_bready_qout & MEM_AXI_BVALID & MEM_AXI_BRESP[1]; 




	assign axi_arvalid_set = ~axi_arvalid_qout & start_single_burst_read;
	assign axi_arvalid_rst = axi_arvalid_qout & MEM_AXI_ARREADY ;
	gen_rsffr axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign rnext = MEM_AXI_RVALID && axi_rready_qout;



	assign read_index_dnxt = start_single_burst_read ? 8'd0 :
								(
									(rnext & (read_index != C_MEM_AXI_BURST_LEN-1)) ? (read_index_qout + 8'd1) : read_index_qout
								);							
	gen_dffr # (.DW(8)) read_index_dffr (.dnxt(read_index_dnxt), .qout(read_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign axi_rready_set = MEM_AXI_RVALID & (~MEM_AXI_RLAST | ~axi_rready_qout);
	assign axi_rready_rst = MEM_AXI_RVALID &   MEM_AXI_RLAST &  axi_rready_qout;
	gen_rsffr axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));


	assign read_resp_error = axi_rready_qout & MEM_AXI_RVALID & MEM_AXI_RRESP[1];























endmodule












