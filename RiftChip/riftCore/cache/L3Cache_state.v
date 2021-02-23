/*
* @File name: L3Cache_state
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-23 09:49:56
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-23 09:50:43
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


module L3Cache_state (

);




localparam L3C_FREE = 0;
localparam L3C_TAG = 1;
localparam L3C_EVICT = 2;
localparam L3C_REFLASH = 3;
localparam L3C_RSPRD = 4;
localparam L3C_RSPWR = 5;
localparam L3C_FENCE = 6;


wire [2:0] l3c_state_dnxt;
wire [2:0] l3c_state_qout;
gen_dffr #(.DW(3)) l3c_state_dffr (.dnxt(l3c_state_dnxt), .qout(l3c_state_qout), .CLK(CLK), .RSTn(RSTn));

assign l3c_state_dnxt = 
	(
		{3{l3c_state_qout == L3C_FREE}} &
		(
			cache_fence_qout ? L3C_FENCE :
				( (L2C_AWVALID | L2C_ARVALID) ? L3C_TAG : L3C_FREE)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_FENCE}} &
		(
			(| tag_valid_qout) ? L3C_EVICT : L3C_FREE
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_TAG}} & 
		(
			({{ isCacheHit & L2C_AWVALID}} & L3C_RSPWR )
			|
			({{ isCacheHit & L2C_ARVALID}} & L3C_RSPRD )
			|
			({{ isCacheMiss &  tag_valid_r}} & L3C_EVICT)
			|
			({{ isCacheMiss & ~tag_valid_r}} & L3C_REFLASH)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_EVICT}} & 
		(
			~mem_bready_set ? L3C_EVICT : 
				( cache_fence_qout ? L3C_FENCE : L3C_TAG)
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_REFLASH}} & 
		(
			mem_rready_set ? L3C_TAG : L3C_REFLASH
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_RSPRD}} & 
		(
			l2c_rvalid_set ? L3C_FREE : L3C_RSPRD
		)
	)
	|
	(
		{3{l3c_state_qout == L3C_RSPWR}} & 
		(
			l2c_bvalid_set ? L3C_FREE : L3C_RSPWR
		)
	)















endmodule





