/*
* @File name: inner_itcm
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 09:46:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-09 23:58:43
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

module inner_itcm #
(
	parameter DW = 32,
	parameter AW = 14
)
(

	input [63:0] M_IFU_ARADDR,
	input M_IFU_ARVALID,

	input M_IFU_RREADY,
	output M_IFU_RVALID,
	output reg [DW-1:0] M_IFU_RDATA,


	input CLK,
	input RSTn
	
);

	localparam DP = 2**AW;
	reg [DW-1:0] ram[0:DP-1];
	wire [AW-1:0] addr = M_IFU_ARADDR[2 +: AW];

always @(posedge CLK or negedge RSTn) begin
	if( ~RSTn ) begin
		M_IFU_RDATA <= {DW{1'b0}};
	end
	else begin
		if ( M_IFU_ARVALID ) begin
			M_IFU_RDATA <= ram[addr];
		end
		else begin
			M_IFU_RDATA <= M_IFU_RDATA;
		end

	end
end



wire handshake_dnxt;
wire handshake_qout;

assign M_IFU_RVALID = handshake_qout;
assign handshake_dnxt = 
	(M_IFU_ARVALID  & M_IFU_RREADY & 1'b1) //next comes and get old 
	| (M_IFU_ARVALID  & ~M_IFU_RREADY & 1'b1) // next comes and abort old
	| (~M_IFU_ARVALID  & M_IFU_RREADY & 1'b0) // just get old
	| (~M_IFU_ARVALID  & ~M_IFU_RREADY & handshake_qout); // wait


gen_dffr # (.DW(1)) handshake ( .dnxt(handshake_dnxt), .qout(handshake_qout), .CLK(CLK), .RSTn(RSTn));






endmodule








