/*
* @File name: gen_fifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-30 17:55:22
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:05:55
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


module gen_fifo # (
	parameter DW = 64,
	parameter AW = 3
) (

	input fifo_pop, 
	input fifo_push,
	input [DW-1:0] data_push,

	output fifo_empty, 
	output fifo_full, 
	output [DW-1:0] data_pop,

	input flush,
	input CLK,
	input RSTn
);

	localparam DP = 2**AW;


	wire [AW+1-1:0] read_addr_dnxt, read_addr_qout;
	wire [AW+1-1:0] write_addr_dnxt, write_addr_qout;
	wire [DP*DW-1:0] fifo_data_dnxt,fifo_data_qout;

	gen_dffr # (.DW(AW+1)) read_addr (.dnxt(read_addr_dnxt), .qout(read_addr_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(AW+1)) write_addr (.dnxt(write_addr_dnxt), .qout(write_addr_qout), .CLK(CLK), .RSTn(RSTn));

	assign fifo_empty = (read_addr_qout == write_addr_qout);
	assign fifo_full = (read_addr_qout[AW-1:0] == write_addr_qout[AW-1:0]) & (read_addr_qout[AW] != write_addr_qout[AW]);


generate
	for ( genvar i = 0; i < DP; i = i + 1 ) begin
		assign fifo_data_dnxt[DW*i+:DW] = (fifo_push & ~fifo_full & (write_addr_qout[AW-1:0] == i) ) ? data_push : fifo_data_qout[DW*i+:DW];


		gen_dffr # (.DW(DW)) fifo_data (.dnxt(fifo_data_dnxt[DW*i+:DW]), .qout(fifo_data_qout[DW*i+:DW]), .CLK(CLK), .RSTn(RSTn));

	end




endgenerate




	assign data_pop = fifo_data_qout[DW*read_addr_qout[AW-1:0]+:DW];

	assign read_addr_dnxt = flush ? ({(AW+1){1'b1}}) : (( fifo_pop & ~fifo_empty ) ? read_addr_qout + 'd1 : read_addr_qout);
	assign write_addr_dnxt = flush ? ({(AW+1){1'b1}}) : (( fifo_push & ~fifo_full ) ? write_addr_qout + 'd1 :  write_addr_qout);


endmodule 



