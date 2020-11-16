/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-13 17:50:25
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

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
		parameter DW = `LSU_EXEPARAM_DW,

		parameter AW = 4
	)
	(


	//can only execute in order right now
	output lsu_exeparam_ready,
	input lsu_exeparam_vaild,
	input [DW-1:0] lsu_exeparam,
	
	output lsu_writeback_vaild,
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

	wire [2:0] lAddr_align;
	wire odd;

	gen_dffr # (.DW(1)) isUsiHold ( .dnxt(rv64i_lbu | rv64i_lhu | rv64i_lwu), .qout(isUsi), .CLK(CLK), .RSTn(RSTn));
	
	gen_dffr # (.DW(1)) islb ( .dnxt(rv64i_lb | rv64i_lbu), .qout(lsu_fun_lb), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) islh ( .dnxt(rv64i_lh | rv64i_lhu), .qout(lsu_fun_lh), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) islw ( .dnxt(rv64i_lw | rv64i_lwu), .qout(lsu_fun_lw), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) isld ( .dnxt(rv64i_ld), .qout(lsu_fun_ld), .CLK(CLK), .RSTn(RSTn));

	gen_dffr # (.DW(3)) lAddrAlignHold ( .dnxt(lsu_op1[2:0]), .qout(lAddr_align), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) isOdd ( .dnxt(lsu_op1[3]), .qout(odd), .CLK(CLK), .RSTn(RSTn));











// LLLLLLLLLLL            UUUUUUUU     UUUUUUUU
// L:::::::::L            U::::::U     U::::::U
// L:::::::::L            U::::::U     U::::::U
// LL:::::::LL            UU:::::U     U:::::UU
//   L:::::L               U:::::U     U:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L         LLLLLLU::::::U   U::::::U 
// LL:::::::LLLLLLLLL:::::LU:::::::UUU:::::::U 
// L::::::::::::::::::::::L UU:::::::::::::UU  
// L::::::::::::::::::::::L   UU:::::::::UU    
// LLLLLLLLLLLLLLLLLLLLLLLL     UUUUUUUUU   









wire [7:0] loadB_align = data_qout[ lAddr_align*8 +: 8 ];
wire [15:0] loadH_align = data_qout[ lAddr_align*8 +: 16 ];
wire [31:0] loadW_align = data_qout[ lAddr_align*8 +: 32 ];
wire [63:0] loadD_align = data_qout[ lAddr_align*8 +: 64 ];

	assign lsu_res_qout = 
			({64{lsu_fun_lb}} & ( isUsi ? {56'b0,loadB_align} : {{56{loadB_align[7]}},loadB_align} ))
			|
			({64{lsu_fun_lh}} & ( isUsi ? {48'b0,loadH_align} : {{48{loadH_align[15]}},loadH_align} ))
			|
			({64{lsu_fun_lw}} & ( isUsi ? {32'b0,loadW_align} : {{32{loadW_align[31]}},loadW_align} ))
			|
			({64{lsu_fun_ld}} & loadD_align);



wire [127:0] data_qout = odd ? { data_qout_A, data_qout_B} : { data_qout_B, data_qout_A};


//    SSSSSSSSSSSSSSS UUUUUUUU     UUUUUUUU
//  SS:::::::::::::::SU::::::U     U::::::U
// S:::::SSSSSS::::::SU::::::U     U::::::U
// S:::::S     SSSSSSSUU:::::U     U:::::UU
// S:::::S             U:::::U     U:::::U 
// S:::::S             U:::::D     D:::::U 
//  S::::SSSS          U:::::D     D:::::U 
//   SS::::::SSSSS     U:::::D     D:::::U 
//     SSS::::::::SS   U:::::D     D:::::U 
//        SSSSSS::::S  U:::::D     D:::::U 
//             S:::::S U:::::D     D:::::U 
//             S:::::S U::::::U   U::::::U 
// SSSSSSS     S:::::S U:::::::UUU:::::::U 
// S::::::SSSSSS:::::S  UU:::::::::::::UU  
// S:::::::::::::::SS     UU:::::::::UU    
//  SSSSSSSSSSSSSSS         UUUUUUUUU      




wire [63:0] lsu_addrA_Raw = lsu_op1[3] ? lsu_op1 + 64'b1000 : lsu_op1;
wire [63:0] lsu_addrB_Raw = lsu_op1[3] ? lsu_op1 : lsu_op1 | 64'b1000;


wire [2:0] sAddr_align = lsu_op1[2:0];

wire [63:0] data_dnxt_A;
wire [63:0] data_dnxt_B;

wire wen_A = rv64i_sb | rv64i_sh | rv64i_sw | rv64i_sd;
wire wen_B = wen_A;

wire [7:0] wmask_A;
wire [7:0] wmask_B;

wire [63:0] data_qout_A;
wire [63:0] data_qout_B;


wire [15:0] mask = ({16{rv64i_sb}} & ( 16'b1 << sAddr_align ))
					|
					({16{rv64i_sh}} & ( 16'b11 << sAddr_align ))
					|
					({16{rv64i_sw}} & ( 16'b1111 << sAddr_align ))
					|
					({16{rv64i_sd}} & ( 16'b11111111 << sAddr_align ));


assign { wmask_B, wmask_A } = lsu_op1[3] ? {mask[7:0],mask[15:8]} : mask;

wire [127:0] data_dnxt = lsu_op2 << {sAddr_align,3'b0};
assign {data_dnxt_B, data_dnxt_A} = lsu_op1[3] ? {data_dnxt[63:0],data_dnxt[127:64]} : data_dnxt;


wire [AW-1:0] addr_A = lsu_addrA_Raw[4 +:AW];
wire [AW-1:0] addr_B = lsu_addrB_Raw[4 +:AW];



dtcm #(.DW(64), .AW(AW)) 
i_dtcm_A
(
	.addr(addr_A),
	.data_dnxt(data_dnxt_A),
	.wen(wen_A),
	.wmask(wmask_A),
	.data_qout(data_qout_A),

	.CLK(CLK),
	.RSTn(RSTn)

);


dtcm #( .DW(64), .AW(AW))
i_dtcm_B
(
	.addr(addr_B),
	.data_dnxt(data_dnxt_B),
	.wen(wen_B),
	.wmask(wmask_B),
	.data_qout(data_qout_B),

	.CLK(CLK),
	.RSTn(RSTn)

);




	initial $warning("only in dccm");
	wire memory_ready = 1'b1;

	assign lsu_exeparam_ready = memory_ready;



	wire lsu_writeback_vaild_dnxt = (lsu_exeparam_vaild & lsu_exeparam_ready);





gen_dffr # (.DW((5+`RB))) lsu_rd0 ( .dnxt(lsu_rd0_dnxt), .qout(lsu_rd0_qout), .CLK(CLK), .RSTn(RSTn));
// gen_dffr # (.DW(64)) lsu_res ( .dnxt(lsu_res_dnxt), .qout(lsu_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) lsu_vaild ( .dnxt(lsu_writeback_vaild_dnxt&(~flush)), .qout(lsu_writeback_vaild), .CLK(CLK), .RSTn(RSTn));




endmodule














