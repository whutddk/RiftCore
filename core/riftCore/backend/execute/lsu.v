/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-11 22:22:50
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
		parameter LU_DW = `LU_EXEPARAM_DW,
		parameter SU_DW = `SU_EXEPARAM_DW,

		parameter AW = 8
	)
	(


	//read 可以乱序
	output lu_exeparam_ready,
	input lu_exeparam_vaild,
	input [LU_DW-1:0] lu_exeparam,


	//write 暂时只能顺序
	output su_exeparam_ready,
	input su_exeparam_vaild,
	input [SU_DW-1:0] su_exeparam,
	
	output lsu_writeback_vaild,
	output [63:0] lsu_res_qout,
	output [(5+`RB-1):0] lsu_rd0_qout,

	input flush,
	input CLK,
	input RSTn
);

initial $warning("定义load优先级高于store");
wire store_fun = su_exeparam_vaild & ~lu_exeparam_vaild;
wire load_fun = lu_exeparam_vaild;




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




	wire lu_fun_lb_dnxt;
	wire lu_fun_lh_dnxt;
	wire lu_fun_lw_dnxt;
	wire lu_fun_ld_dnxt;

	wire [(5+`RB-1):0] lu_rd0_dnxt;
	wire [63:0] lu_op1_dnxt;

	wire lu_isUsi_dnxt;

	assign { 
			lu_fun_lb_dnxt,
			lu_fun_lh_dnxt,
			lu_fun_lw_dnxt,
			lu_fun_ld_dnxt,
			lu_rd0_dnxt,
			lu_op1_dnxt,
			lu_isUsi_dnxt
			} = lu_exeparam;

	wire lu_fun_lb_qout;
	wire lu_fun_lh_qout;
	wire lu_fun_lw_qout;
	wire lu_fun_ld_qout;
	wire [(5+`RB-1):0] lu_rd0_qout;
	wire [63:0] lu_op1_qout;
	wire lu_isUsi_qout;

	assign { 
			lu_fun_lb_qout,
			lu_fun_lh_qout,
			lu_fun_lw_qout,
			lu_fun_ld_qout,

			lu_rd0_qout,
			lu_op1_qout,

			lu_isUsi_qout

			} = lu_exeparam_syn_qout;


wire [2:0] luAddr_align_qout = lu_op1_qout[2:0];

wire [7:0] loadB_align = data_qout[ luAddr_align_qout*8 +: 8 ];
wire [15:0] loadH_align = data_qout[ luAddr_align_qout*8 +: 16 ];
wire [31:0] loadW_align = data_qout[ luAddr_align_qout*8 +: 32 ];
wire [63:0] loadD_align = data_qout[ luAddr_align_qout*8 +: 64 ];

	assign lsu_res_qout = 
			({64{lu_fun_lb_qout}} & ( lu_isUsi_qout ? {56'b0,loadB_align} : {{56{loadB_align[7]}},loadB_align} ))
			|
			({64{lu_fun_lh_qout}} & ( lu_isUsi_qout ? {48'b0,loadH_align} : {{48{loadH_align[15]}},loadH_align} ))
			|
			({64{lu_fun_lw_qout}} & ( lu_isUsi_qout ? {32'b0,loadW_align} : {{32{loadW_align[31]}},loadW_align} ))
			|
			({64{lu_fun_ld_qout}} & loadD_align);


wire [63:0] lu_addrA_Raw = lu_op1_dnxt[3] ? lu_op1_dnxt + 64'b1000 : lu_op1_dnxt;
wire [63:0] lu_addrB_Raw = lu_op1_dnxt[3] ? lu_op1_dnxt : lu_op1_dnxt | 64'b1000;
wire [127:0] data_qout = lu_op1_qout[3] ? { data_qout_A, data_qout_B} : { data_qout_B, data_qout_A};


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



	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;

	wire [(5+`RB-1):0] su_rd0;
	wire [63:0] su_op1;
	wire [63:0] su_op2;



	assign { 
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,

			su_rd0,
			su_op1,
			su_op2
			} = su_exeparam;



wire [63:0] su_addrA_Raw = su_op1[3] ? su_op1 + 64'b1000 : su_op1;
wire [63:0] su_addrB_Raw = su_op1[3] ? su_op1 : su_op1 | 64'b1000;

wire [2:0] su_addr_align = su_op1[2:0];

wire [63:0] data_dnxt_A;
wire [63:0] data_dnxt_B;

wire wen_A = store_fun;
wire wen_B = store_fun;

wire [7:0] wmask_A;
wire [7:0] wmask_B;

wire [63:0] data_qout_A;
wire [63:0] data_qout_B;


wire [15:0] mask = ({16{rv64i_sb}} & ( 16'b1 << su_addr_align ))
					|
					({16{rv64i_sh}} & ( 16'b11 << su_addr_align ))
					|
					({16{rv64i_sw}} & ( 16'b1111 << su_addr_align ))
					|
					({16{rv64i_sd}} & ( 16'b11111111 << su_addr_align ));


assign { wmask_B, wmask_A } = su_op1[3] ? {mask[7:0],mask[15:8]} :mask;

wire [127:0] data_dnxt = su_op2 << {su_addr_align,3'b0};
assign {data_dnxt_B, data_dnxt_A} = su_op1[3] ? {data_dnxt[63:0],data_dnxt[127:64]} : data_dnxt;


wire [AW-1:0] addr_A = ({AW{load_fun}} & lu_addrA_Raw[4 +:AW])
					|
					({AW{store_fun}} &  su_addrA_Raw[4+:AW])
					;
wire [AW-1:0] addr_B = ({AW{load_fun}} & lu_addrB_Raw[4 +:AW])
					|
					({AW{store_fun}} &  su_addrB_Raw[4 +:AW])
					;



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




	initial $warning("直接握手前提是单拍出结果");
	wire memory_ready = 1'b1;

	initial $info("定义load优先级高于store");
	assign lu_exeparam_ready = memory_ready;
	assign su_exeparam_ready = memory_ready & ~lu_exeparam_vaild;


	wire lsu_writeback_vaild_dnxt = (lu_exeparam_vaild & lu_exeparam_ready)
									| (su_exeparam_vaild & su_exeparam_ready);



	wire [(5+`RB)-1 : 0] lsu_rd0_dnxt = ({(5+`RB){load_fun}} & lu_rd0_dnxt)
										|
										({(5+`RB){store_fun}} & su_rd0);



wire [LU_DW-1:0] lu_exeparam_syn_dnxt = lu_exeparam;
wire [LU_DW-1:0] lu_exeparam_syn_qout;

gen_dffr # (.DW(LU_DW)) lu_exeparam_syn ( .dnxt(lu_exeparam_syn_dnxt), .qout(lu_exeparam_syn_qout), .CLK(CLK), .RSTn(RSTn));

gen_dffr # (.DW((5+`RB))) lsu_rd0 ( .dnxt(lsu_rd0_dnxt), .qout(lsu_rd0_qout), .CLK(CLK), .RSTn(RSTn));
// gen_dffr # (.DW(64)) lsu_res ( .dnxt(lsu_res_dnxt), .qout(lsu_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) lsu_vaild ( .dnxt(lsu_writeback_vaild_dnxt&(~flush)), .qout(lsu_writeback_vaild), .CLK(CLK), .RSTn(RSTn));




endmodule














