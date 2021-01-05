/*
* @File name: dtcm
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:32:59
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:46:28
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

module dtcm #
(
	parameter DW = 128,
	parameter AW = 14
)
(

	input [AW-1:0] addr,
	input [DW-1:0] data_dnxt,
	input wen,
	input [(DW/8)-1:0] wmask,
	output reg [DW-1:0] data_qout,

	input CLK,
	input RSTn

);

	localparam DP = 2**AW;

	reg [DW-1:0] ram[0:DP-1];

	wire [DW-1:0] write_mask;
	wire [DW-1:0] clear_mask = ~write_mask;

initial $info("may rebuild with even odd memory");

	generate
		for ( genvar i = 0; i < DW/8 ; i = i + 1 ) begin
			assign write_mask[i*8 +: 8] = {8{wmask[i]}};
		end
	endgenerate



	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			data_qout <= {DW{1'b0}};
		end
		else begin
			if(wen) begin
				ram[addr] <= (ram[addr] & clear_mask) | (data_dnxt & write_mask);
			end else begin
				data_qout <= ram[addr];
			end
		end
	end

















endmodule

























