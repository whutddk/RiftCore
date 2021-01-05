/*
* @File name: gen_bypassfifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-05 14:33:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 19:16:22
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
	input [DW-1:0] data_i,
	output ready_i,

	output valid_o,
	output [DW-1:0] data_o,
	input ready_o,

	input flush,
	input CLK,
	input RSTn
);

wire fifo_empty;
wire fifo_full;
wire [DW-1:0] data_pop;




wire isLoad_set;
wire isLoad_rst;
wire isLoad_qout;

assign isLoad_set = valid_i & ~ready_o & ~fifo_full;
assign isLoad_rst = ~isLoad_set & (ready_o & ~fifo_empty);
assign fifo_empty = ~isLoad_qout;
assign fifo_full = isLoad_qout;
gen_dffren # ( .DW(DW)) fifo_bypass ( .dnxt(data_i), .qout(data_pop), .en(isLoad_set), .CLK(CLK), .RSTn(RSTn));
gen_rsffr # ( .DW(1) ) isLoad ( .set_in(isLoad_set), .rst_in(isLoad_rst), .qout(isLoad_qout), .CLK(CLK), .RSTn(RSTn));





assign data_o = fifo_empty ? data_i : data_pop;
assign ready_i = ~fifo_full;
assign valid_o = valid_i | ~fifo_empty; 













endmodule





