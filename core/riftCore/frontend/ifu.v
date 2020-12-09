/*
* @File name: ifu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-09 20:05:10
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

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


module ifu #
(
	parameter DW = 32
)
(

	output [63:0] M_IFU_ARADDR,
	output M_IFU_ARVALID,

	output M_IFU_RREADY,
	input M_IFU_RVALID,
	input [DW-1:0] M_IFU_RDATA,



	input [63:0] fetch_pc_dnxt,
	output reg itcm_ready,
	input pcGen_fetch_vaild,
	input instrFifo_full,
	output reg [DW-1:0] instr,
	output isInstrReadOut,
	output reg [63:0] fetch_pc_qout,

	input CLK,
	input RSTn

);


wire instr_update = ~instrFifo_full & M_IFU_RVALID;
assign M_IFU_ARVALID = pcGen_fetch_vaild;
assign M_IFU_RREADY = instr_update;

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			instr <= {DW{1'b0}};
			fetch_pc_qout <= 64'h80000000;
			itcm_ready <= 1'b0;
		end
		else begin
			instr <= #1 instr_update ? M_IFU_RDATA : instr;
			fetch_pc_qout <= #1 instr_update ? fetch_pc_dnxt : fetch_pc_qout;
			itcm_ready <= #1 instr_update ? pcGen_fetch_vaild : itcm_ready;
		end 
	end





endmodule




