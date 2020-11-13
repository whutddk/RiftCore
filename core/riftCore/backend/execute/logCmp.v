/*
* @File name: logCmp
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 14:45:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-13 16:06:56
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

module logCmp #
	(
		parameter DW = `LOGCMP_EXEPARAM_DW
	)(

	//from logCmp_issue
	input logCmp_exeparam_vaild,
	input [DW-1:0] logCmp_exeparam,

	output logCmp_writeback_vaild,
	output [63:0] logCmp_res_qout,
	output [(5+`RB-1):0] logCmp_rd0_qout,

	input flush,
	input CLK,
	input RSTn
);

	
	wire logCmp_fun_slt;
	wire logCmp_fun_xor;
	wire logCmp_fun_or;
	wire logCmp_fun_and;

	wire [(5+`RB-1):0] logCmp_rd0_dnxt;
	wire [63:0] op1;
	wire [63:0] op2;

	wire isUsi;

assign { 

			logCmp_fun_slt,
			logCmp_fun_xor,
			logCmp_fun_or,
			logCmp_fun_and,

			logCmp_rd0_dnxt,

			op1,
			op2,

			isUsi
		} = logCmp_exeparam;






wire [63:0] logCmp_logic_xor = op1 ^ op2;
wire [63:0] logCmp_logic_or  = op1 | op2;
wire [63:0] logCmp_logic_and = op1 & op2;

wire [63:0] slt_sign_res = ( $signed(op1) < $signed(op2) ) ? 64'd1 : 64'd0;
wire [63:0] slt_unsign_res = ( $unsigned(op1) < $unsigned(op2) ) ? 64'd1 : 64'd0;
wire [63:0] logCmp_slt_res = isUsi ? slt_unsign_res : slt_sign_res;


wire [63:0] logCmp_res_dnxt =   ( {64{logCmp_fun_slt}} & logCmp_slt_res )
						| ( {64{logCmp_fun_xor}} & logCmp_logic_xor )
						| ( {64{logCmp_fun_or}} & logCmp_logic_or )
						| ( {64{logCmp_fun_and}} & logCmp_logic_and );



gen_dffr # (.DW((5+`RB))) logCmp_rd0 ( .dnxt(logCmp_rd0_dnxt), .qout(logCmp_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) logCmp_res ( .dnxt(logCmp_res_dnxt), .qout(logCmp_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(logCmp_exeparam_vaild&(~flush)), .qout(logCmp_writeback_vaild), .CLK(CLK), .RSTn(RSTn));




endmodule








