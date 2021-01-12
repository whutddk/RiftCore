/*
* @File name: decoder
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:28:05
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-12 11:13:25
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



module decoder
(
	input iq_id_valid,
	output iq_id_ready,
	input [32+64+1-1:0] iq_id_info,

	input instrFifo_full,
	output [`DECODE_INFO_DW-1:0] decode_microInstr,
	output instrFifo_push

);

	assign iq_id_ready = ~instrFifo_full;

	wire [63:0] id_pc = iq_id_info[64:1];
	wire [31:0] id_instr32 = iq_id_info[96:65];
	wire [15:0] id_instr16 = iq_id_info[80:65];
	wire isRVC = iq_id_info[0];



	wire [`DECODE_INFO_DW-1:0] decode_microInstr_16;
	wire [`DECODE_INFO_DW-1:0] decode_microInstr_32;

decoder16 i_decoder16
(
	.instr(id_instr16),
	.pc(id_pc),
	.is_rvc(isRVC),

	.decode_microInstr(decode_microInstr_16)
);



decoder32 i_decoder32
(
	.instr(id_instr32),
	.pc(id_pc),
	.is_rvc(isRVC),

	.decode_microInstr(decode_microInstr_32)
);


	assign decode_microInstr = iq_id_info[0] ? decode_microInstr_16 : decode_microInstr_32;

	assign instrFifo_push = iq_id_valid & ~instrFifo_full;



endmodule








