/*
* @File name: ifu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:08:20
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


module ifu #
(
	parameter DW = 64
)
(

	output [63:0] M_IFU_ARADDR,
	output M_IFU_ARVALID,

	output M_IFU_RREADY,
	input M_IFU_RVALID,
	input [DW-1:0] M_IFU_RDATA,



	input [63:0] fetch_pc_dnxt,
	// output reg itcm_ready,
	input pcGen_fetch_valid,
	input instrFifo_full,
	output [DW-1:0] instr,
	output isInstrReadOut,
	output reg [63:0] fetch_pc_qout,

	input CLK,
	input RSTn

);


wire instr_update = ~instrFifo_full & M_IFU_RVALID;
assign M_IFU_ARVALID = pcGen_fetch_valid & ~instrFifo_full;
assign M_IFU_RREADY = instr_update;
assign M_IFU_ARADDR = fetch_pc_dnxt;


assign isInstrReadOut = M_IFU_RVALID;
assign instr = M_IFU_RDATA;



wire M_IFU_RVALID_F = 
	(M_IFU_ARVALID  & M_IFU_RREADY & 1'b1) //next comes and get old 
	| (M_IFU_ARVALID  & ~M_IFU_RREADY & 1'b1) // next comes and abort old
	| (~M_IFU_ARVALID  & M_IFU_RREADY & 1'b0) // just get old
	| (~M_IFU_ARVALID  & ~M_IFU_RREADY & M_IFU_RVALID); // wait


	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			// instr <= {DW{1'b0}};
			fetch_pc_qout <= 64'h80000000;
			// isInstrReadOut <= 1'b0;
		end
		else begin
			// instr <= #1 instr_update ? M_IFU_RDATA : instr;
			fetch_pc_qout <= #1 M_IFU_RVALID_F & ~instrFifo_full  ? fetch_pc_dnxt : fetch_pc_qout;
			// isInstrReadOut <= #1 instr_update ? pcGen_fetch_valid : isInstrReadOut;
		end 
	end





endmodule




