/*
* @File name: dirty_block
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-22 17:33:10
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-22 18:00:09
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



module dirty_block # 
(
	parameter AW = 32,
	parameter DP = 16 
)
(
	input pop,
	input push,

	input [AW-1:0] addr_i,	
	output [AW-1:0] addr_o,

	output empty,
	output full,

	input CLK,
	input RSTn
);

localparam CW = $clog2(DP);


wire [CW-1:0] index;
wire [CW-1:0] index_push;
wire [CW-1:0] index_pop;
wire [AW*DP-1:0] info_o;

wire [DP - 1 : 0] valid;


gen_ppbuff # ( .DW(AW), .DP(DP) )
dirty_index
(
	.pop(pop),
	.push(push),
	.index(index),

	.info_i(addr_i),	
	.info_o(info_o),

	.empty(empty),
	.full(full),
	.valid(valid),
	
	.flush(1'b0),
	.CLK(CLK),
	.RSTn(RSTn)
	
);


assign index = 	
		(CW{push & ~pop}} & index_push)
		|
		(CW{pop & ~push}} & index_pop)
		|
		(CW{pop & push}} & index_pop);


assign addr_o = info_o[ 32*index_pop +: 32];


lzp #( .CW(CW) ) buff_push
(
	.in_i(valid),
	.pos_o(index_push),
	.all0(),
	.all1()
);


lzp #( .CW($clog2(DP)) ) buff_pop
(
	.in_i(~valid),
	.pos_o(index_pop),
	.all0(),
	.all1()
);




endmodule


