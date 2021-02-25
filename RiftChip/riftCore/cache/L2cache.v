/*
* @File name: L2cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-18 14:26:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-19 11:20:46
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
	parameter DATA_WIDTH = 1024,
	parameter CACHE_BLOCK = 4,
	parameter CACHE_LINE = 32
)
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

	localparam ADDR_LSB = $clog2(DATA_WIDTH/8)
	localparam LINE_W = $clog2(CACHE_LINE);
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;
	localparam BANK = 4;










wire [31:0] addr_req = IFU_ARADDR;


wire [1:0] bank_sel = addr_req[6:5];
wire [13:0] address_sel = addr_req[20:7];
wire [10:0] tag_sel = addr_req[31:21];





wire [ DATA_WIDTH * CACHE_BLOCK - 1:0 ] cache_data_out;
wire [ (TAG_W+1) * CACHE_BLOCK - 1:0] cache_tag_out;
wire [ CACHE_BLOCK - 1 : 0] tag_valid;
wire [ TAG_W * CACHE_BLOCK - 1 : 0] tag_info;
wire [ CACHE_BLOCK - 1 : 0] isTagHit;
wire [  DATA_WIDTH - 1 : 0] data_hit;

wire [ CACHE_BLOCK * BANK - 1 : 0 ] data_w_en;
wire [ CACHE_BLOCK - 1 : 0 ] tag_w_en;
wire [ CACHE_BLOCK * BANK - 1 : 0 ] data_r_en;
wire [ CACHE_BLOCK - 1 : 0 ] tag_r_en;
wire [ DATA_WIDTH * CACHE_BLOCK - 1 : 0 ] data_w;
wire [ (TAG_W+1) * CACHE_BLOCK - 1 : 0 ] tag_w;

wire [LINE_W-1:0] tag_rd_addr;
wire [LINE_W-1:0] tag_wr_addr;
wire [LINE_W-1:0] bank_rd_addr;
wire [LINE_W-1:0] bank_wr_addr;

generate
	for ( genvar i = 0; i < CACHE_BLOCK; i = i + 1 ) begin
		gen_sram # ( .DW(TAG_W+1), .AW(LINE_W)) tag_ram
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


		for ( genvar j = 0; j < BANK; j = j + 1 ) begin
			gen_sram # ( .DW(DATA_WIDTH/BANK), .AW(LINE_W)) data_bank_ram
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





