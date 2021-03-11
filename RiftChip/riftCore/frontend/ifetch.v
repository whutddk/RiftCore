/*
* @File name: ifetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-10 12:13:13
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


module ifetch (

	output ifu_req_valid,
	output [31:0] ifu_addr_req,
	input [63:0] ifu_data_rsp,
	input ifu_rsp_valid,
	output icache_trans_kill,

	//from pcGen
	input [63:0] pc_if_addr,
	output pc_if_ready,

	//to iqueue
	output [63:0] if_iq_pc,
	output [63:0] if_iq_instr,
	output if_iq_valid,
	input if_iq_ready,

	input flush,
	input CLK,
	input RSTn

);



	assign ifu_addr_req = pc_if_addr[31:0] & (~32'b111);

	assign ifu_req_valid = if_iq_ready & ~flush;
	assign pc_if_ready = if_iq_valid;
	assign if_iq_valid = ifu_rsp_valid & ~flush;

	assign if_iq_pc = pc_if_addr;
	assign if_iq_instr = ifu_data_rsp;
	assign icache_trans_kill = flush;







	// assign ifu_addr_req = 32'b0;

	// assign ifu_req_valid = 1'b1;
	// assign pc_if_ready = if_iq_valid;
	// assign if_iq_valid = if_iq_ready;

	// assign if_iq_pc = pc_if_addr;
	// assign if_iq_instr = pc_if_addr;
	// assign icache_trans_kill = 1'b0;











endmodule




