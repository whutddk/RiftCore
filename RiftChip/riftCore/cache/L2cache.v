/*
* @File name: L2cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-18 14:26:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-25 17:40:52
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



module L2cache 
(
	parameter DW = 256,
	parameter BK = 4,
	parameter CB = 4,
	parameter CL = 32
)
(

	//L1 I Cache
	input [31:0] IL1_ARADDR,
	input [7:0] IL1_ARLEN,
	input [1:0] IL1_ARBURST,
	input IL1_ARVALID,
	output IL1_ARREADY,

	output [63:0] IL1_RDATA,
	output [1:0] IL1_RRESP,
	output IL1_RLAST,
	output IL1_RVALID,
	input IL1_RREADY,

	//L1 D cache
	input [31:0] DL1_AWADDR,
	input [7:0] DL1_AWLEN,
	input [1:0] DL1_AWBURST,
	input DL1_AWVALID,
	output DL1_AWREADY,

	input [63:0] DL1_WDATA,
	input [7:0] DL1_WSTRB,
	input DL1_WLAST,
	input DL1_WVALID,
	output DL1_WREADY,

	output [1:0] DL1_BRESP,
	output DL1_BVALID,
	input DL1_BREADY,

	input [31:0] DL1_ARADDR,
	input [7:0] DL1_ARLEN,
	input [1:0] DL1_ARBURST,
	input DL1_ARVALID,
	output DL1_ARREADY,

	output [63:0] DL1_RDATA,
	output [1:0] DL1_RRESP,
	output DL1_RLAST,
	output DL1_RVALID,
	input DL1_RREADY,


	//L3Cache
	output [63:0] MEM_AWADDR,
	output [7:0] MEM_AWLEN,
	output [1:0] MEM_AWBURST,
	output MEM_AWVALID,
	input MEM_AWREADY,
	output [63:0] MEM_WDATA,
	output [7:0] MEM_WSTRB,
	output MEM_WLAST,
	output MEM_WVALID,
	input MEM_WREADY,

	input [1:0] MEM_BRESP,
	input MEM_BVALID,
	output MEM_BREADY,

	output [63:0] MEM_ARADDR,
	output [7:0] MEM_ARLEN,
	output [1:0] MEM_ARBURST,
	output MEM_ARVALID,
	input MEM_ARREADY,

	input [63:0] MEM_RDATA,
	input [1:0] MEM_RRESP,
	input MEM_RLAST,
	input MEM_RVALID,
	output MEM_RREADY,

	input l2c_fence,
	input CLK,
	input RSTn
);










// IIIIIIIIIILLLLLLLLLLL               1111111                           PPPPPPPPPPPPPPPPP        OOOOOOOOO     RRRRRRRRRRRRRRRRR   TTTTTTTTTTTTTTTTTTTTTTT
// I::::::::IL:::::::::L              1::::::1                           P::::::::::::::::P     OO:::::::::OO   R::::::::::::::::R  T:::::::::::::::::::::T
// I::::::::IL:::::::::L             1:::::::1                           P::::::PPPPPP:::::P  OO:::::::::::::OO R::::::RRRRRR:::::R T:::::::::::::::::::::T
// II::::::IILL:::::::LL             111:::::1                           PP:::::P     P:::::PO:::::::OOO:::::::ORR:::::R     R:::::RT:::::TT:::::::TT:::::T
//   I::::I    L:::::L                  1::::1                             P::::P     P:::::PO::::::O   O::::::O  R::::R     R:::::RTTTTTT  T:::::T  TTTTTT
//   I::::I    L:::::L                  1::::1                             P::::P     P:::::PO:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   I::::I    L:::::L                  1::::1                             P::::PPPPPP:::::P O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   I::::I    L:::::L                  1::::l                             P:::::::::::::PP  O:::::O     O:::::O  R:::::::::::::RR          T:::::T        
//   I::::I    L:::::L                  1::::l                             P::::PPPPPPPPP    O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   I::::I    L:::::L                  1::::l                             P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   I::::I    L:::::L                  1::::l                             P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   I::::I    L:::::L         LLLLLL   1::::l                             P::::P            O::::::O   O::::::O  R::::R     R:::::R        T:::::T        
// II::::::IILL:::::::LLLLLLLLL:::::L111::::::111                        PP::::::PP          O:::::::OOO:::::::ORR:::::R     R:::::R      TT:::::::TT      
// I::::::::IL::::::::::::::::::::::L1::::::::::1                        P::::::::P           OO:::::::::::::OO R::::::R     R:::::R      T:::::::::T      
// I::::::::IL::::::::::::::::::::::L1::::::::::1                        P::::::::P             OO:::::::::OO   R::::::R     R:::::R      T:::::::::T      
// IIIIIIIIIILLLLLLLLLLLLLLLLLLLLLLLL111111111111                        PPPPPPPPPP               OOOOOOOOO     RRRRRRRR     RRRRRRR      TTTTTTTTTTT      
//                                               ________________________                                                                                  
//                                               _::::::::::::::::::::::_                                                                                  
//                                               ________________________                                                                                  
                                                                              


	wire il1_wready_set, il1_wready_rst, il1_wready_qout;
	wire il1_bvalid_set, il1_bvalid_rst, il1_bvalid_qout;
	wire il1_arready_set, il1_arready_rst, il1_arready_qout;
	wire il1_arv_arr_flag_set, il1_arv_arr_flag_rst, il1_arv_arr_flag_qout;
	wire [31:0] il1_araddr_dnxta;
	wire [31:0] il1_araddr_dnxtb;
	wire [31:0] il1_araddr_qout;
	wire il1_araddr_ena, il1_araddr_enb, il1_arburst_en;
	wire [1:0] il1_arburst_dnxt;
	wire [1:0] il1_arburst_qout;
	wire il1_arlen_en;
	wire [7:0] il1_arlen_dnxt;
	wire [7:0] il1_arlen_qout;
	wire [7:0] il1_arlen_cnt_dnxta;
	wire [7:0] il1_arlen_cnt_dnxtb;
	wire [7:0] il1_arlen_cnt_qout;
	wire il1_arlen_cnt_ena, il1_arlen_cnt_enb;
	wire il1_rvalid_set, il1_rvalid_rst, il1_rvalid_qout;
	wire il1_rlast_set, il1_rlast_rst, il1_rlast_qout;
	wire il1_ar_rsp;
	wire il1_ar_end;


	assign IL1_ARREADY = il1_arready_qout;
	assign IL1_RDATA = ;
	assign IL1_RRESP = 2'b00;
	assign IL1_RLAST = il1_rlast_qout;
	assign IL1_RVALID	= il1_rvalid_qout;
	assign il1_ar_rsp = (~il1_arready_qout & IL1_ARVALID & ~il1_arv_arr_flag_qout);
	assign il1_ar_end = IL1_RVALID & IL1_RREADY & IL1_RLAST;


	
	assign il1_arready_set = il1_ar_rsp;
	assign il1_arready_rst = ~il1_ar_rsp & ~(il1_rvalid_qout & IL1_RREADY & il1_arlen_cnt_qout == il1_arlen_qout);
	gen_rsffr # (.DW(1)) il1_arready_rsffr (.set_in(il1_arready_set), .rst_in(il1_arready_rst), .qout(il1_arready_qout), .CLK(CLK), .RSTn(RSTn));

	assign il1_arv_arr_flag_set = il1_ar_rsp;
	assign il1_arv_arr_flag_rst = ~il1_ar_rsp & (il1_rvalid_qout & IL1_RREADY & il1_arlen_cnt_qout == il1_arlen_qout);
	gen_rsffr # (.DW(1)) il1_arv_arr_flag_rsffr (.set_in(il1_arv_arr_flag_set), .rst_in(il1_arv_arr_flag_rst), .qout(il1_arv_arr_flag_qout), .CLK(CLK), .RSTn(RSTn));



	assign il1_araddr_dnxta = IL1_ARADDR;
	assign il1_araddr_dnxtb = ({32{il1_arburst_qout == 2'b01}} & il1_araddr_qout + (1<<3));

	assign il1_araddr_ena = il1_ar_rsp;
	assign il1_araddr_enb = ((il1_arlen_cnt_qout <= il1_arlen_qout) & il1_rvalid_qout & IL1_RREADY);
	gen_dpdffren # (.DW(32)) il1_araddr_dpdffren( .dnxta(il1_araddr_dnxta), .ena(il1_araddr_ena), .dnxtb(il1_araddr_dnxtb), .enb(il1_araddr_enb), .qout(il1_araddr_qout), .CLK(CLK), .RSTn(RSTn) );

	assign il1_arburst_en = il1_ar_rsp;
	assign il1_arburst_dnxt = IL1_ARBURST;
	gen_dffren # (.DW(2)) il1_arburst_dffren (.dnxt(il1_arburst_dnxt), .qout(il1_arburst_qout), .en(il1_arburst_en), .CLK(CLK), .RSTn(RSTn));

	assign il1_arlen_en = il1_ar_rsp;
	assign il1_arlen_dnxt = IL1_ARLEN;
	gen_dffren # (.DW(8)) il1_arlen_dffren (.dnxt(il1_arlen_dnxt), .qout(il1_arlen_qout), .en(il1_arlen_en), .CLK(CLK), .RSTn(RSTn));

	assign il1_rlast_set = ((il1_arlen_cnt_qout == il1_arlen_qout) & ~il1_rlast_qout & il1_arv_arr_flag_qout )  ;
	assign il1_rlast_rst = il1_ar_rsp | (((il1_arlen_cnt_qout <= il1_arlen_qout) | il1_rlast_qout | ~il1_arv_arr_flag_qout ) & ( il1_rvalid_qout & IL1_RREADY));
	gen_rsffr # (.DW(1)) il1_rlast_rsffr (.set_in(il1_rlast_set), .rst_in(il1_rlast_rst), .qout(il1_rlast_qout), .CLK(CLK), .RSTn(RSTn));

	assign il1_arlen_cnt_dnxta = 8'd0;
	assign il1_arlen_cnt_dnxtb = il1_arlen_cnt_qout + 8'd1;
	assign il1_arlen_cnt_ena = il1_ar_rsp;
	assign il1_arlen_cnt_enb = ((il1_arlen_cnt_qout <= il1_arlen_qout) & il1_rvalid_qout & IL1_RREADY);
	gen_dpdffren # (.DW(8)) il1_arlen_cnt_dpdffren( .dnxta(il1_arlen_cnt_dnxta), .ena(il1_arlen_cnt_ena), .dnxtb(il1_arlen_cnt_dnxtb), .enb(il1_arlen_cnt_enb), .qout(il1_arlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );

	assign il1_rvalid_set = ~il1_rvalid_qout & il1_arv_arr_flag_qout;
	assign il1_rvalid_rst =  il1_rvalid_qout & IL1_RREADY;
	gen_rsffr # (.DW(1)) il1_rvalid_rsffr (.set_in(il1_rvalid_set), .rst_in(il1_rvalid_rst), .qout(il1_rvalid_qout), .CLK(CLK), .RSTn(RSTn));







// DDDDDDDDDDDDD      LLLLLLLLLLL               1111111                           PPPPPPPPPPPPPPPPP        OOOOOOOOO     RRRRRRRRRRRRRRRRR   TTTTTTTTTTTTTTTTTTTTTTT
// D::::::::::::DDD   L:::::::::L              1::::::1                           P::::::::::::::::P     OO:::::::::OO   R::::::::::::::::R  T:::::::::::::::::::::T
// D:::::::::::::::DD L:::::::::L             1:::::::1                           P::::::PPPPPP:::::P  OO:::::::::::::OO R::::::RRRRRR:::::R T:::::::::::::::::::::T
// DDD:::::DDDDD:::::DLL:::::::LL             111:::::1                           PP:::::P     P:::::PO:::::::OOO:::::::ORR:::::R     R:::::RT:::::TT:::::::TT:::::T
//   D:::::D    D:::::D L:::::L                  1::::1                             P::::P     P:::::PO::::::O   O::::::O  R::::R     R:::::RTTTTTT  T:::::T  TTTTTT
//   D:::::D     D:::::DL:::::L                  1::::1                             P::::P     P:::::PO:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   D:::::D     D:::::DL:::::L                  1::::1                             P::::PPPPPP:::::P O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   D:::::D     D:::::DL:::::L                  1::::l                             P:::::::::::::PP  O:::::O     O:::::O  R:::::::::::::RR          T:::::T        
//   D:::::D     D:::::DL:::::L                  1::::l                             P::::PPPPPPPPP    O:::::O     O:::::O  R::::RRRRRR:::::R         T:::::T        
//   D:::::D     D:::::DL:::::L                  1::::l                             P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   D:::::D     D:::::DL:::::L                  1::::l                             P::::P            O:::::O     O:::::O  R::::R     R:::::R        T:::::T        
//   D:::::D    D:::::D L:::::L         LLLLLL   1::::l                             P::::P            O::::::O   O::::::O  R::::R     R:::::R        T:::::T        
// DDD:::::DDDDD:::::DLL:::::::LLLLLLLLL:::::L111::::::111                        PP::::::PP          O:::::::OOO:::::::ORR:::::R     R:::::R      TT:::::::TT      
// D:::::::::::::::DD L::::::::::::::::::::::L1::::::::::1                        P::::::::P           OO:::::::::::::OO R::::::R     R:::::R      T:::::::::T      
// D::::::::::::DDD   L::::::::::::::::::::::L1::::::::::1                        P::::::::P             OO:::::::::OO   R::::::R     R:::::R      T:::::::::T      
// DDDDDDDDDDDDD      LLLLLLLLLLLLLLLLLLLLLLLL111111111111                        PPPPPPPPPP               OOOOOOOOO     RRRRRRRR     RRRRRRR      TTTTTTTTTTT      
//                                                        ________________________                                                                                  
//                                                        _::::::::::::::::::::::_                                                                                  
//                                                        ________________________              




	wire dl1_awready_set, dl1_awready_rst, dl1_awready_qout;
	wire dl1_awv_awr_flag_set, dl1_awv_awr_flag_rst, dl1_awv_awr_flag_qout;
	wire [AW-1:0] dl1_awaddr_dnxta;
	wire [AW-1:0] dl1_awaddr_dnxtb;
	wire [AW-1:0] dl1_awaddr_qout;
	wire dl1_awaddr_ena, dl1_awaddr_enb;
	wire dl1_awburst_en;
	wire [1:0] dl1_awburst_dnxt;
	wire [1:0] dl1_awburst_qout;
	wire dl1_awlen_en;
	wire [7:0] dl1_awlen_dnxt;
	wire [7:0] dl1_awlen_qout;
	wire [7:0] dl1_awlen_cnt_dnxta;
	wire [7:0] dl1_awlen_cnt_dnxtb;
	wire [7:0] dl1_awlen_cnt_qout;
	wire dl1_awlen_cnt_ena, dl1_awlen_cnt_enb;
	wire dl1_wready_set, dl1_wready_rst, dl1_wready_qout;
	wire dl1_bvalid_set, dl1_bvalid_rst, dl1_bvalid_qout;
	wire dl1_arready_set, dl1_arready_rst, dl1_arready_qout;
	wire dl1_arv_arr_flag_set, dl1_arv_arr_flag_rst, dl1_arv_arr_flag_qout;
	wire [AW-1:0] dl1_araddr_dnxta;
	wire [AW-1:0] dl1_araddr_dnxtb;
	wire [AW-1:0] dl1_araddr_qout;
	wire dl1_araddr_ena, dl1_araddr_enb, dl1_arburst_en;
	wire [1:0] dl1_arburst_dnxt;
	wire [1:0] dl1_arburst_qout;
	wire dl1_arlen_en;
	wire [7:0] dl1_arlen_dnxt;
	wire [7:0] dl1_arlen_qout;
	wire [7:0] dl1_arlen_cnt_dnxta;
	wire [7:0] dl1_arlen_cnt_dnxtb;
	wire [7:0] dl1_arlen_cnt_qout;
	wire dl1_arlen_cnt_ena, dl1_arlen_cnt_enb;
	wire dl1_rvalid_set, dl1_rvalid_rst, dl1_rvalid_qout;
	wire dl1_rlast_set, dl1_rlast_rst, dl1_rlast_qout;
	wire dl1_aw_rsp,dl1_ar_rsp;
	wire dl1_end_w, dl1_end_r;

	assign DL1_AWREADY = dl1_awready_qout;
	assign DL1_WREADY	= dl1_wready_qout;
	assign DL1_BRESP = 2'b00;
	assign DL1_BVALID	= dl1_bvalid_qout;
	assign DL1_ARREADY = dl1_arready_qout;
	assign DL1_RDATA = ;
	assign DL1_RRESP = 2'b00;
	assign DL1_RLAST = dl1_rlast_qout;
	assign DL1_RVALID = dl1_rvalid_qout;

	assign dl1_aw_rsp = (~dl1_awready_qout & DL1_AWVALID & ~dl1_awv_awr_flag_qout & ~dl1_arv_arr_flag_qout);
	assign dl1_ar_rsp = (~dl1_arready_qout & DL1_ARVALID & ~dl1_awv_awr_flag_qout & ~dl1_arv_arr_flag_qout);
	assign dl1_end_w = DL1_WVALID & DL1_WREADY & DL1_WLAST;
	assign dl1_end_r = DL1_RVALID & DL1_RREADY & DL1_RLAST;

	assign dl1_awready_set =  dl1_aw_rsp;
	assign dl1_awready_rst = ~dl1_aw_rsp & ~(DL1_WLAST & dl1_wready_qout);
	gen_rsffr # (.DW(1)) dl1_awready_rsffr (.set_in(dl1_awready_set), .rst_in(dl1_awready_rst), .qout(dl1_awready_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_awv_awr_flag_set = dl1_aw_rsp;
	assign dl1_awv_awr_flag_rst = ~dl1_aw_rsp & (DL1_WLAST & dl1_wready_qout);
	gen_rsffr # (.DW(1)) dl1_awv_awr_flag_rsffr (.set_in(dl1_awv_awr_flag_set), .rst_in(dl1_awv_awr_flag_rst), .qout(dl1_awv_awr_flag_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_awaddr_dnxta = DL1_AWADDR;
	assign dl1_awaddr_dnxtb = ( {32{dl1_awburst_qout == 2'b01}} & dl1_awaddr_qout + (1<<3) );
	assign dl1_awaddr_ena = dl1_aw_rsp;
	assign dl1_awaddr_enb = (dl1_awlen_cnt_qout <= dl1_awlen_qout) & dl1_wready_qout & DL1_WVALID;
	gen_dpdffren # (.DW(32)) dl1_awaddr_dpdffren( .dnxta(dl1_awaddr_dnxta), .ena(dl1_awaddr_ena), .dnxtb(dl1_awaddr_dnxtb), .enb(dl1_awaddr_enb), .qout(dl1_awaddr_qout), .CLK(CLK), .RSTn(RSTn) );

	assign dl1_awburst_en = dl1_aw_rsp;
	assign dl1_awburst_dnxt = DL1_AWBURST;
	gen_dffren # (.DW(2)) dl1_awburst_dffren (.dnxt(dl1_awburst_dnxt), .qout(dl1_awburst_qout), .en(dl1_awburst_en), .CLK(CLK), .RSTn(RSTn));

	assign dl1_awlen_en = dl1_aw_rsp;
	assign dl1_awlen_dnxt = DL1_AWLEN;
	gen_dffren # (.DW(8)) dl1_awlen_dffren (.dnxt(dl1_awlen_dnxt), .qout(dl1_awlen_qout), .en(dl1_awlen_en), .CLK(CLK), .RSTn(RSTn));

	assign dl1_awlen_cnt_dnxta = 8'd0;
	assign dl1_awlen_cnt_dnxtb = dl1_awlen_cnt_qout + 8'd1;
	assign dl1_awlen_cnt_ena = dl1_aw_rsp;
	assign dl1_awlen_cnt_enb = (dl1_awlen_cnt_qout <= dl1_awlen_qout) & dl1_wready_qout & DL1_WVALID;
	gen_dpdffren # (.DW(8)) dl1_awlen_cnt_dpdffren( .dnxta(dl1_awlen_cnt_dnxta), .ena(dl1_awlen_cnt_ena), .dnxtb(dl1_awlen_cnt_dnxtb), .enb(dl1_awlen_cnt_enb), .qout(dl1_awlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );

	assign dl1_wready_set = ~dl1_wready_qout & DL1_WVALID & dl1_awv_awr_flag_qout;
	assign dl1_wready_rst =  dl1_wready_qout & DL1_WLAST;
	gen_rsffr # (.DW(1)) dl1_wready_rsffr (.set_in(dl1_wready_set), .rst_in(dl1_wready_rst), .qout(dl1_wready_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_bvalid_set = ~dl1_bvalid_qout & dl1_awv_awr_flag_qout & dl1_wready_qout & DL1_WVALID & DL1_WLAST;
	assign dl1_bvalid_rst =  dl1_bvalid_qout & DL1_BREADY;
	gen_rsffr # (.DW(1)) dl1_bvalid_rsffr (.set_in(dl1_bvalid_set), .rst_in(dl1_bvalid_rst), .qout(dl1_bvalid_qout), .CLK(CLK), .RSTn(RSTn));



	assign dl1_arready_set = dl1_ar_rsp;
	assign dl1_arready_rst = ~dl1_ar_rsp & ~(dl1_rvalid_qout & DL1_RREADY & dl1_arlen_cnt_qout == dl1_arlen_qout);
	gen_rsffr # (.DW(1)) dl1_arready_rsffr (.set_in(dl1_arready_set), .rst_in(dl1_arready_rst), .qout(dl1_arready_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_arv_arr_flag_set = dl1_ar_rsp;
	assign dl1_arv_arr_flag_rst = ~dl1_ar_rsp & (dl1_rvalid_qout & DL1_RREADY & dl1_arlen_cnt_qout == dl1_arlen_qout);
	gen_rsffr # (.DW(1)) dl1_arv_arr_flag_rsffr (.set_in(dl1_arv_arr_flag_set), .rst_in(dl1_arv_arr_flag_rst), .qout(dl1_arv_arr_flag_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_araddr_dnxta = DL1_ARADDR;
	assign dl1_araddr_dnxtb = ({32{dl1_arburst_qout == 2'b01}} & dl1_araddr_qout + (1<<ADDR_LSB));
	assign dl1_araddr_ena = dl1_ar_rsp;
	assign dl1_araddr_enb = ((dl1_arlen_cnt_qout <= dl1_arlen_qout) & dl1_rvalid_qout & DL1_RREADY);
	gen_dpdffren # (.DW(32)) dl1_araddr_dpdffren( .dnxta(dl1_araddr_dnxta), .ena(dl1_araddr_ena), .dnxtb(dl1_araddr_dnxtb), .enb(dl1_araddr_enb), .qout(dl1_araddr_qout), .CLK(CLK), .RSTn(RSTn) );

	
	assign dl1_arburst_en = dl1_ar_rsp;
	assign dl1_arburst_dnxt = DL1_ARBURST;
	gen_dffren # (.DW(2)) dl1_arburst_dffren (.dnxt(dl1_arburst_dnxt), .qout(dl1_arburst_qout), .en(dl1_arburst_en), .CLK(CLK), .RSTn(RSTn));


	assign dl1_arlen_en = dl1_ar_rsp;
	assign dl1_arlen_dnxt = DL1_ARLEN;
	gen_dffren # (.DW(8)) dl1_arlen_dffren (.dnxt(dl1_arlen_dnxt), .qout(dl1_arlen_qout), .en(dl1_arlen_en), .CLK(CLK), .RSTn(RSTn));


	assign dl1_rlast_set = ((dl1_arlen_cnt_qout == dl1_arlen_qout) & ~dl1_rlast_qout & dl1_arv_arr_flag_qout )  ;
	assign dl1_rlast_rst = dl1_ar_rsp | (((dl1_arlen_cnt_qout <= dl1_arlen_qout) | dl1_rlast_qout | ~dl1_arv_arr_flag_qout ) & ( dl1_rvalid_qout & DL1_RREADY));
	gen_rsffr # (.DW(1)) dl1_rlast_rsffr (.set_in(dl1_rlast_set), .rst_in(dl1_rlast_rst), .qout(dl1_rlast_qout), .CLK(CLK), .RSTn(RSTn));



	assign dl1_arlen_cnt_dnxta = 8'd0;
	assign dl1_arlen_cnt_dnxtb = dl1_arlen_cnt_qout + 8'd1;
	assign dl1_arlen_cnt_ena = dl1_ar_rsp;
	assign dl1_arlen_cnt_enb = ((dl1_arlen_cnt_qout <= dl1_arlen_qout) & dl1_rvalid_qout & DL1_RREADY);
	gen_dpdffren # (.DW(8)) dl1_arlen_cnt_dpdffren( .dnxta(dl1_arlen_cnt_dnxta), .ena(dl1_arlen_cnt_ena), .dnxtb(dl1_arlen_cnt_dnxtb), .enb(dl1_arlen_cnt_enb), .qout(dl1_arlen_cnt_qout), .CLK(CLK), .RSTn(RSTn) );



	assign dl1_rvalid_set = ~dl1_rvalid_qout & dl1_arv_arr_flag_qout;
	assign dl1_rvalid_rst =  dl1_rvalid_qout & DL1_RREADY;
	gen_rsffr # (.DW(1)) dl1_rvalid_rsffr (.set_in(dl1_rvalid_set), .rst_in(dl1_rvalid_rst), .qout(dl1_rvalid_qout), .CLK(CLK), .RSTn(RSTn));









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
	wire mem_rready_set, mem_rready_rst, mem_rready_qout;
	wire write_resp_error, read_resp_error;
	wire mem_aw_req, mem_ar_req;
	wire mem_end_r, mem_end_w;


	assign MEM_AWLEN = 8'd0;
	assign MEM_AWBURST = 2'b00;
	assign MEM_AWVALID = mem_awvalid_qout;

	assign MEM_WSTRB = ;
	assign MEM_WLAST = mem_wlast_qout;
	assign MEM_WVALID = mem_wvalid_qout;
	assign MEM_BREADY = mem_bready_qout;

	assign MEM_ARLEN = 8'd15;
	assign MEM_ARVALID = mem_arvalid_qout;
	assign MEM_RREADY = mem_rready_qout;

	assign mem_end_r = MEM_RVALID & MEM_RREADY & MEM_RLAST;
	assign mem_end_w = MEM_WVALID & MEM_WREADY & MEM_WLAST;


	assign mem_awvalid_set = ~mem_awvalid_qout & mem_aw_req;
	assign mem_awvalid_rst =  mem_awvalid_qout & MEM_AWREADY ;
	gen_rsffr # (.DW(1)) mem_awvalid_rsffr (.set_in(mem_awvalid_set), .rst_in(mem_awvalid_rst), .qout(mem_awvalid_qout), .CLK(CLK), .RSTn(RSTn));

	assign mem_wvalid_set = (~mem_wvalid_qout & mem_aw_req);
	assign mem_wvalid_rst = (MEM_WREADY & mem_wvalid_qout & mem_wlast_qout) ;
	gen_rsffr # (.DW(1)) mem_wvalid_rsffr (.set_in(mem_wvalid_set), .rst_in(mem_wvalid_rst), .qout(mem_wvalid_qout), .CLK(CLK), .RSTn(RSTn));

	assign mem_wlast_set = ((write_index_qout == MEM_AWLEN - 1 ) & MEM_WREADY & mem_wvalid_qout);
	assign mem_wlast_rst = ~mem_wlast_set & ( MEM_WREADY & mem_wvalid_qout | mem_wlast_qout );
	gen_rsffr # (.DW(1)) mem_wlast_rsffr (.set_in(mem_wlast_set), .rst_in(mem_wlast_rst), .qout(mem_wlast_qout), .CLK(CLK), .RSTn(RSTn));

	assign write_index_dnxt = mem_aw_req ? 8'd0 :
								(
									(MEM_WREADY & mem_wvalid_qout & (write_index_qout != MEM_AWLEN)) ? (write_index_qout + 8'd1) : write_index_qout
								);							
	gen_dffr # (.DW(8)) write_index_dffr (.dnxt(write_index_dnxt), .qout(write_index_qout), .CLK(CLK), .RSTn(RSTn));

	assign mem_bready_set = (MEM_BVALID && ~mem_bready_qout);
	assign mem_bready_rst = mem_bready_qout;
	gen_rsffr # (.DW(1)) mem_bready_rsffr (.set_in(mem_bready_set), .rst_in(mem_bready_rst), .qout(mem_bready_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign write_resp_error = mem_bready_qout & MEM_BVALID & MEM_BRESP[1]; 
	assign mem_arvalid_set = ~mem_arvalid_qout & mem_ar_req;
	assign mem_arvalid_rst = mem_arvalid_qout & MEM_ARREADY ;
	gen_rsffr # (.DW(1)) mem_arvalid_rsffr (.set_in(mem_arvalid_set), .rst_in(mem_arvalid_rst), .qout(mem_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	
	assign mem_rready_set = MEM_RVALID & (~MEM_RLAST | ~mem_rready_qout);
	assign mem_rready_rst = MEM_RVALID &   MEM_RLAST &  mem_rready_qout;
	gen_rsffr # (.DW(1)) mem_rready_rsffr (.set_in(mem_rready_set), .rst_in(mem_rready_rst), .qout(mem_rready_qout), .CLK(CLK), .RSTn(RSTn));

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




localparam L2C_CFREE = 0;
localparam L2C_CKTAG = 1;
// localparam L2C_EVICT = 2;
localparam L2C_FLASH = 2;
localparam L2C_RSPRD = 3;
localparam L2C_RSPWR = 4;
localparam L2C_FENCE = 5;

localparam ADDR_LSB = $clog2(DW*BK/8);
localparam LINE_W = $clog2(CL); 
localparam TAG_W = 32 - ADDR_LSB - LINE_W;


wire [2:0] l2c_state_dnxt;
wire [2:0] l2c_state_qout;

gen_dffr # (.DW(3)) l2c_state_dffr (.dnxt(l2c_state_dnxt), .qout(l2c_state_qout), .CLK(CLK), .RSTn(RSTn));



assign l2c_state_dnxt = 
	  ( {3{l2c_state_qout == L2C_CFREE}} & ( cache_fence_qout ? L2C_FENCE : ( (IL1_ARVALID | DL1_ARVALID | DL1_AWVALID) ? L2C_CKTAG : L2C_CFREE) ) )
	| ( {3{l2c_state_qout == L2C_FENCE}} & ( ( db_empty ) ? L2C_CFREE : L2C_FENCE ) )
	| (
		{3{23c_state_qout == L2C_CKTAG}} & 
		(
			//   ({3{ cb_hit & cache_valid_qout[cl_sel] & L2C_AWVALID & ~ L2C_ARVALID}} & (db_full ? L2C_EVICT : L2C_RSPWR ) )
			// | ({3{ cb_hit & cache_valid_qout[cl_sel] & L2C_ARVALID}} & L3C_RSPRD )
			// | ({3{~cb_hit & cache_valid_qout[cl_sel]              }} & L3C_EVICT )
			// | ({3{         ~cache_valid_qout[cl_sel]              }} & L3C_FLASH )
		)
	)
	| ( {3{l2c_state_qout == L2C_FLASH}} & ( mem_end_r ? L2C_CKTAG : L2C_FLASH ) )
	| ( {3{l2c_state_qout == L2C_RSPRD}} & ( l2c_end_r ? L2C_CFREE : L2C_RSPRD ) )
	| ( {3{l2c_state_qout == L2C_RSPWR}} & ( l2c_end_w ? L2C_CFREE : L2C_RSPWR ) )
	;





cache_mem # ( .DW(DW), .BK(BK), .CB(CB), .CL(CL), .TAG_W(TAG_W) ) i_cache_mem
(
	.cache_addr(cache_addr),
	.cache_en_w(cache_en_w),
	.cache_en_r(cache_en_r),
	.cache_info_wstrb(cache_info_wstrb),
	.cache_info_w(cache_info_w),
	.cache_info_r(cache_info_r),

	.tag_addr(tag_addr),
	.tag_en_w(tag_en_w),
	.tag_en_r(tag_en_r),
	.tag_info_wstrb(tag_info_wstrb),
	.tag_info_w(tag_info_w),
	.tag_info_r(tag_info_r),

	.CLK(CLK),
	.RSTn(RSTn)
);




wire cache_fence_set;
wire cache_fence_rst;
wire cache_fence_qout;

wire [2:0] l2c_state_dnxt;
wire [2:0] l2c_state_qout;

wire [31:0] cache_addr;
wire [CB-1:0] cache_en_w;
wire [CB-1:0] cache_en_r;
wire [7:0] cache_info_wstrb;
wire [63:0] cache_info_w;
wire [64*CB-1:0] cache_info_r;

wire [31:0] tag_addr;
wire [CB-1:0] tag_en_w;
wire [CB-1:0] tag_en_r;
wire [(TAG_W+7)/8-1:0] tag_info_wstrb;
wire [TAG_W-1:0] tag_info_w;
wire [TAG_W*CB-1:0] tag_info_r;

wire [31:0] cache_addr_dnxt;
wire [31:0] cache_addr_qout;

wire [CB-1:0] cb_hit;
wire [CL-1:0] cl_sel;



wire [CL*CB-1:0] cache_valid_dnxt;
wire [CL*CB-1:0] cache_valid_qout;
wire [CB-1:0]cache_valid_en;

generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		gen_dffren # (.DW(CL)) cache_valid_dffren (.dnxt(cache_valid_dnxt[CL*cb +: cb]), .qout(cache_valid_qout[CL*cb +: cb]), .en(cache_valid_en[cb]), .CLK(CLK), .RSTn(RSTn));
	end
endgenerate





endmodule





