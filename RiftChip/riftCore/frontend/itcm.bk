/*
* @File name: itcm
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 09:46:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:08:18
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

module itcm #
	(
		parameter DW = 32,
		parameter AW = 14
	)
	(
	output itcm_ready,
	input pcGen_valid,
	input instrFifo_full,

	input [63:0] fetch_pc_dnxt,
	output [DW-1:0] instr_out,

	// input [DW-1:0] instr_in,
	// input wen,

	output reg instr_valid,
	output reg [63:0] fetch_pc_qout,

	input CLK,
	input RSTn
	
);
initial $warning("no debugger");

	localparam DP = 2**AW;

	wire [AW-1:0] addr = fetch_pc_dnxt[2 +: AW];

	reg [DW-1:0] ram[0:DP-1];
	reg [DW-1:0] instr;

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			instr <= {DW{1'b0}};
			fetch_pc_qout <= 64'h80000000;
			instr_valid <= 1'b0;
		end
		else begin
			// if(wen) begin
			// 	ram[addr] <= instr_in;
			// end else begin
			instr <= #1 instrFifo_full ? instr : ram[addr];
			fetch_pc_qout <= #1 instrFifo_full ? fetch_pc_qout : fetch_pc_dnxt;
			instr_valid <= #1 instrFifo_full ? instr_valid : pcGen_valid ;

			// end
		end 
	end

	assign instr_out = instr;
	assign itcm_ready = ~instrFifo_full;






endmodule








