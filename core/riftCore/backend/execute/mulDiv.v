/*
* @File name: mulDiv
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-22 10:50:16
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-23 14:37:49
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


module mulDiv (

);



	wire rv64m_mul, rv64m_mulh, rv64m_mullhsu, rv64m_mulhu, rv64m_div, rv64m_divu, rv64m_rem, rv64m_remu, rv64m_mulw, rv64m_divw, rv64m_divuw, rv64_remw, rv64m_remuw;

	wire [(5+`RB)-1:0] mulDiv_rs1;
	wire [(5+`RB)-1:0] mulDiv_rs2;
	wire [(5+`RB)-1:0] mulDiv_rd0_dnxt;


	assign {
			rv64m_mul,
			rv64m_mulh,
			rv64m_mullhsu,
			rv64m_mulhu,
			rv64m_div,
			rv64m_divu,
			rv64m_rem,
			rv64m_remu,
			rv64m_mulw,
			rv64m_divw,
			rv64m_divuw,
			rv64_remw,
			rv64m_remuw,

			mulDiv_rs1,
			mulDiv_rs2,
			mulDiv_rd0_dnxt

			} = alu_exeparam;


	wire [63:0] src1 = regFileX_read[ 64*mulDiv_rs1 +: 64];
	wire [63:0] src2 = regFileX_read[ 64*mulDiv_rs2 +: 64];

	initial $warning("only can syn in FPGA in this verison");

	wire signed [127:0] muls = $signed(src1) * $signed(src2);
	wire unsigned [127:0] mulu = $unsigned(src1) * $unsigned(src2);
	wire signed [127:0] mulsu = $signed(src1) * $unsigned(src2);





























	wire [63:0] mulDiv_res_dnxt = 
		( {64{rv64m_mul}} & muls[63:0] )
		| ({64{rv64m_mulh}} & muls[127:64] )
		| ({64{rv64m_mullhsu}} & mulsu[127:64] )
		| ({64{rv64m_mulhu}} & mulu[127:64] )
		| ({64{rv64m_div}} & )
		| ({64{rv64m_divu}} & )
		| ({64{rv64m_rem}} & )
		| ({64{rv64m_remu}} & )
		| ({64{rv64m_mulw}} & {{32{muls[31]}},muls[31:0]} )
		| ({64{rv64m_divw}} & )
		| ({64{rv64m_divuw}} & )
		| ({64{rv64_remw}} & )
		| ({64{rv64m_remuw}} & )

	gen_dffr # (.DW((5+`RB))) mulDiv_rd0 ( .dnxt(mulDiv_rd0_dnxt), .qout(mulDiv_rd0_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(64)) mulDiv_res ( .dnxt(mulDiv_res_dnxt), .qout(mulDiv_res_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) vaild ( .dnxt(mulDiv_exeparam_vaild&(~flush)), .qout(mulDiv_writeback_vaild), .CLK(CLK), .RSTn(RSTn));





endmodule
















