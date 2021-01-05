/*
* @File name: gen_sram
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 17:37:00
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:44:26
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



module gen_sram #
(
	parameter DW = 32,
	parameter AW = 14
)
(

	input [DW-1:0] data_w,
	output [DW-1:0] data_r,
	input [(DW+7)/8-1:0] data_wstrb,

	input wen,


	input [AW-1:0] addr,



	input CLK,
	input RSTn
	
);

	localparam DP = 2**AW;

	reg [DW-1:0] ram[0:DP-1];
	reg [DW-1:0] data_r_reg;

	wire [DW-1:0] data_wstrb_bit;
	wire [DW-1:0] data_wstrb_bitn;

	generate
		for ( genvar i = 0; i < DW; i = i + 1) begin
			assign data_wstrb_bit[i] = data_wstrb[i/8];
		end
	endgenerate
	
	assign data_wstrb_bitn = ~data_wstrb_bit;



	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			data_r_reg <= {DW{1'b0}};
		end
		else begin
			data_r_reg <= #1 ram[addr];

			if (wen) begin
				ram[addr] <= #1 ((ram[addr] & data_wstrb_bitn) | (data_w & data_wstrb_bit));
				data_r_reg <= #1 data_r_reg;
			end

		end 
	end

	assign data_r = data_r_reg;





endmodule












