/*
* @File name: decoder
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:28:05
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 11:29:51
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
	input queue_decode_valid,
	output queue_decode_ready,

	input [31:0] queue_decode_instr,
	input [63:0] queue_decode_pc,
	input queue_decode_isRVC,

	input instrFifo_full,
	output [`DECODE_INFO_DW-1:0] decode_microInstr,
	output instrFifo_push

);

	assign queue_decode_ready = ~instrFifo_full;


wire [`DECODE_INFO_DW-1:0] decode_microInstr_16;
wire [`DECODE_INFO_DW-1:0] decode_microInstr_32;

decoder16 i_decoder16
(
	.instr(queue_decode_instr[15:0]),
	.pc(queue_decode_pc),
	.is_rvc(queue_decode_isRVC),

	.decode_microInstr(decode_microInstr_16)
);



decoder32 i_decoder32
(
	.instr(queue_decode_instr),
	.pc(queue_decode_pc),
	.is_rvc(queue_decode_isRVC),

	.decode_microInstr(decode_microInstr_32)
);


	assign decode_microInstr = queue_decode_isRVC ? decode_microInstr_16 : decode_microInstr_32;

	assign instrFifo_push = queue_decode_valid & ~instrFifo_full;



endmodule








