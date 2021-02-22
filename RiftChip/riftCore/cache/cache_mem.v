/*
* @File name: cache_mem
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-22 10:00:20
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-22 10:29:01
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


module cache_mem #
(
	parameter DW = 1024,
	parameter BK = 4,
	parameter CB = 1,
	parameter CL = 256,



)
(
	input [31:0] cache_addr,

	output [DW-1:0] cache_data_r,
	output [CL*CB-1:0] cache_valid,
	input [DW-1:0] cache_data_w,
	input [7:0] cache_data_wstrb,

	input cache_en_w,
	input cache_en_r,
	input cache_evict,

	output isCacheMiss
);



	localparam ADDR_LSB = $clog2(DW*BK/8);
	localparam LINE_W = $clog2(CL);
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;





wire [$clog2(BK)-1:0] bank_sel = cache_addr[ ADDR_LSB-1 -: $clog2(BK)];
wire [LINE_W-1:0] address_sel = cache_addr[ADDR_LSB +: LINE_W];
wire [TAG_W-1:0] tag_sel = cache_addr[31 -: TAG_W];




wire [CL*CB-1:0] cache_valid_dnxt;
wire [CL*CB-1:0] cache_valid_qout;
wire [CL*CB-1:0] cache_valid_en;

wire [ TAG_W - 1 : 0] tag_w;
wire [ TAG_W - 1 : 0] tag_r;



wire [(TAG_W+7)/8-1 : 0] tag_data_wstrb;
wire [DW*BK/8-1:0] bank_data_wstrb;

wire [ BK - 1 : 0 ] bank_en_w;
wire [ BK - 1 : 0 ] bank_en_r;
wire tag_en_w;
wire tag_en_r;

wire [ DW*BK - 1 : 0 ] bank_data_w;
wire [ DW*BK - 1 : 0 ] bank_data_r;
wire [ TAG_W - 1 : 0 ] tag_data_w;
wire [ TAG_W - 1 : 0 ] tag_data_r;

wire [LINE_W-1:0] tag_addr_r;
wire [LINE_W-1:0] tag_addr_w;
wire [LINE_W-1:0] bank_addr_r;
wire [LINE_W-1:0] bank_addr_w;

wire isTagHit;
wire [ DW - 1 : 0] data_hit;
generate
	
	for ( genvar i = 0; i < CL; i = i + 1 )begin
		gen_dffren #(.DW(1)) cache_valid_dffren (.dnxt(cache_valid_dnxt), .qout(cache_valid_qout), .en(cache_valid_en), .CLK(CLK), .RSTn(RSTn));


	end


	gen_sram # ( .DW((TAG_W)), .AW(LINE_W)) tag_ram
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

endgenerate


assign tag_data_w = {tag_valid_w, tag_info_w};
assign tag_data_wstrb = {(TAG_W+1){1'b1}};
assign {tag_valid_r, tag_info_r} = tag_data_r;














endmodule













