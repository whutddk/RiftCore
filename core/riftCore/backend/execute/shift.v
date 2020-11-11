/*
* @File name: shift
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 16:10:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-11 16:16:23
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

module shift #
	(
		parameter DW = `SHIFT_EXEPARAM_DW
	)
	(
		input shift_exeparam_vaild,
		input [DW-1:0] shift_exeparam,

		output shift_writeback_vaild,
		output [63:0] shift_res_qout,
		output [(5+`RB-1):0] shift_rd0_qout,

		input flush,
		input CLK,
		input RSTn
);


	wire rv64i_sll;
	wire rv64i_srl;
	wire rv64i_sra;

	wire [(5+`RB-1):0] shift_rd0_dnxt;
	wire  [63:0] op1;
	wire  [63:0] op2;

	wire is32w;



assign { 	rv64i_sll,
			rv64i_srl,
			rv64i_sra,

			shift_rd0_dnxt,
			op1,
			op2,

			is32w
		} = shift_exeparam;



	//shift SLL SRL SRA

	wire [63:0] shiftLeft_op1 = op1;
	wire signed [64:0] shiftRigt_op1 = is32w ? { {33{(op1[31] & rv64i_sra)}}, op1[31:0]} 
												: { (op1[63] & rv64i_sra), op1 };

	wire [5:0] shamt = is32w ? {1'b0, op2[4:0]} : op2[5:0];

	wire [63:0] shift_left64 = shiftLeft_op1 << shamt;
	wire [63:0] shift_left32 = {{32{shift_left64[31]}},shift_left64[31:0]};

	wire [63:0] shift_left  = is32w ? shift_left32 : shift_left64;
	wire signed [63:0] shift_rigt = shiftRigt_op1 >>> shamt;


	wire [63:0] shift_res_dnxt =  ( {64{rv64i_sll}} & shift_left )
								| ( {64{rv64i_srl | rv64i_sra}} & shift_rigt );


gen_dffr # (.DW((5+`RB))) shift_rd0 ( .dnxt(shift_rd0_dnxt), .qout(shift_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) shift_res ( .dnxt(shift_res_dnxt), .qout(shift_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(shift_exeparam_vaild&(~flush)), .qout(shift_writeback_vaild), .CLK(CLK), .RSTn(RSTn));


endmodule




