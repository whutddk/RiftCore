/*
* @File name: instr_fifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-06 11:11:59
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-06 11:15:59
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





module instr_fifo (
	parameter DW = 64,
	parameter AW = 3
) (

	input instrFifo_pop, 
	input instrFifo_push,
	input [DW-1:0] decode_microInstr_push,

	output instrFifo_empty, 
	output fifo_push_reject, 
	output [DW-1:0] (decode_microInstr_pop),

	input feflush,
	input CLK,
	input RSTn
);


gen_fifo # (.DW(`DECODE_INFO_DW),.AW(4)) 
	fifo (
	.fifo_pop(instrFifo_pop),
	.fifo_push(instrFifo_push),

	.data_push(decode_microInstr_push),
	.data_pop(decode_microInstr_pop),

	.fifo_empty(instrFifo_empty),
	.fifo_full(instrFifo_full),

	.flush(feflush),
	.CLK(CLK),
	.RSTn(RSTn)
);












endmodule








