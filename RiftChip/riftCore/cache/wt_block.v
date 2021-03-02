/*
* @File name: wt_block
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-03-02 14:32:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-02 15:49:57
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

module wt_block # 
(
	parameter DW = 64 + 8 + 32,
	parameter DP = 8
)
(
	input [31:0] chkAddr,
	output isAddrHazard,

	input push,
	input [DW-1:0] data_i,

	input pop,
	output [DW-1:0] data_o,

	output empty,
	output full,

	input CLK,
	input RSTn
);

wire [DP-1:0] addrHit;
wire [DW*DP-1:0] expose_o;
wire [DP-1:0] valid;


generate
	for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin
		assign addrHit = (chkAddr == expose_o[ DW*dp +: 32]) & valid[dp];
	end
endgenerate



assign isAddrHazard = (| addrHit);




gen_fifo # (.DW(DW), .AW($clog2(DP)) ) writeThrough_fifo
(

	.fifo_pop(pop), 
	.fifo_push(push),
	.data_push(data_i),

	.fifo_empty(empty), 
	.fifo_full(full), 
	.data_pop(data_o),

	.expose_o(expose_o),
	.valid(valid),

	.flush(1'b0),
	.CLK(CLK),
	.RSTn(RSTn)
);








endmodule



