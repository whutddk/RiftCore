/*
* @File name: L3cache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-19 10:11:07
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-19 11:37:02
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

module L3cache
(
	parameter DATA_WIDTH = 4096,
	// parameter CACHE_BLOCK = 1,
	parameter CACHE_LINE = 256
)
(

	//form L2cache





	//from DDR

	
);

	localparam ADDR_LSB = $clog2(DATA_WIDTH/8)
	localparam LINE_W = $clog2(CACHE_LINE);
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;
	localparam BANK = 4;
	localparam BANK_WIDTH = DATA_WIDTH / BANK;


wire [31:0] addr_req;


wire [$clog2(BANK)-1:0] bank_sel = addr_req[ ADDR_LSB-1 -:  $clog2(BANK)];
wire [LINE_W-1:0] address_sel = addr_req[ADDR_LSB +: LINE_W];
wire [TAG_W-1:0] tag_sel = addr_req[31 -: TAG_W];




wire tag_valid;
wire [ TAG_W - 1 : 0] tag_info;
wire isTagHit;
wire [ DATA_WIDTH - 1 : 0] data_hit;

wire [(TAG_W+8) / 8 -1 : 0] tag_data_wstrb;
wire [DATA_WIDTH/8-1] bank_data_wstrb;

wire [ BANK - 1 : 0 ] bank_en_w;
wire [ BANK - 1 : 0 ] bank_en_r;
wire tag_en_w;
wire tag_en_r;

wire [ DATA_WIDTH - 1 : 0 ] bank_data_w;
wire [ DATA_WIDTH - 1 : 0 ] bank_data_r;
wire [ (TAG_W+1) - 1 : 0 ] tag_data_w;
wire [ (TAG_W+1) - 1 : 0 ] tag_data_r;

wire [LINE_W-1:0] tag_addr_r;
wire [LINE_W-1:0] tag_addr_w;
wire [LINE_W-1:0] bank_addr_r;
wire [LINE_W-1:0] bank_addr_w;



	gen_sram # ( .DW((TAG_W+1)), .AW(LINE_W)) tag_ram
	(
		.data_w(tag_data_w),
		.addr_w(tag_addr_w),
		.data_wstrb(tag_data_wstrb),
		.en_w(tag_en_w),

		.data_r(tag_data_r),
		.addr_r(tag_addr_r),
		.en_r(tag_en_r),

		.CLK(CLK)		
	);





	for ( genvar j = 0; j < BANK; j = j + 1 ) begin
		gen_sram # ( .DW(BANK_WIDTH), .AW(LINE_W)) data_bank_ram
		(
			.data_w(bank_data_w[BANK_WIDTH*j +: BANK_WIDTH]),
			.addr_w(bank_addr_w),
			.data_wstrb(bank_data_wstrb[BANK_WIDTH/8 * j +: BANK_WIDTH/8]),
			.en_w(bank_en_w[j]),

			.data_r(bank_data_r[BANK_WIDTH*j +: BANK_WIDTH]),
			.addr_r(bank_addr_r),
			.en_r(bank_en_r[j]),

			.CLK(CLK)		
		);

	end








endmodule












