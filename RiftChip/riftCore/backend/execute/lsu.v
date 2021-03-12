/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-12 14:58:23
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

	output [31:0] LSU_AWADDR,
	output LSU_AWVALID,
	input LSU_AWREADY,

	output [63:0] LSU_WDATA,
	output [7:0] LSU_WSTRB,
	output LSU_WVALID,
	input LSU_WREADY,

	input [1:0] LSU_BRESP,
	input LSU_BVALID,
	output LSU_BREADY,

	output [31:0] LSU_ARADDR,
	output LSU_ARVALID,
	input LSU_ARREADY,

	input [63:0] LSU_RDATA,
	input [1:0] LSU_RRESP,
	input LSU_RVALID,
	output LSU_RREADY,

	output lsu_fencei_valid,


	output issue_lsu_ready,
	input issue_lsu_valid,
	input [DW-1:0] issue_lsu_info,
	
	output lsu_wb_valid,
	output [63:0] lsu_wb_res,
	output [(5+`RB-1):0] lsu_wb_rd0,

	//from commit
	input suCommited,
	output isLsuAccessFault,

	input flush,
	input CLK,
	input RSTn
);

	wire [63:0] lsu_wb_res_dnxt;
	wire [63:0] lsu_wb_res_qout;
	wire rd_end, wr_end, fence_end;
	wire lsu_wb_valid_set, lsu_wb_valid_rst, lsu_wb_valid_qout;

	assign fence_end = (rv64zi_fence_i | rv64i_fence) & issue_lsu_valid;
	assign rd_end = LSU_RVALID & LSU_RREADY;
	assign wr_end = rd_end;


	assign issue_lsu_ready = ~lsu_busy_qout & ~issue_lsu_valid;

	assign lsu_wb_valid_set = ( fence_end | rd_end | wr_end ) & ~flush;
	assign lsu_wb_valid_rst = lsu_wb_valid_qout | flush;
	assign lsu_wb_valid = lsu_wb_valid_qout;

	assign lsu_wb_res = lsu_wb_res_qout;
	assign lsu_wb_res_dnxt = 
			rd_end ? 
			(
				({64{exe_lb_qout}} & ( isUsi ? {56'b0,LSU_RDATA[7:0]} : {{56{LSU_RDATA[7]}},LSU_RDATA[7:0]} ))
				|
				({64{exe_lh_qout}} & ( isUsi ? {48'b0,LSU_RDATA[15:0]} : {{48{LSU_RDATA[15]}},LSU_RDATA[15:0]} ))
				|
				({64{exe_lw_qout}} & ( isUsi ? {32'b0,LSU_RDATA[31:0]} : {{32{LSU_RDATA[31]}},LSU_RDATA[31:0]} ))
				|
				({64{exe_ld_qout}} & LSU_RDATA)			
			) :
			lsu_wb_res_qout;



gen_dffren # (.DW((5+`RB))) lsu_wb_rd0_dffren ( .dnxt(lsu_rd0_dnxt), .qout(lsu_wb_rd0), .en(issue_lsu_valid), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) lsu_wb_valid_rsffr ( .set_in(lsu_wb_valid_set), .rst_in(lsu_wb_valid_rst), .qout(lsu_wb_valid_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) lsu_wb_res_dffr (.dnxt(lsu_wb_res_dnxt), .qout(lsu_wb_res_qout), .CLK(CLK), .RSTn(RSTn));






	
	wire rv64i_lb, rv64i_lh, rv64i_lw, rv64i_ld, rv64i_lbu, rv64i_lhu, rv64i_lwu, rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd, rv64zi_fence_i, rv64i_fence;

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
			} = issue_lsu_info;




	// wire isWTrans_pending_set;
	// wire isWTrans_pending_rst;
	// wire isWTrans_pending_qout;
	// wire isWTrans_invalid_set;
	// wire isWTrans_invalid_rst;
	// wire isWTrans_invalid_qout;

	wire isRTrans_pending_set, isRTrans_pending_rst, isRTrans_pending_qout;
	wire isRTrans_invalid_set, isRTrans_invalid_rst, isRTrans_invalid_qout;




	wire axi_awvalid_set, axi_awvalid_rst, axi_awvalid_qout;
	wire axi_wvalid_set, axi_wvalid_rst, axi_wvalid_qout;
	wire axi_bready_set, axi_bready_rst, axi_bready_qout;

	wire axi_arvalid_set, axi_arvalid_rst, axi_arvalid_qout;
	wire axi_rready_set, axi_rready_rst, axi_rready_qout;


	assign lsu_fencei_valid = issue_lsu_valid & rv64zi_fence_i;


	wire accessFault;

	wire [31:0] exe_op1_dnxt;
	wire [31:0] exe_op1_qout;
	wire [31:0] exe_op2_dnxt;
	wire [31:0] exe_op2_qout;

	wire exe_isUsi_dnxt, exe_isUsi_qout;
	wire exe_lb_dnxt, exe_lb_qout;
	wire exe_lh_dnxt, exe_lh_qout;
	wire exe_lw_dnxt, exe_lw_qout;
	wire exe_ld_dnxt, exe_ld_qout;

	assign exe_op1_dnxt     = issue_lsu_valid ? lsu_op1[31:0] : exe_op1_qout;
	assign exe_op2_dnxt     = issue_lsu_valid ? lsu_op2[31:0] : exe_op2_qout;

	assign exe_isUsi_dnxt   = issue_lsu_valid ? (rv64i_lbu | rv64i_lhu | rv64i_lwu) : exe_isUsi_qout;
	assign exe_lb_dnxt      = issue_lsu_valid ? (rv64i_lb | rv64i_lbu) : exe_lb_qout;
	assign exe_lh_dnxt      = issue_lsu_valid ? (rv64i_lh | rv64i_lhu) : exe_lh_qout;
	assign exe_lw_dnxt      = issue_lsu_valid ? (rv64i_lw | rv64i_lwu) : exe_lw_qout;
	assign exe_ld_dnxt      = issue_lsu_valid ? (rv64i_ld)             : exe_ld_qout;


	gen_dffr # (.DW(32)) exe_op1_dffr (.dnxt(exe_op1_dnxt), .qout(exe_op1_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(32)) exe_op2_dffr (.dnxt(exe_op2_dnxt), .qout(exe_op2_qout), .CLK(CLK), .RSTn(RSTn));

	gen_dffren # (.DW(1)) exe_isUsi_dffr ( .dnxt(exe_isUsi_dnxt), .qout(exe_isUsi_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) exe_islb_dffr ( .dnxt(exe_lb_dnxt), .qout(exe_lb_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) exe_islh_dffr ( .dnxt(exe_lh_dnxt), .qout(exe_lh_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) exe_islw_dffr ( .dnxt(exe_lw_dnxt), .qout(exe_lw_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) exe_isld_dffr ( .dnxt(exe_ld_dnxt), .qout(exe_ld_qout), .CLK(CLK), .RSTn(RSTn));






	wire lsu_wen;
	wire lsu_ren;
	wire [7:0] lsu_wstrb;


	assign lsu_ren = rv64i_lb | rv64i_lh | rv64i_lw | rv64i_ld | rv64i_lbu | rv64i_lhu | rv64i_lwu;
	assign lsu_wen = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
	assign lsu_wstrb =    ({8{rv64i_sb}} & 8'b1  )
						| ({8{rv64i_sh}} & 8'b11 )
						| ({8{rv64i_sw}} & 8'b1111 )
						| ({8{rv64i_sd}} & 8'b11111111 );

	wire axi_rsp_ready = axi_bready_set | axi_rready_set;
	wire axi_trans_pending = isRTrans_pending_qout;
	wire axi_trans_invalid = isRTrans_invalid_qout;





wire lsu_busy_set;
wire lsu_busy_rst;
wire lsu_busy_qout;

assign lsu_busy_set = issue_lsu_valid & (~rv64zi_fence_i & ~rv64i_fence) & ~flush;
assign lsu_busy_rst = axi_rsp_ready;

gen_rsffr #(.DW(1)) lsu_busy_rsffr (.set_in(lsu_busy_set), .rst_in(lsu_busy_rst), .qout(lsu_busy_qout), .CLK(CLK), .RSTn(RSTn));



// assign isWTrans_pending_set = axi_awvalid_set;
// assign isWTrans_pending_rst = (~axi_awvalid_set & axi_bready_set);
// assign isWTrans_invalid_set = isWTrans_pending_qout & flush;
// assign isWTrans_invalid_rst = isWTrans_invalid_qout & axi_bready_set;


assign isRTrans_invalid_set = isRTrans_pending_qout & flush;
assign isRTrans_invalid_rst = axi_rready_set;



// gen_rsffr # (.DW(1)) isWTrans_pending_rsffr (.set_in(isWTrans_pending_set), .rst_in(isWTrans_pending_rst), .qout(isWTrans_pending_qout), .CLK(CLK), .RSTn(RSTn));
// gen_rsffr # (.DW(1)) isWTrans_invalid_rsffr (.set_in(isWTrans_invalid_set), .rst_in(isWTrans_invalid_rst), .qout(isWTrans_invalid_qout), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) isRTrans_invalid_rsffr (.set_in(isRTrans_invalid_set), .rst_in(isRTrans_invalid_rst), .qout(isRTrans_invalid_qout), .CLK(CLK), .RSTn(RSTn));



	// assign LSU_AWADDR	= lsu_op1;
	// assign LSU_WDATA	= lsu_op2;
	// assign LSU_AWPROT	= 3'b000;
	// assign LSU_AWVALID = axi_awvalid_qout;
	// assign LSU_WVALID	= axi_wvalid_qout;
	// assign LSU_WSTRB = lsu_wstrb;
	// assign LSU_BREADY	= axi_bready_qout;

	// assign axi_awvalid_set = lsu_wen & issue_lsu_valid & ~flush;
	// assign axi_awvalid_rst = ~axi_awvalid_set & (LSU_AWREADY & axi_awvalid_qout);
	// assign axi_wvalid_set = axi_awvalid_set;
	// assign axi_wvalid_rst = ~axi_wvalid_set & (LSU_WREADY & axi_wvalid_qout);	
	// assign axi_bready_set = LSU_BVALID & ~axi_bready_qout;
	// assign axi_bready_rst = axi_bready_qout;

	wire [31:0] araddr_req;
	assign araddr_req = issue_lsu_valid ? lsu_op1 : exe_op1_qout;

	assign LSU_ARADDR	= araddr_req;
	assign LSU_ARVALID = axi_arvalid_qout;
	assign LSU_RREADY	= axi_rready_qout;

	assign isRTrans_pending_set = lsu_ren & issue_lsu_valid & ~flush;
	assign isRTrans_pending_rst = (~isRTrans_pending_set & axi_rready_set);

	assign axi_arvalid_set =
				stpb_isHazard_r & ~flush
					(
						(~axi_arvalid_qout & isRTrans_pending_qout) | (lsu_ren & issue_lsu_valid )
					);
	assign axi_arvalid_rst = ~axi_arvalid_set & ( LSU_ARVALID & LSU_ARREADY);

	assign axi_rready_set = LSU_RVALID & ~axi_rready_qout;
	assign axi_rready_rst = axi_rready_qout;

	gen_rsffr # (.DW(1)) isRTrans_pending_rsffr (.set_in(isRTrans_pending_set), .rst_in(isRTrans_pending_rst), .qout(), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));




	wire AccessFault_set;
	wire AccessFault_rst;
	wire AccessFault_qout;


	assign accessFault = (| lsu_op1[63:32]);

	assign AccessFault_set = accessFault & issue_lsu_valid;
	assign AccessFault_rst = flush;
	assign isLsuAccessFault = AccessFault_qout;

	gen_rsffr # (.DW(1)) AccessFault_rsffr ( .set_in(AccessFault_set), .rst_in(AccessFault_rst), .qout(AccessFault_qout), .CLK (CLK), .RSTn(RSTn));











wire [31:0] stpb_chkAddr;
wire stpb_isHazard_r;
wire stpb_push;
wire [103:0] stpb_data_i;
wire stpb_pop;
wire [103:0] stpb_data_o;
wire stpb_commit;
wire stpb_empty;
wire stpb_full;




assign stpb_chkAddr = araddr_req;





initial $info("then store can be executed only after the instruction be commited "); 

stp_block # ( .DW(64 + 8 + 32), .DP(8), .TAG_W(32) ) store_pending_block
(
	.chkAddr(stpb_chkAddr),
	.isHazard_r(stpb_isHazard_r),

	.push(stpb_push),
	.data_i(stpb_data_i),
	.pop(stpb_pop),
	.data_o(stpb_data_o),

	.commit(stpb_commit)
	.empty(stpb_empty),
	.full(stpb_full),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);


	assign axi_awvalid_set = ~axi_awvalid_qout & ~stpb_empty;
	assign axi_awvalid_rst = ~axi_awvalid_set & (LSU_AWREADY & axi_awvalid_qout);
	assign axi_wvalid_set = axi_awvalid_set;
	assign axi_wvalid_rst = ~axi_wvalid_set & (LSU_WREADY & axi_wvalid_qout);	
	assign axi_bready_set = LSU_BVALID & ~axi_bready_qout;
	assign axi_bready_rst = axi_bready_qout;

	gen_slffr # (.DW(1)) axi_awvalid_slffr (.set_in(axi_awvalid_set), .rst_in(axi_awvalid_rst), .qout(axi_awvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_wvalid_rsffr (.set_in(axi_wvalid_set), .rst_in(axi_wvalid_rst), .qout(axi_wvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # (.DW(1)) axi_bready_rsffr (.set_in(axi_bready_set), .rst_in(axi_bready_rst), .qout(axi_bready_qout), .CLK(CLK), .RSTn(RSTn));


	assign {LSU_WDATA, LSU_WSTRB, LSU_AWADDR} = stpb_data_o;
	assign stpb_pop = LSU_AWVALID & LSU_AWREADY;


	assign LSU_AWPROT	= 3'b000;
	assign LSU_AWVALID = axi_awvalid_qout;
	assign LSU_WVALID	= axi_wvalid_qout;


	assign LSU_BREADY	= axi_bready_qout;



endmodule














