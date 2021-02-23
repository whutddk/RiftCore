/*
* @File name: L3Cache_mem
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-23 09:28:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-23 11:54:31
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



module L3Cache_mem (
	input [31:0] cache_addr,
	input cache_en_w,
	input cache_en_r,
	input [7:0] cache_info_wstrb,
	input [63:0] cache_info_w,
	output [63:0] cache_info_r,


	input [31:0] tag_addr,
	input tag_en_w,
	input tag_en_r,

	output cache_miss,
	output cache_hit,
	output [DB-1:0] cache_dirty,

	input CLK,
	input RSTn
	
);




	wire [CB-1:0] cache_block_en_w;
	wire [CB-1:0] cache_block_en_r;
	wire [63:0] cache_info_w;
	wire [64*CB-1:0] cache_block_info_r;
	wire [CB-1:0] tag_block_en_w;
	wire [CB-1:0] tag_block_en_r;
	wire [TAG_W-1:0] tag_info_w;
	wire [TAG_W*CB-1:0] tag_block_info_r;








cache_mem # ( .DW(DW), .BK(BK), .CB(CB), .CL(CL), .TAG_W(TAG_W) ) i_cache_mem
(
	.cache_addr(cache_addr),
	.cache_en_w(cache_block_en_w),
	.cache_en_r(cache_block_en_r),
	.cache_info_wstrb(cache_info_wstrb),
	.cache_info_w(cache_info_w),
	.cache_info_r(cache_block_info_r),

	.tag_addr(tag_addr),
	.tag_en_w(tag_block_en_w),
	.tag_en_r(tag_block_en_r),
	.tag_info_wstrb({((TAG_W+7)/8){1'b1}}),
	.tag_info_w(tag_info_w),
	.tag_info_r(tag_block_info_r),

	.CLK(CLK),
	.RSTn(RSTn)
);






dirty_block # ( .AW(32-ADDR_LSB), .DP(16) ) i_dirty_block
(
	input pop,
	input push,

	input [31:0] addr_i,	
	output [31:0] addr_o,

	output empty,
	output full,

	input CLK,
	input RSTn
);













endmodule


