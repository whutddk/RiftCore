/*
* @File name: jal
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 17:21:08
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 17:45:33
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

module jal #
	(
		parameter DW = `JAL_EXEPARAM_DW
	)(
	
	//from jal issue
	input jal_exeparam_vaild,
	input [DW-1:0] jal_exeparam, 


	// to branch predict
	output jalr_vaild_qout,
	output [63:0] jalr_pc_qout,

	// to writeback
	output jal_writeback_vaild,
	output [63:0] jal_res_qout,
	output [(5+`RB-1):0] jal_rd0_qout,

	input flush,
	input CLK,
	input RSTn

);

	wire rv64i_jal;
	wire rv64i_jalr;

	wire [(5+`RB-1):0] jal_rd0_dnxt;
	wire [63:0] pc;
	
	wire [63:0] src1;	

	wire is_rvc;

	assign { 
			rv64i_jal,
			rv64i_jalr,

			jal_rd0_dnxt,
			src1,
			pc,

			is_rvc
			} = jal_exeparam;


wire [63:0] jalr_pc_dnxt = pc + src1;

wire [63:0] jal_res_dnxt = {64{(rv64i_jal | rv64i_jalr)}} & ( pc + ( is_rvc ? 64'd2 : 64'd4 ) );

wire jalr_vaild_dnxt = rv64i_jalr & jal_exeparam_vaild;





gen_dffr # (.DW((5+`RB))) jal_rd0 ( .dnxt(jal_rd0_dnxt), .qout(jal_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) jal_res ( .dnxt(jal_res_dnxt), .qout(jal_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(jal_exeparam_vaild), .qout(jal_writeback_vaild), .CLK(CLK), .RSTn(RSTn));


initial $warning("jalr 已经发射，而pcGen理论上正在等待jalr的正确结果返回才能解出下一个pc，或者pop rsa");
initial $warning("发生前端冲刷获得jalr，需要挂起等待后端冲刷后的jalr返回信号");

gen_dffr # (.DW(1)) jalr_vaild ( .dnxt(jalr_vaild_dnxt), .qout(jalr_vaild_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) jalr_pc ( .dnxt(jalr_pc_dnxt&(~flush)), .qout(jalr_pc_qout), .CLK(CLK), .RSTn(RSTn));




endmodule






