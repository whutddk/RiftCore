/*
* @File name: gen_bypassfifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-05 14:33:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:43:52
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

module gen_bypassfifo #
(
	parameter DW = 64,
	parameter AW = 0
)
(
	input valid_i,
	input data_i,
	output ready_i,

	output valid_o,
	output data_o,
	input ready_o,

	input flush,
	input CLK,
	input RSTn
);

wire fifo_empty;
wire fifo_full;
wire [DW-1:0] data_pop;




gen_fifo # ( .DW(DW), .AW(AW) ) fifo_bypass (

	.fifo_pop(ready_o & ~fifo_empty), 
	.fifo_push(valid_i & ~ready_o & ~fifo_full),
	.data_push(data_i),

	.fifo_empty(fifo_empty), 
	.fifo_full(fifo_full), 
	.data_pop(data_pop),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);

assign data_o = fifo_empty ? data_i : data_pop;
assign ready_i = ~fifo_full;
assign valid_o = valid_i | ~fifo_empty; 













endmodule





