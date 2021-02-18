/*
* @File name: L2cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-18 14:26:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-18 19:06:38
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



module L2cache 
(

	//L1 I Cache
	input [31:0] L1C_ARADDR,
	input [2:0] L1C_ARPROT,
	input L1C_ARVALID,
	output L1C_ARREADY,
	output [255:0] L1C_RDATA,
	output L1C_RVALID,
	input L1C_RREADY,

);


wire [31:0] addr_req = IFU_ARADDR;


wire [1:0] bank_sel = addr_req[6:5];
wire [13:0] address_sel = addr_req[20:7];
wire [10:0] tag_sel = addr_req[31:21];





wire [1024*8-1:0 ] cache_data_out;
wire [12*8-1:0] cache_tag_out;
wire [7:0] tag_valid;
wire [11*8-1:0] tag_info;
wire [7:0] tag_hit;
wire [1023:0] data_hit;

wire [8*4-1:0] data_w_en;
wire [7:0] tag_w_en;
wire [1024*8-1:0] data_w;
wire [12*8-1:0] tag_w;

wire [13:0] tag_rd_addr;
wire [13:0] tag_wr_addr;
wire [13:0] bank_rd_addr;
wire [13:0] bank_wr_addr;

generate
	for ( genvar i = 0; i < 8; i = i + 1 ) begin
		gen_sram # ( .DW(12), .AW(14)) tag_ram
		(
			.data_w(),
			.addr_w(tag_wr_addr),
			.data_wstrb(2'b11),
			.en_w(tag_w_en[i]),

			.data_r(),
			.addr_r(tag_rd_addr),
			.en_r(),

			.CLK(CLK)		
		);


		for ( genvar j = 0; j < 4; j = j + 1 ) begin
			gen_sram # ( .DW(256), .AW(14)) data_bank_ram
			(
				.data_w(),
				.addr_w(oprd_addr),
				.data_wstrb({32{1'b1}}),
				.en_w(data_w_en[i*4+j]),

				.data_r(data_rd_addr),
				.addr_r(),
				.en_r(),

				.CLK(CLK)		
			);

		end





	end
endgenerate










endmodule





