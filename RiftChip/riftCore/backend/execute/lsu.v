/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-13 18:15:14
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

	output lsu_mstReq_valid,
	output [63:0] lsu_addr,
	output [63:0] lsu_data_w,
	input [63:0] lsu_data_r,
	output [7:0] lsu_wstrb,
	input lsu_slvRsp_valid,

	//can only execute in order right now
	output lsu_exeparam_ready,
	input lsu_exeparam_valid,
	input [DW-1:0] lsu_exeparam,
	
	output lsu_writeback_valid,
	output [63:0] lsu_res_qout,
	output [(5+`RB-1):0] lsu_rd0_qout,

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

	wire isLSU_busy_set;
	wire isLSU_busy_rst;
	wire isLSU_busy_qout;

	wire lsu_wb_valid_set;
	wire lsu_wb_valid_rst;

	gen_dffren # (.DW(1)) isUsiHold_dffren ( .dnxt(rv64i_lbu | rv64i_lhu | rv64i_lwu), .qout(isUsi), .en(lsu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
	
	gen_dffren # (.DW(1)) islb_dffren ( .dnxt(rv64i_lb | rv64i_lbu), .qout(lsu_fun_lb), .en(lsu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) islh_dffren ( .dnxt(rv64i_lh | rv64i_lhu), .qout(lsu_fun_lh), .en(lsu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) islw_dffren ( .dnxt(rv64i_lw | rv64i_lwu), .qout(lsu_fun_lw), .en(lsu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
	gen_dffren # (.DW(1)) isld_dffren ( .dnxt(rv64i_ld), .qout(lsu_fun_ld), .en(lsu_mstReq_valid), .CLK(CLK), .RSTn(RSTn));



	assign lsu_res_qout = 
			({64{lsu_fun_lb}} & ( isUsi ? {56'b0,lsu_data_r[7:0]} : {{56{lsu_data_r[7]}},lsu_data_r[7:0]} ))
			|
			({64{lsu_fun_lh}} & ( isUsi ? {48'b0,lsu_data_r[15:0]} : {{48{lsu_data_r[15]}},lsu_data_r[15:0]} ))
			|
			({64{lsu_fun_lw}} & ( isUsi ? {32'b0,lsu_data_r[31:0]} : {{32{lsu_data_r[31]}},lsu_data_r[31:0]} ))
			|
			({64{lsu_fun_ld}} & lsu_data_r);




	assign lsu_mstReq_valid = lsu_exeparam_valid & ~rv64zi_fence_i & ~rv64i_fence & ~flush;
	assign lsu_addr = lsu_op1;
	assign lsu_data_w = lsu_op2;
	assign lsu_wstrb = ({8{rv64i_sb}} & 8'b1  )
						|
						({8{rv64i_sh}} & 8'b11 )
						|
						({8{rv64i_sw}} & 8'b1111 )
						|
						({8{rv64i_sd}} & 8'b11111111 )
						|
						8'b00000000;






	assign lsu_exeparam_ready = ~lsu_mstReq_valid & ~isLSU_busy_qout;







assign isLSU_busy_set =  lsu_mstReq_valid;
assign isLSU_busy_rst = (~lsu_mstReq_valid & lsu_slvRsp_valid) | flush;

assign lsu_wb_valid_set = (lsu_slvRsp_valid | ((rv64zi_fence_i | rv64i_fence) & lsu_exeparam_valid)) & ~flush;
assign lsu_wb_valid_rst = lsu_writeback_valid | flush;

gen_rsffr # (.DW(1)) isLSU_busy_rsffr (.set_in(isLSU_busy_set), .rst_in(isLSU_busy_rst), .qout(isLSU_busy_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffren # (.DW((5+`RB))) lsu_rd0 ( .dnxt(lsu_rd0_dnxt), .qout(lsu_rd0_qout), .en(lsu_wb_valid_set), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # (.DW(1)) lsu_wb_valid_rsffr ( .set_in(lsu_wb_valid_set), .rst_in(lsu_wb_valid_rst), .qout(lsu_writeback_valid), .CLK(CLK), .RSTn(RSTn));




endmodule














