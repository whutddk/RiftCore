/*
* @File name: L3cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-19 10:11:07
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-22 12:10:14
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
					input [L2C_ID_W-1:0] L2C_AWID,
					input [L2C_AW-1:0] L2C_AWADDR,
					input [7:0] L2C_AWLEN,
					input [2:0] L2C_AWSIZE,
					input [1:0] L2C_AWBURST,
					input [2:0] L2C_AWPROT,
					input L2C_AWVALID,
					output L2C_AWREADY,

					input [L2C_DW-1:0] L2C_WDATA,
					input [(L2C_DW/8)-1:0] L2C_WSTRB,
					input L2C_WLAST,
					input L2C_WVALID,
					output L2C_WREADY,

					output [L2C_ID_W-1:0] L2C_BID,
					output [1:0] L2C_BRESP,
					output L2C_BVALID,
					input L2C_BREADY,

	input [L2C_ID_W-1:0] L2C_ARID,
	input [L2C_AW-1:0] L2C_ARADDR,
	input [7:0] L2C_ARLEN,
	input [2:0] L2C_ARSIZE,
	input [1:0] L2C_ARBURST,
	input [2:0] L2C_ARPROT,
	input L2C_ARVALID,
	output L2C_ARREADY,

	output [L2C_ID_W-1:0] L2C_RID,
	output [L2C_DW-1:0] L2C_RDATA,
	output [1:0] L2C_RRESP,
	output L2C_RLAST,
	output L2C_RVALID,
	input L2C_RREADY,


	//from DDR
	output [MEM_ID_W-1:0] MEM_AWID,
	output [MEM_AW-1:0] MEM_AWADDR,
	output [7:0] MEM_AWLEN,
	output [2:0] MEM_AWSIZE,
	output [1:0] MEM_AWBURST,
	output MEM_AWLOCK,
	output [3:0] MEM_AWCACHE,
	output [2:0] MEM_AWPROT,
	output [3:0] MEM_AWQOS,
	output [MEM_USER_W-1:0] MEM_AWUSER,
	output MEM_AWVALID,
	input MEM_AWREADY,

	output [MEM_DW-1:0] MEM_WDATA,
	output [MEM_DW/8-1:0] MEM_WSTRB,
	output MEM_WLAST,
	output [MEM_USER_W-1:0] MEM_WUSER,
	output MEM_WVALID,
	input MEM_WREADY,

	input [MEM_ID_W-1:0] MEM_BID,
	input [1:0] MEM_BRESP,
	input [MEM_USER_W-1:0] MEM_BUSER,
	input MEM_BVALID,
	output MEM_BREADY,

	output [MEM_ID_W-1:0] MEM_ARID,
	output [MEM_AW-1:0] MEM_ARADDR,
	output [7:0] MEM_ARLEN,
	output [2:0] MEM_ARSIZE,
	output [1:0] MEM_ARBURST,
	output MEM_ARLOCK,
	output [3:0] MEM_ARCACHE,
	output [2:0] MEM_ARPROT,
	output [3:0] MEM_ARQOS,
	output [MEM_USER_W-1:0] MEM_ARUSER,
	output MEM_ARVALID,
	input MEM_ARREADY,

	input [MEM_ID_W-1:0] MEM_RID,
	input [MEM_DW-1:0] MEM_RDATA,
	input [1:0] MEM_RRESP,
	input MEM_RLAST,
	input [MEM_USER_W-1:0] MEM_RUSER,
	input MEM_RVALID,
	output MEM_RREADY,


	input CLK,
	input RSTn

);





















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

	wire l2c_awready_set, l2c_awready_rst, l2c_awready_qout;
	wire l2c_awv_awr_flag_set, l2c_awv_awr_flag_rst, l2c_awv_awr_flag_qout;
	wire [L2C_AW-1:0] l2c_awaddr_dnxta;
	wire [L2C_AW-1:0] l2c_awaddr_dnxtb;
	wire [L2C_AW-1:0] l2c_awaddr_qout;
	wire l2c_awaddr_ena, l2c_awaddr_enb;
	wire l2c_awburst_en;
	wire [1:0] l2c_awburst_dnxt;
	wire [1:0] l2c_awburst_qout;
	wire l2c_awlen_en;
	wire [7:0] l2c_awlen_dnxt;
	wire [7:0] l2c_awlen_qout;
	wire [7:0] l2c_awlen_cnt_dnxta;
	wire [7:0] l2c_awlen_cnt_dnxtb;
	wire [7:0] l2c_awlen_cnt_qout;
	wire l2c_awlen_cnt_ena, l2c_awlen_cnt_enb;
	wire l2c_wready_set, l2c_wready_rst, l2c_wready_qout;
	wire l2c_bvalid_set, l2c_bvalid_rst, l2c_bvalid_qout;
	wire l2c_arready_set, l2c_arready_rst, l2c_arready_qout;
	wire l2c_arv_arr_flag_set, l2c_arv_arr_flag_rst, l2c_arv_arr_flag_qout;
	wire [L2C_AW-1:0] l2c_araddr_dnxta;
	wire [L2C_AW-1:0] l2c_araddr_dnxtb;
	wire [L2C_AW-1:0] l2c_araddr_qout;
	wire l2c_araddr_ena, l2c_araddr_enb, l2c_arburst_en;
	wire [1:0] l2c_arburst_dnxt;
	wire [1:0] l2c_arburst_qout;
	wire l2c_arlen_en;
	wire [7:0] l2c_arlen_dnxt;
	wire [7:0] l2c_arlen_qout;
	wire [7:0] l2c_arlen_cnt_dnxta;
	wire [7:0] l2c_arlen_cnt_dnxtb;
	wire [7:0] l2c_arlen_cnt_qout;
	wire l2c_arlen_cnt_ena, l2c_arlen_cnt_enb;
	wire l2c_rvalid_set, l2c_rvalid_rst, l2c_rvalid_qout;
	wire l2c_rlast_set, l2c_rlast_rst, l2c_rlast_qout;


	assign L2C_AWREADY = l2c_awready_qout;
	assign L2C_WREADY	= l2c_wready_qout;
	assign L2C_BRESP = 2'b00;
	assign L2C_BUSER = 'b0;
	assign L2C_BVALID	= l2c_bvalid_qout;
	assign L2C_ARREADY = l2c_arready_qout;
	assign L2C_RRESP = 2'b00;
	assign L2C_RLAST = l2c_rlast_qout;
	assign L2C_RUSER = 'd0;
	assign L2C_RVALID	= l2c_rvalid_qout;
	assign L2C_BID = L2C_AWID;
	assign L2C_RID = L2C_ARID;
	assign aw_wrap_size = (L2C_DW/8 * (l2c_awlen_qout)); 
	assign ar_wrap_size = (L2C_DW/8 * (l2c_arlen_qout)); 
	assign aw_wrap_en = ((l2c_awaddr_qout & aw_wrap_size) == aw_wrap_size) ? 1'b1 : 1'b0;
	assign ar_wrap_en = ((l2c_araddr_qout & ar_wrap_size) == ar_wrap_size) ? 1'b1 : 1'b0;



	wire l3c_aw_rsp;
	wire l3c_ar_rsp;

	assign l2c_awready_set =  l3c_aw_rsp;
	assign l2c_awready_rst = ~l3c_aw_rsp & ~(L2C_WLAST & l2c_wready_qout);
	gen_rsffr l2c_awready_rsffr (.set_in(l2c_awready_set), .rst_in(l2c_awready_rst), .qout(l2c_awready_qout), .CLK(CLK), .RSTn(RSTn));

	assign l2c_awv_awr_flag_set =  l3c_aw_rsp;
	assign l2c_awv_awr_flag_rst = ~l3c_aw_rsp & (L2C_WLAST & l2c_wready_qout);
	gen_rsffr l2c_awv_awr_flag_rsffr (.set_in(l2c_awv_awr_flag_set), .rst_in(l2c_awv_awr_flag_rst), .qout(l2c_awv_awr_flag_qout), .CLK(CLK), .RSTn(RSTn));

	assign l2c_awaddr_dnxta = L2C_AWADDR;
	assign l2c_awaddr_dnxtb = ( {L2C_AW{l2c_awburst == 2'b00}} & l2c_awaddr_qout )
							| 
							( {L2C_AW{l2c_awburst == 2'b01}} & l2c_awaddr_qout + (1<<ADDR_LSB) )
							|
							( {L2C_AW{l2c_awburst == 2'b10}} & 
								(
									{L2C_AW{ aw_wrap_en}} & (l2c_awaddr_qout - aw_wrap_size)
									|
									{L2C_AW{~aw_wrap_en}} & (l2c_awaddr_qout + (1<<ADDR_LSB) )
								)
							);
	assign l2c_awaddr_ena = l3c_aw_rsp;
	assign l2c_awaddr_enb = (l2c_awlen_cnt_qout <= l2c_awlen_qout) & l2c_wready_qout & L2C_WVALID;
	gen_dpdffren # (.DW(L2C_AW)) l2c_awaddr_dpdffren( .dnxta(l2c_awaddr_dnxta), .ena(l2c_awaddr_ena), .dnxtb(l2c_awaddr_dnxtb), .enb(l2c_awaddr_enb), .qout(l2c_awaddr_qout), .CLK(CLK), .RSTn(RSTn) );

	assign l2c_awburst_en = l3c_aw_rsp;
	assign l2c_awburst_dnxt = L2C_AWBURST;
	gen_dffren # (.DW(2)) l2c_awburst_dffren (.dnxt(l2c_awburst_dnxt), .qout(l2c_awburst_qout), .en(l2c_awburst_en), .CLK(CLK), .RSTn(RSTn));




	assign l2c_awlen_en = l3c_aw_rsp;
	assign l2c_awlen_dnxt = L2C_AWLEN;
	gen_dffren # (.DW(8)) l2c_awlen_dffren (.dnxt(l2c_awlen_dnxt), .qout(l2c_awlen_qout), .en(l2c_awlen_en), .CLK(CLK), .RSTn(RSTn));


	assign l2c_awlen_cnt_dnxta = 8'd0;
	assign l2c_awlen_cnt_dnxtb = l2c_awlen_cnt_qout + 8'd1;
	assign l2c_awlen_cnt_ena = l3c_aw_rsp;
	assign l2c_awlen_cnt_enb = (l2c_awlen_cnt_qout <= l2c_awlen_qout) & l2c_wready_qout & L2C_WVALID;
	gen_dpdffren # (.DW(8)) l2c_awlen_cnt_dpdffren( .dnxta(l2c_awlen_cnt_dnxta), .ena(l2c_awlen_cnt_ena), .dnxtb(l2c_awlen_cnt_dnxtb), .enb(l2c_awlen_cnt_enb), .qout(l2c_awlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );


	assign l2c_wready_set = ~l2c_wready_qout & L2C_WVALID & l2c_awv_awr_flag_qout;
	assign l2c_wready_rst =  l2c_wready_qout & L2C_WLAST;
	gen_rsffr l2c_wready_rsffr (.set_in(l2c_wready_set), .rst_in(l2c_wready_rst), .qout(l2c_wready_qout), .CLK(CLK), .RSTn(RSTn));



	assign l2c_bvalid_set = ~l2c_bvalid_qout & l2c_awv_awr_flag_qout & l2c_wready_qout & L2C_WVALID & L2C_WLAST;
	assign l2c_bvalid_rst =  l2c_bvalid_qout & L2C_BREADY;
	gen_rsffr l2c_bvalid_rsffr (.set_in(l2c_bvalid_set), .rst_in(l2c_bvalid_rst), .qout(l2c_bvalid_qout), .CLK(CLK), .RSTn(RSTn));





	
	assign l2c_arready_set =  l3c_ar_rsp;
	assign l2c_arready_rst = ~l3c_ar_rsp & ~(l2c_rvalid_qout & L2C_RREADY & l2c_arlen_cnt_qout == l2c_arlen_qout);
	gen_rsffr l2c_arready_rsffr (.set_in(l2c_arready_set), .rst_in(l2c_arready_rst), .qout(l2c_arready_qout), .CLK(CLK), .RSTn(RSTn));

	assign l2c_arv_arr_flag_set =  l3c_ar_rsp;
	assign l2c_arv_arr_flag_rst = ~l3c_ar_rsp & (l2c_rvalid_qout & L2C_RREADY & l2c_arlen_cnt_qout == l2c_arlen_qout);
	gen_rsffr l2c_arv_arr_flag_rsffr (.set_in(l2c_arv_arr_flag_set), .rst_in(l2c_arv_arr_flag_rst), .qout(l2c_arv_arr_flag_qout), .CLK(CLK), .RSTn(RSTn));



	assign l2c_araddr_dnxta = L2C_ARADDR;
	assign l2c_araddr_dnxtb = ({L2C_AW{l2c_arburst_qout == 2'b00}} & l2c_araddr_qout)
							|
							({L2C_AW{l2c_arburst_qout == 2'b01}} & l2c_araddr_qout + (1<<ADDR_LSB))
							|
							({L2C_AW{l2c_arburst_qout == 2'b10}} & 
								(
									({L2C_AW{ ar_wrap_en}} & (l2c_araddr_qout - ar_wrap_size) )
									|
									({L2C_AW{~ar_wrap_en}} & (l2c_araddr_qout + (1<<ADDR_LSB)))
								)
							);
	assign l2c_araddr_ena = l3c_ar_rsp;
	assign l2c_araddr_enb = ((l2c_arlen_cnt_qout <= l2c_arlen_qout) & l2c_rvalid_qout & L2C_RREADY);
	gen_dpdffren # (.DW(L2C_AW)) l2c_araddr_dpdffren( .dnxta(l2c_araddr_dnxta), .ena(l2c_araddr_ena), .dnxtb(l2c_araddr_dnxtb), .enb(l2c_araddr_enb), .qout(l2c_araddr_qout), .CLK(CLK), .RSTn(RSTn) );

	
	assign l2c_arburst_en = l3c_ar_rsp;
	assign l2c_arburst_dnxt = L2C_ARBURST;
	gen_dffren # (.DW(2)) l2c_arburst_dffren (.dnxt(l2c_arburst_dnxt), .qout(l2c_arburst_qout), .en(l2c_arburst_en), .CLK(CLK), .RSTn(RSTn));


	assign l2c_arlen_en = l3c_ar_rsp;
	assign l2c_arlen_dnxt = L2C_ARLEN;
	gen_dffren # (.DW(8)) l2c_arlen_dffren (.dnxt(l2c_arlen_dnxt), .qout(l2c_arlen_qout), .en(l2c_arlen_en), .CLK(CLK), .RSTn(RSTn));


	assign l2c_rlast_set = ((l2c_arlen_cnt_qout == l2c_arlen_qout) & ~l2c_rlast_qout & l2c_arv_arr_flag_qout )  ;
	assign l2c_rlast_rst = l3c_ar_rsp | (((l2c_arlen_cnt_qout <= l2c_arlen_qout) | l2c_rlast_qout | ~l2c_arv_arr_flag_qout ) & (L2C_RREADY));
	gen_rsffr l2c_rlast_rsffr (.set_in(l2c_rlast_set), .rst_in(l2c_rlast_rst), .qout(l2c_rlast_qout), .CLK(CLK), .RSTn(RSTn));



	assign l2c_arlen_cnt_dnxta = 8'd0;
	assign l2c_arlen_cnt_dnxtb = l2c_arlen_cnt_qout + 8'd1;
	assign l2c_arlen_cnt_ena = l3c_ar_rsp;
	assign l2c_arlen_cnt_enb = ((l2c_arlen_cnt_qout <= l2c_arlen_qout) & l2c_rvalid_qout & L2C_RREADY);
	gen_dpdffren # (.DW(8)) l2c_arlen_cnt_dpdffren( .dnxta(l2c_arlen_cnt_dnxta), .ena(l2c_arlen_cnt_ena), .dnxtb(l2c_arlen_cnt_dnxtb), .enb(l2c_arlen_cnt_enb), .qout(l2c_arlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );



	assign l2c_rvalid_set = ~l2c_rvalid_qout & l2c_arv_arr_flag_qout;
	assign l2c_rvalid_rst =  l2c_rvalid_qout & L2C_RREADY;
	gen_rsffr l2c_rvalid_rsffr (.set_in(l2c_rvalid_set), .rst_in(l2c_rvalid_rst), .qout(l2c_rvalid_qout), .CLK(CLK), .RSTn(RSTn));





















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













	wire mem_awvalid_set, mem_awvalid_rst, mem_awvalid_qout;
	wire mem_wvalid_set, mem_wvalid_rst, mem_wvalid_qout;
	wire mem_wlast_set, mem_wlast_rst, mem_wlast_qout;
	wire [7:0] write_index_dnxt;
	wire [7:0] write_index_qout;
	wire mem_bready_set, mem_bready_rst, mem_bready_qout;
	wire mem_arvalid_set, mem_arvalid_rst, mem_arvalid_qout;
	wire [7:0] read_index_dnxt;
	wire [7:0] read_index_qout;
	wire mem_rready_set, mem_rready_rst, mem_rready_qout;
	wire wnext, rnext;
	wire write_resp_error, read_resp_error;
	wire mem_aw_req, mem_ar_req;


	assign MEM_AWID = 'b0;

	assign MEM_AWLEN = 8'd63;
	assign MEM_AWSIZE	= $clog2(MEM_DW/8);
	assign MEM_AWBURST = 2'b01;
	assign MEM_AWLOCK	= 1'b0;
	assign MEM_AWCACHE = 4'b0000;
	assign MEM_AWPROT	= 3'h0;
	assign MEM_AWQOS = 4'h0;
	assign MEM_AWUSER	= 'b1;
	assign MEM_AWVALID = mem_awvalid_qout;


	assign MEM_WSTRB = {(MEM_DW/8){1'b1}};
	assign MEM_WLAST = mem_wlast_qout;
	assign MEM_WUSER = 'b0;
	assign MEM_WVALID = mem_wvalid_qout;

	assign MEM_BREADY = mem_bready_qout;


	assign MEM_ARID = 'b0;

	
	assign MEM_ARLEN = 8'd63;
	assign MEM_ARSIZE = $clog2(MEM_DW/8);
	assign MEM_ARBURST = 2'b01;
	assign MEM_ARLOCK = 1'b0;
	
	assign MEM_ARCACHE = 4'b0000;
	assign MEM_ARPROT = 3'h0;
	assign MEM_ARQOS = 4'h0;
	assign MEM_ARUSER = 'b1;
	assign MEM_ARVALID = mem_arvalid_qout;
	
	assign MEM_RREADY = mem_rready_qout;



	assign mem_awvalid_set = ~mem_awvalid_qout & mem_aw_req;
	assign mem_awvalid_rst =  mem_awvalid_qout & MEM_AWREADY ;
	gen_rsffr mem_awvalid_rsffr (.set_in(mem_awvalid_set), .rst_in(mem_awvalid_rst), .qout(mem_awvalid_qout), .CLK(CLK), .RSTn(RSTn));



	assign wnext = MEM_WREADY & mem_wvalid_qout;


	assign mem_wvalid_set = (~mem_wvalid_qout & mem_aw_req);
	assign mem_wvalid_rst = (wnext & mem_wlast_qout) ;
	gen_rsffr mem_wvalid_rsffr (.set_in(mem_wvalid_set), .rst_in(mem_wvalid_rst), .qout(mem_wvalid_qout), .CLK(CLK), .RSTn(RSTn));




	assign mem_wlast_set = ((write_index_qout == C_MEM_BURST_LEN-2 && C_MEM_BURST_LEN >= 2) && wnext) || (C_MEM_BURST_LEN == 1 );
	assign mem_wlast_rst = ~mem_wlast_set & ( wnext | (mem_wlast_qout && C_MEM_BURST_LEN == 1) );
	gen_rsffr mem_wlast_rsffr (.set_in(mem_wlast_set), .rst_in(mem_wlast_rst), .qout(mem_wlast_qout), .CLK(CLK), .RSTn(RSTn));


	assign write_index_dnxt = mem_aw_req ? 8'd0 :
								(
									(wnext && (write_index_qout != C_MEM_BURST_LEN-1)) ? (write_index_qout + 8'd1) : write_index_qout
								);							
	gen_dffr # (.DW(8)) write_index_dffr (.dnxt(write_index_dnxt), .qout(write_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign mem_bready_set = (MEM_BVALID && ~mem_bready_qout);
	assign mem_bready_rst = mem_bready_qout;
	gen_rsffr mem_bready_rsffr (.set_in(mem_bready_set), .rst_in(mem_bready_rst), .qout(mem_bready_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign write_resp_error = mem_bready_qout & MEM_BVALID & MEM_BRESP[1]; 




	assign mem_arvalid_set = ~mem_arvalid_qout & mem_ar_req;
	assign mem_arvalid_rst = mem_arvalid_qout & MEM_ARREADY ;
	gen_rsffr mem_arvalid_rsffr (.set_in(mem_arvalid_set), .rst_in(mem_arvalid_rst), .qout(mem_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign rnext = MEM_RVALID && mem_rready_qout;



	assign read_index_dnxt = mem_ar_req ? 8'd0 :
								(
									(rnext & (read_index != C_MEM_BURST_LEN-1)) ? (read_index_qout + 8'd1) : read_index_qout
								);							
	gen_dffr # (.DW(8)) read_index_dffr (.dnxt(read_index_dnxt), .qout(read_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign mem_rready_set = MEM_RVALID & (~MEM_RLAST | ~mem_rready_qout);
	assign mem_rready_rst = MEM_RVALID &   MEM_RLAST &  mem_rready_qout;
	gen_rsffr mem_rready_rsffr (.set_in(mem_rready_set), .rst_in(mem_rready_rst), .qout(mem_rready_qout), .CLK(CLK), .RSTn(RSTn));


	assign read_resp_error = mem_rready_qout & MEM_RVALID & MEM_RRESP[1];





















// BBBBBBBBBBBBBBBBB   RRRRRRRRRRRRRRRRR                  AAA               MMMMMMMM               MMMMMMMM
// B::::::::::::::::B  R::::::::::::::::R                A:::A              M:::::::M             M:::::::M
// B::::::BBBBBB:::::B R::::::RRRRRR:::::R              A:::::A             M::::::::M           M::::::::M
// BB:::::B     B:::::BRR:::::R     R:::::R            A:::::::A            M:::::::::M         M:::::::::M
//   B::::B     B:::::B  R::::R     R:::::R           A:::::::::A           M::::::::::M       M::::::::::M
//   B::::B     B:::::B  R::::R     R:::::R          A:::::A:::::A          M:::::::::::M     M:::::::::::M
//   B::::BBBBBB:::::B   R::::RRRRRR:::::R          A:::::A A:::::A         M:::::::M::::M   M::::M:::::::M
//   B:::::::::::::BB    R:::::::::::::RR          A:::::A   A:::::A        M::::::M M::::M M::::M M::::::M
//   B::::BBBBBB:::::B   R::::RRRRRR:::::R        A:::::A     A:::::A       M::::::M  M::::M::::M  M::::::M
//   B::::B     B:::::B  R::::R     R:::::R      A:::::AAAAAAAAA:::::A      M::::::M   M:::::::M   M::::::M
//   B::::B     B:::::B  R::::R     R:::::R     A:::::::::::::::::::::A     M::::::M    M:::::M    M::::::M
//   B::::B     B:::::B  R::::R     R:::::R    A:::::AAAAAAAAAAAAA:::::A    M::::::M     MMMMM     M::::::M
// BB:::::BBBBBB::::::BRR:::::R     R:::::R   A:::::A             A:::::A   M::::::M               M::::::M
// B:::::::::::::::::B R::::::R     R:::::R  A:::::A               A:::::A  M::::::M               M::::::M
// B::::::::::::::::B  R::::::R     R:::::R A:::::A                 A:::::A M::::::M               M::::::M
// BBBBBBBBBBBBBBBBB   RRRRRRRR     RRRRRRRAAAAAAA                   AAAAAAAMMMMMMMM               MMMMMMMM














	localparam ADDR_LSB = $clog2(DATA_WIDTH/8)
	localparam LINE_W = $clog2(CACHE_LINE);
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;
	localparam BANK = 4;
	localparam BANK_WIDTH = DATA_WIDTH / BANK;
	localparam LINE_N = 2**LINE_W;


wire [31:0] addr_req;


wire [$clog2(BANK)-1:0] bank_sel = addr_req[ ADDR_LSB-1 -:  $clog2(BANK)];
wire [LINE_W-1:0] address_sel = addr_req[ADDR_LSB +: LINE_W];
wire [TAG_W-1:0] tag_sel = addr_req[31 -: TAG_W];




wire [LINE_N-1:0] tag_valid_dnxt;
wire [LINE_N-1:0] tag_valid_qout;
wire [LINE_N-1:0] tag_valid_en;

wire [ TAG_W - 1 : 0] tag_info_w;
wire [ TAG_W - 1 : 0] tag_info_r;
wire isTagHit;
wire [ DATA_WIDTH - 1 : 0] data_hit;

wire [(TAG_W+7) / 8 -1 : 0] tag_data_wstrb;
wire [DATA_WIDTH/8-1] bank_data_wstrb;

wire [ BANK - 1 : 0 ] bank_en_w;
wire [ BANK - 1 : 0 ] bank_en_r;
wire tag_en_w;
wire tag_en_r;

wire [ DATA_WIDTH - 1 : 0 ] bank_data_w;
wire [ DATA_WIDTH - 1 : 0 ] bank_data_r;
wire [ TAG_W - 1 : 0 ] tag_data_w;
wire [ TAG_W - 1 : 0 ] tag_data_r;

wire [LINE_W-1:0] tag_addr_r;
wire [LINE_W-1:0] tag_addr_w;
wire [LINE_W-1:0] bank_addr_r;
wire [LINE_W-1:0] bank_addr_w;

generate
	
	for ( genvar i = 0; i < LINE_N; i = i + 1 )begin
		gen_dffren #(.DW(1)) tag_valid_dffren (.dnxt(tag_valid_dnxt), .qout(tag_valid_qout), .en(tag_valid_en), .CLK(CLK), .RSTn(RSTn));


	end


	gen_sram # ( .DW((TAG_W)), .AW(LINE_W)) tag_ram
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

endgenerate


assign tag_data_w = {tag_valid_w, tag_info_w};
assign tag_data_wstrb = {(TAG_W+1){1'b1}};
assign {tag_valid_r, tag_info_r} = tag_data_r;





wire isL2cReq;
wire isL2cRead;
wire isl2cWrite;

wire isCacheMiss;
wire isCacheHit;

wire isL3Cbusy_set, isL3Cbusy_rst, isL3Cbusy_qout;
wire [0:0] req_chn_dnxt, req_chn_qout, req_chn_en;

assign req_chn_en = ~(l2c_arv_arr_flag_qout | l2c_awv_awr_flag_qout);
assign req_chn_dnxt = (isL2cRead & 1'b0) | (isl2cWrite & 1'b1);
// assign isL3Cbusy_set = isCacheHit;
// assign isL3Cbusy_rst = l2c_bvalid_set | l2c_rlast_set;

assign l3c_aw_rsp = ~l2c_awready_qout & L2C_AWVALID & ~l2c_awv_awr_flag_qout & ~l2c_arv_arr_flag_qout & isCacheHit & (req_chn_qout == 1'b1);
assign l3c_ar_rsp = ~l2c_arready_qout & L2C_ARVALID & ~l2c_awv_awr_flag_qout & ~l2c_arv_arr_flag_qout & isCacheHit & (req_chn_qout == 1'b0);


// gen_rsffr isL3Cbusy_rsffr (.set_in(isL3Cbusy_set), .rst_in(isL3Cbusy_rst), .qout(isL3Cbusy_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffren #(.DW(1)) req_chn_dffren (.dnxt(req_chn_dnxt), .qout(req_chn_qout), .en(req_chn_en), .CLK(CLK), .RSTn(RSTn));

assign isL2cReq = isL2cRead | isl2cWrite;
assign isL2cRead = L2C_ARVALID & ~l2c_arv_arr_flag_qout & ~l2c_awv_awr_flag_qout;
assign isl2cWrite = L2C_AWVALID & ~L2C_ARVALID & ~l2c_arv_arr_flag_qout & ~l2c_awv_awr_flag_qout;




wire [31:0] tag_addr_req_dnxt;
wire [31:0] tag_addr_req_qout;
wire tag_addr_req_en;
wire [31:0] bank_addr_req_dnxt;
wire [31:0] bank_addr_req_qout;

assign tag_addr_req_dnxt = ( L2C_ARVALID ? L2C_ARADDR : L2C_AWADDR) & ~(32'h1ff);
assign tag_addr_req_en = l3c_state_dnxt == L3C_TAG;



assign bank_addr_req_dnxt = 

gen_dffren #(.DW(32)) tag_addr_req_dffren  (.dnxt(tag_addr_req_dnxt),  .qout(tag_addr_req_qout), .en(tag_addr_req_en),.CLK(CLK), .RSTn(RSTn));
gen_dffr #(.DW(32)) bank_addr_req_dffr (.dnxt(bank_addr_req_dnxt), .qout(bank_addr_req_qout), .CLK(CLK), .RSTn(RSTn));


assign bank_addr_req_dnxt = 
	(
		{32{l3c_state_qout == L3C_FREE}} & bank_addr_req_qout
	)
	|
	(
		{32{l3c_state_qout == L3C_TAG}} & ( L2C_ARVALID ? L2C_ARADDR : L2C_AWADDR) & ~(32'h1ff);
	)
	|
	(
		{32{l3c_state_qout == L3C_FENCE}} & 
	)
	|
	(
		{32{l3c_state_qout == L3C_EVICT}} & bank_addr_req_qout + 32'b1000
	)
	|
	(
		{32{l3c_state_qout == L3C_REFLASH}} & bank_addr_req_qout + 32'b1000
	)
	|
	(
		{32{l3c_state_qout == L3C_RSPRD}} & bank_addr_req_qout + 32'b1000
	)
	|
	(
		{32{l3c_state_qout == L3C_RSPWR}} & bank_addr_req_qout + 32'b1000
	)
	;



assign tag_en_r = isL2cReq;

assign isCacheMiss = isL2cReq & ((~tag_valid_r) | (tag_info_r != tag_sel));
assign isCacheHit =  isL2cReq &  ( tag_valid_r & ( tag_info_r == tag_sel));






//read op
assign bank_en_r = {4{l2c_arv_arr_flag_qout}} & (1 << bank_sel);
assign data_hit_r = bank_data_r[1024*bank_sel +: 1024];
assign L2C_RDATA = data_hit_r[ 64 * l2c_arlen_cnt_qout +: 64];
assign MEM_WDATA = data_hit_r[ 64 * write_index_qout +: 64];;

//write op 
//write a single 64bits
assign bank_en_w = {4{l2c_awv_awr_flag_qout}} & (1 << bank_sel);
assign bank_data_w = {64{L2C_WDATA}};
assign bank_data_wstrb = {4{L2C_WSTRB << addr_req[6:0]}};

//miss op
//evict

// wire isEvict = isCacheMiss & tag_valid_r;

assign MEM_AWADDR = addr_req;
assign MEM_ARADDR = addr_req;

assign mem_ar_req =;
assign mem_aw_req = isCacheMiss & tag_valid_r;

// wire isEvict_set, isEvict_rst, isEvict_qout;
// wire isFlash_set, isFlash_rst, isFlash_qout;

// assign isEvict_set = mem_aw_req;
// assign isEvict_rst = mem_bready_set;
// assign isFlash_set = mem_ar_req;
// assign isFlash_rst = mem_rready_set;

// gen_rsffr isEvict_rsffr (.set_in(isEvict_set), .rst_in(isEvict_rst), .qout(isEvict_qout), .CLK(CLK), .RSTn(RSTn));
// gen_rsffr isFlash_rsffr (.set_in(isFlash_set), .rst_in(isFlash_rst), .qout(isFlash_qout), .CLK(CLK), .RSTn(RSTn));


localparam L3C_FREE = 0;
localparam L3C_TAG = 1;
localparam L3C_EVICT = 2;
localparam L3C_REFLASH = 3;
localparam L3C_RSPRD = 4;
localparam L3C_RSPWR = 5;
localparam L3C_FENCE = 6;


wire [2:0] l3c_state_dnxt;
wire [2:0] l3c_state_qout;
gen_dffr #(.DW(3)) l3c_state_dffr (.dnxt(l3c_state_dnxt), .qout(l3c_state_qout), .CLK(CLK), .RSTn(RSTn));

assign l3c_state_dnxt = 
	(
		{3{l3c_state_qout == L3C_FREE}} &
		(
			cache_fence_qout ? L3C_FENCE :
				( (L2C_AWVALID | L2C_ARVALID) ? L3C_TAG : L3C_FREE)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_FENCE}} &
		(
			(| tag_valid_qout) ? L3C_EVICT : L3C_FREE
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_TAG}} & 
		(
			({{ isCacheHit & L2C_AWVALID}} & L3C_RSPWR )
			|
			({{ isCacheHit & L2C_ARVALID}} & L3C_RSPRD )
			|
			({{ isCacheMiss &  tag_valid_r}} & L3C_EVICT)
			|
			({{ isCacheMiss & ~tag_valid_r}} & L3C_REFLASH)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_EVICT}} & 
		(
			~mem_bready_set ? L3C_EVICT : 
				( cache_fence_qout ? L3C_FENCE : L3C_TAG)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_REFLASH}} & 
		(
			mem_rready_set ? L3C_TAG : L3C_REFLASH
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_RSPRD}} & 
		(
			l2c_rvalid_set ? L3C_FREE : L3C_RSPRD
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_RSPWR}} & 
		(
			l2c_bvalid_set ? L3C_FREE : L3C_RSPWR
		)
	)































//ASSERT
always @( negedge CLK ) begin
	if ( (l3c_state_dnxt == L3C_TAG) & ~L2C_AWVALID & ~L2C_ARVALID ) begin
		$display("Assert Fail at L3cache");
		$finish;
	end
end







endmodule












