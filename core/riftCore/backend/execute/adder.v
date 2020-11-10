/*
* @File name: adder
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:16:34
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 17:45:45
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

module adder #
	(
		parameter DW = `ADDER_EXEPARAM_DW 
	)
	(

	input adder_exeparam_vaild,
	input [DW-1:0] adder_exeparam,

	output adder_writeback_vaild,
	output [63:0] adder_res_qout,
	output [(5+`RB)-1:0] adder_rd0_qout,

	input flush,
	input CLK,
	input RSTn
	
);


	wire rv64i_add;
	wire rv64i_sub;

	wire [(5+`RB)-1:0] adder_rd0_dnxt;

	wire  [63:0] op1;
	wire  [63:0] op2;

	wire is32w;


assign { 
			rv64i_add,
			rv64i_sub,

			adder_rd0_dnxt,
			op1,
			op2,

			is32w
		} = adder_exeparam;



wire [63:0] adder_op1 = op1;
wire [63:0] adder_op2 = rv64i_sub ? ((~op2) + 64'd1) : op2;

wire [63:0] adder_cal = $unsigned(adder_op1) + $unsigned(adder_op2);
wire [63:0] adder_res_dnxt = is32w ? {{32{adder_cal[31]}}, adder_cal[31:0]} : adder_cal;



gen_dffr # (.DW((5+`RB))) adder_rd0 ( .dnxt(adder_rd0_dnxt), .qout(adder_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) adder_res ( .dnxt(adder_res_dnxt), .qout(adder_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(adder_exeparam_vaild&(~flush)), .qout(adder_writeback_vaild), .CLK(CLK), .RSTn(RSTn));




endmodule



