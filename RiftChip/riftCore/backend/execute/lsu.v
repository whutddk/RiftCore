/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-07 10:02:50
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

module lsu #
(
	parameter DW = `LSU_EXEPARAM_DW
)
(

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

	output lsu_fencei_valid,


	//can only execute in order right now
	output lsu_exeparam_ready,
	input lsu_exeparam_valid,
	input [DW-1:0] lsu_exeparam,
	
	output lsu_writeback_valid,
	output [63:0] lsu_res_qout,
	output [(5+`RB-1):0] lsu_rd0_qout,

	output isLsuAccessFault,

	input flush,
	input CLK,
	input RSTn
);


wire [DW-1:0] lsu_exeparam_hold_dnxt = lsu_exeparam;
wire [DW-1:0] lsu_exeparam_hold_qout;
gen_dffr # (.DW(DW)) lu_exeparam_hold ( .dnxt(lsu_exeparam_hold_dnxt), .qout(lsu_exeparam_hold_qout), .CLK(CLK), .RSTn(RSTn));

	
	wire rv64i_lb;
	wire rv64i_lh;
	wire rv64i_lw;
	wire rv64i_ld;
	wire rv64i_lbu;
	wire rv64i_lhu;
	wire rv64i_lwu;
	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;
	wire rv64zi_fence_i;
	wire rv64i_fence;

	wire [(5+`RB)-1:0] lsu_rd0_dnxt;
	wire [63:0] lsu_op1;
	wire [63:0] lsu_op2;

	assign { 
			rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu,
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
			rv64zi_fence_i, rv64i_fence,
			lsu_rd0_dnxt,
			lsu_op1,
			lsu_op2
			} = lsu_exeparam;


	wire isUsi;

	wire lsu_fun_lb;
	wire lsu_fun_lh;
	wire lsu_fun_lw;
	wire lsu_fun_ld;

	wire isWTrans_pending_set;
	wire isWTrans_pending_rst;
	wire isWTrans_pending_qout;
	wire isWTrans_invalid_set;
	wire isWTrans_invalid_rst;
	wire isWTrans_invalid_qout;

	wire isRTrans_pending_set;
	wire isRTrans_pending_rst;
	wire isRTrans_pending_qout;
	wire isRTrans_invalid_set;
	wire isRTrans_invalid_rst;
	wire isRTrans_invalid_qout;

	wire lsu_wb_valid_set;
	wire lsu_wb_valid_rst;


	wire axi_awvalid_set, axi_awvalid_rst, axi_awvalid_qout;
	wire axi_wvalid_set, axi_wvalid_rst, axi_wvalid_qout;
	wire axi_bready_set, axi_bready_rst, axi_bready_qout;

	wire axi_arvalid_set, axi_arvalid_rst, axi_arvalid_qout;
	wire axi_rready_set, axi_rready_rst, axi_rready_qout;


	assign lsu_fencei_valid = lsu_exeparam_valid & rv64zi_fence_i;


	wire accessFault;



	gen_dffren # (.DW(1)) isUsiHold_dffren ( .dnxt(rv64i_lbu | rv64i_lhu | rv64i_lwu), .qout(isUsi), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));
	
	gen_dffren # (.DW(1)) islb_dffren ( .dnxt(rv64i_lb | rv64i_lbu), .qout(lsu_fun_lb), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) islh_dffren ( .dnxt(rv64i_lh | rv64i_lhu), .qout(lsu_fun_lh), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) islw_dffren ( .dnxt(rv64i_lw | rv64i_lwu), .qout(lsu_fun_lw), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) isld_dffren ( .dnxt(rv64i_ld), .qout(lsu_fun_ld), .en(axi_arvalid_set), .CLK(CLK), .RSTn(RSTn));



	assign lsu_res_qout = 
			({64{lsu_fun_lb}} & ( isUsi ? {56'b0,LSU_RDATA[7:0]} : {{56{LSU_RDATA[7]}},LSU_RDATA[7:0]} ))
			|
			({64{lsu_fun_lh}} & ( isUsi ? {48'b0,LSU_RDATA[15:0]} : {{48{LSU_RDATA[15]}},LSU_RDATA[15:0]} ))
			|
			({64{lsu_fun_lw}} & ( isUsi ? {32'b0,LSU_RDATA[31:0]} : {{32{LSU_RDATA[31]}},LSU_RDATA[31:0]} ))
			|
			({64{lsu_fun_ld}} & LSU_RDATA);


	wire lsu_wen;
	wire lsu_ren;
	wire [7:0] lsu_wstrb;

	// assign lsu_addr = lsu_op1;
	// assign lsu_data_w = lsu_op2;
	assign lsu_ren = rv64i_lb | rv64i_lh | rv64i_lw | rv64i_ld | rv64i_lbu | rv64i_lhu | rv64i_lwu;
	assign lsu_wen = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	assign lsu_wstrb = ({8{rv64i_sb}} & 8'b1  )
						|
						({8{rv64i_sh}} & 8'b11 )
						|
						({8{rv64i_sw}} & 8'b1111 )
						|
						({8{rv64i_sd}} & 8'b11111111 );

	wire axi_rsp_ready = axi_bready_set | axi_rready_set;
	wire axi_trans_pending = isWTrans_pending_qout | isRTrans_pending_qout;
	wire axi_trans_invalid = isWTrans_invalid_qout | isRTrans_invalid_qout;



	assign lsu_exeparam_ready = ~lsu_busy_qout & ~lsu_exeparam_valid;

wire lsu_busy_set;
wire lsu_busy_rst;
wire lsu_busy_qout;

assign lsu_busy_set = lsu_exeparam_valid & (~rv64zi_fence_i & ~rv64i_fence);
assign lsu_busy_rst = axi_rsp_ready;

gen_rsffr #(.DW(1)) lsu_busy_rsffr (.set_in(lsu_busy_set), .rst_in(lsu_busy_rst), .qout(lsu_busy_qout), .CLK(CLK), .RSTn(RSTn));



assign isWTrans_pending_set = axi_awvalid_set;
assign isWTrans_pending_rst = (~axi_awvalid_set & axi_bready_set);
assign isWTrans_invalid_set = isWTrans_pending_qout & flush;
assign isWTrans_invalid_rst = isWTrans_invalid_qout & axi_bready_set;

assign isRTrans_pending_set = axi_arvalid_set;
assign isRTrans_pending_rst = (~axi_arvalid_set & axi_rready_set);
assign isRTrans_invalid_set = isRTrans_pending_qout & flush;
assign isRTrans_invalid_rst = axi_rready_set;

assign lsu_wb_valid_set = ((axi_rsp_ready & ~axi_trans_invalid) | ((rv64zi_fence_i | rv64i_fence) & lsu_exeparam_valid)) & ~flush;
assign lsu_wb_valid_rst = lsu_writeback_valid | flush;

gen_rsffr # (.DW(1)) isWTrans_pending_rsffr (.set_in(isWTrans_pending_set), .rst_in(isWTrans_pending_rst), .qout(isWTrans_pending_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) isWTrans_invalid_rsffr (.set_in(isWTrans_invalid_set), .rst_in(isWTrans_invalid_rst), .qout(isWTrans_invalid_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) isRTrans_pending_rsffr (.set_in(isRTrans_pending_set), .rst_in(isRTrans_pending_rst), .qout(isRTrans_pending_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) isRTrans_invalid_rsffr (.set_in(isRTrans_invalid_set), .rst_in(isRTrans_invalid_rst), .qout(isRTrans_invalid_qout), .CLK(CLK), .RSTn(RSTn));


gen_dffren # (.DW((5+`RB))) lsu_rd0 ( .dnxt(lsu_rd0_dnxt), .qout(lsu_rd0_qout), .en(lsu_exeparam_valid), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) lsu_wb_valid_rsffr ( .set_in(lsu_wb_valid_set), .rst_in(lsu_wb_valid_rst), .qout(lsu_writeback_valid), .CLK(CLK), .RSTn(RSTn));











	assign LSU_AWADDR	= lsu_op1;
	assign LSU_WDATA	= lsu_op2;
	assign LSU_AWPROT	= 3'b000;
	assign LSU_AWVALID = axi_awvalid_qout;

	assign LSU_WVALID	= axi_wvalid_qout;
	assign LSU_WSTRB = lsu_wstrb;

	assign LSU_BREADY	= axi_bready_qout;
	assign LSU_ARADDR	= lsu_op1;
	assign LSU_ARVALID = axi_arvalid_qout;
	assign LSU_ARPROT	= 3'b001;
	assign LSU_RREADY	= axi_rready_qout;



	assign axi_awvalid_set = lsu_wen & lsu_exeparam_valid & ~flush & ~accessFault;
	assign axi_awvalid_rst = ~axi_awvalid_set & (LSU_AWREADY & axi_awvalid_qout);
	assign axi_wvalid_set = axi_awvalid_set;
	assign axi_wvalid_rst = ~axi_wvalid_set & (LSU_WREADY & axi_wvalid_qout);	
	assign axi_bready_set = LSU_BVALID & ~axi_bready_qout;
	assign axi_bready_rst = axi_bready_qout;

	gen_slffr # (.DW(1)) axi_awvalid_slffr (.set_in(axi_awvalid_set), .rst_in(axi_awvalid_rst), .qout(axi_awvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_wvalid_rsffr (.set_in(axi_wvalid_set), .rst_in(axi_wvalid_rst), .qout(axi_wvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_bready_rsffr (.set_in(axi_bready_set), .rst_in(axi_bready_rst), .qout(axi_bready_qout), .CLK(CLK), .RSTn(RSTn));


	assign axi_arvalid_set = lsu_ren & lsu_exeparam_valid & ~flush;
	assign axi_arvalid_rst = ~axi_arvalid_set & (LSU_ARREADY & axi_arvalid_qout);
	assign axi_rready_set = LSU_RVALID & ~axi_rready_qout;
	assign axi_rready_rst = axi_rready_qout;


	gen_slffr # (.DW(1)) axi_arvalid_slffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));



	assign accessFault = (| lsu_op1[63:32]);
	gen_dffren # (.DW(1)) AccessFault_dffren ( .dnxt(accessFault), .qout(isLsuAccessFault), .en(lsu_exeparam_valid), .CLK (CLK), .RSTn(RSTn));




















endmodule














