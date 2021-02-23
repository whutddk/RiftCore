/*
* @File name: L3Cache_mem
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-23 09:28:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-23 09:49:32
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
	input [31:0] addr_req,
	input cache_read,
	input cache_write,
	
);

localparam DW = 1024;
localparam BK = 4;
localparam CB = 1;
localparam CL = 256;



localparam ADDR_LSB = $clog2(DW*BK/8);
localparam LINE_W = $clog2(CL); 
localparam TAG_W = 32 - ADDR_LSB - LINE_W;






cache_mem # ( .DW(DW), .BK(BK), .CB(CB), .CL(CL), .TAG_W(TAG_W) ) i_cache_mem
(
	input [31:0] cache_addr,
	input [CB-1:0] cache_en_w,
	input [CB-1:0] cache_en_r,
	input [7:0] cache_info_wstrb,
	input [63:0] cache_info_w,
	output [64*CB-1:0] cache_info_r,


	input [31:0] tag_addr,
	input [CB-1:0] tag_en_w,
	input [CB-1:0] tag_en_r,
	input [(TAG_W+7)/8-1:0] tag_info_wstrb,
	input [TAG_W-1:0] cache_info_w,
	output [TAG_W*CB-1:0] cache_info_r

	input CLK,
	input RSTn
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


