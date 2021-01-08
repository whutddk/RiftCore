/*
* @File name: pcGenerate
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-13 16:56:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-08 18:07:20
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

module pcGenerate (

	input isReset,

	//from jalr exe
	input jalr_valid,
	input [63:0] jalr_pc,
	
	//from bru
	input bru_res_valid,
	input bru_takenBranch,

	// from expection 	
	input [63:0] privileged_pc,
	input privileged_valid,

	//to commit to flush
	output isMisPredict,

	//from instr_queue,
	input fetch_pc_valid,
	input [63:0] fetch_pc_queue,
	input [69:0] preDecode_info,

	//to ifetch
	output [63:0] fetch_addr_qout,
	output fetch_addr_valid,
	input pcGen_fetch_ready,


	input CLK,
	input RSTn

);



	wire isExpection = privileged_valid;
	wire [63:0] expection_pc = privileged_pc;


	wire isJal, isJalr, isBranch, isCall, isReturn,isRVC;
	wire [63:0] imm;

	assign { isJal, isJalr, isBranch, isCall, isReturn, isRVC, imm } = preDecode_info;

























endmodule










