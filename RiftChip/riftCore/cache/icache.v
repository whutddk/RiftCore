/*
* @File name: icache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-04 16:19:27
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


module icache #
(
	parameter DW = 128,
	parameter BK = 2,
	parameter CB = 2,
	parameter CL = 64
)
(
	//L1 I Cache
	output [31:0] IL1_ARADDR,
	output [7:0] IL1_ARLEN,
	output [1:0] IL1_ARBURST,
	output IL1_ARVALID,
	input IL1_ARREADY,

	input [63:0] IL1_RDATA,
	input [1:0] IL1_RRESP,
	input IL1_RLAST,
	input IL1_RVALID,
	output IL1_RREADY,

	//from ifu
	input ifu_req_valid,
	output ifu_req_ready,
	input [31:0] ifu_addr_req,

	output [63:0] ifu_data_rsp,
	output ifu_rsp_valid,
	input ifu_rsp_ready,


	input il1_fence,
	input CLK,
	input RSTn

);

	localparam IL1_STATE_CFREE = 0;
	localparam IL1_STATE_CKTAG = 1;
	localparam IL1_STATE_CMISS = 2;
	localparam IL1_STATE_FENCE = 3;


	localparam ADDR_LSB = $clog2(DW*BK/8);
	localparam LINE_W = $clog2(CL); 
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;

	wire il1_arvalid_set, il1_arvalid_rst, il1_arvalid_qout;
	wire il1_rready_set, il1_rready_rst, il1_rready_qout;
	wire il1_ar_req;
	wire il1_end_r;

	wire cache_fence_set;
	wire cache_fence_rst;
	wire cache_fence_qout;

	wire [1:0] il1_state_dnxt;
	wire [1:0] il1_state_qout;
	wire [1:0] il1_state_mode_dir;

	wire [31:0] cache_addr;

	wire [CB-1:0] cache_en_w;
	wire [CB-1:0] cache_en_r;
	wire [7:0] cache_info_wstrb;
	wire [63:0] cache_info_w;
	wire [64*CB-1:0] cache_info_r;

	wire [31:0] tag_addr;
	wire [CB-1:0] tag_en_w;
	wire [CB-1:0] tag_en_r;
	wire [(TAG_W+7)/8-1:0] tag_info_wstrb;
	wire [TAG_W-1:0] tag_info_w;
	wire [TAG_W*CB-1:0] tag_info_r;

	wire [31:0] cache_addr_dnxt;
	wire [31:0] cache_addr_qout;

	wire [CB-1:0] cb_vhit;
	wire [CL-1:0] valid_cl_sel;
	wire [63:0] cache_data_r;
	wire [64*CB-1:0] cache_info_r_T;

	wire [CL*CB-1:0] cache_valid_set;
	wire [CL*CB-1:0] cache_valid_rst;
	wire [CL*CB-1:0] cache_valid_qout;

	wire isCacheBlockRunout;
	wire [$clog2(CB)-1:0] cache_block_sel;
	wire [15:0] random;
	wire [CB-1:0] blockReplace;

	wire [CB-1:0] cache_cl_valid;

	assign IL1_ARBURST = 2'b01;
	assign IL1_ARADDR = ifu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} };
	assign IL1_ARLEN = 8'd3;
	assign IL1_ARVALID = il1_arvalid_qout;
	assign IL1_RREADY = il1_rready_qout;

	assign il1_end_r = IL1_RVALID & IL1_RREADY & IL1_RLAST;
	
	assign il1_arvalid_set = ~il1_arvalid_qout & il1_ar_req;
	assign il1_arvalid_rst = il1_arvalid_qout & IL1_ARREADY ;
	gen_rsffr # (.DW(1)) il1_arvalid_rsffr (.set_in(il1_arvalid_set), .rst_in(il1_arvalid_rst), .qout(il1_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	
	assign il1_rready_set = IL1_RVALID & (~IL1_RLAST | ~il1_rready_qout);
	assign il1_rready_rst = IL1_RVALID &   IL1_RLAST &  il1_rready_qout;
	gen_rsffr # (.DW(1)) il1_rready_rsffr (.set_in(il1_rready_set), .rst_in(il1_rready_rst), .qout(il1_rready_qout), .CLK(CLK), .RSTn(RSTn));






// BBBBBBBBBBBBBBBBB   RRRRRRRRRRRRRRRRR                  AAA               MMMMMMMM               MMMMMMMM
// B::::::::::::::::B  R::::::::::::::::R                A:::A              M:::::::M             M:::::::M
// B::::::BBBBBB:::::B R::::::RRRRRR:::::R              A:::::A             M::::::::M           M::::::::M
// BB:::::B     B:::::BRR:::::R     R:::::R            A:::::::A            M:::::::::M         M:::::::::M
//   B::::B     B:::::B  R::::R     R:::::R           A:::::::::A           M::::::::::M       M::::::::::M
//   B::::B     B:::::B  R::::R     R:::::R          A:::::A:::::A          M:::::::::::M     M:::::::::::M
//   B::::BBBBBB:::::B   R::::RRRRRR:::::R          A:::::A A:::::A         M:::::::M::::M   M::::M:::::::M
//   B:::::::::::::BB    R:::::::::::::RR          A:::::A   A:::::A        M::::::M M::::M M::::M M::::::M
//   B::::BBBBBB:::::B   R::::RRRRRR:::::R        A:::::A     A:::::A       M::::::M  M::::M::::M  M::::::M
//   B::::B     B:::::B  R::::R     R:::::R      A:::::AAAAAAAAA:::::A      M::::::M   M:::::::M   M::::::M
//   B::::B     B:::::B  R::::R     R:::::R     A:::::::::::::::::::::A     M::::::M    M:::::M    M::::::M
//   B::::B     B:::::B  R::::R     R:::::R    A:::::AAAAAAAAAAAAA:::::A    M::::::M     MMMMM     M::::::M
// BB:::::BBBBBB::::::BRR:::::R     R:::::R   A:::::A             A:::::A   M::::::M               M::::::M
// B:::::::::::::::::B R::::::R     R:::::R  A:::::A               A:::::A  M::::::M               M::::::M
// B::::::::::::::::B  R::::::R     R:::::R A:::::A                 A:::::A M::::::M               M::::::M
// BBBBBBBBBBBBBBBBB   RRRRRRRR     RRRRRRRAAAAAAA                   AAAAAAAMMMMMMMM               MMMMMMMM







assign cache_fence_set = il1_fence;
assign cache_fence_rst = (il1_state_qout == IL1_STATE_FENCE);
gen_rsffr # (.DW(1)) cache_fence_rsffr ( .set_in(cache_fence_set), .rst_in(cache_fence_rst), .qout(cache_fence_qout), .CLK(CLK), .RSTn(RSTn) );







gen_dffr # (.DW(2)) il1_state_dffr (.dnxt(il1_state_dnxt), .qout(il1_state_qout), .CLK(CLK), .RSTn(RSTn));


assign il1_state_mode_dir = 
	ifu_req_valid ? IL1_STATE_CKTAG : IL1_STATE_CFREE;


assign il1_state_dnxt = 
	( {2{il1_state_qout == IL1_STATE_CFREE}} & (cache_fence_qout ? IL1_STATE_FENCE : il1_state_mode_dir) )
	|
	( {2{il1_state_qout == IL1_STATE_CKTAG}} & ((| cb_vhit ) ? il1_state_mode_dir : IL1_STATE_CMISS) )
	|
	( {2{il1_state_qout == IL1_STATE_CMISS}} & (il1_end_r ? il1_state_mode_dir : IL1_STATE_CMISS) )
	|
	( {2{il1_state_qout == IL1_STATE_FENCE}} & IL1_STATE_CFREE )
	;



assign ifu_req_ready = il1_state_qout == IL1_STATE_CKTAG;


assign ifu_rsp_valid = 
	  ( (il1_state_qout == IL1_STATE_CKTAG) & (| cb_vhit ) )
	| ( (il1_state_qout == IL1_STATE_CMISS) & (cache_addr_qout == ifu_addr_req) & IL1_RVALID & IL1_RREADY );

assign ifu_data_rsp = 
	  ( {64{il1_state_qout == IL1_STATE_CKTAG}} & cache_data_r )
	| ( {64{il1_state_qout == IL1_STATE_CMISS}} & IL1_RDATA );


assign il1_ar_req = (il1_state_qout == IL1_STATE_CKTAG) & (il1_state_dnxt == IL1_STATE_CMISS);







	assign cache_en_w = cb_vhit & {CB{il1_state_qout == IL1_STATE_CMISS & IL1_RVALID & IL1_RREADY}};
	assign cache_en_r = {CB{il1_state_dnxt == IL1_STATE_CKTAG}};
	assign cache_info_wstrb = 8'b11111111;
	assign cache_info_w = IL1_RDATA;

	assign tag_addr = ifu_addr_req;
	assign tag_en_w = blockReplace & {CB{il1_state_qout == IL1_STATE_CKTAG & il1_state_dnxt == IL1_STATE_CMISS}};
	assign tag_en_r = {CB{(il1_state_dnxt == IL1_STATE_CKTAG) | (il1_state_qout == IL1_STATE_CMISS & IL1_ARVALID & IL1_ARREADY)}};
	assign tag_info_wstrb = {((TAG_W+7)/8){1'b1}};
	assign tag_info_w = tag_addr[31 -: TAG_W];


	assign cache_addr_dnxt = 
		  ( {32{il1_state_qout == IL1_STATE_CFREE}} & ifu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
		| ( {32{il1_state_qout == IL1_STATE_CKTAG}} & ifu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
		| ( {32{il1_state_qout == IL1_STATE_CMISS}} & ( (IL1_RVALID & IL1_RREADY) ? cache_addr_qout + 32'b1000 : cache_addr_qout) )
		| ( {32{il1_state_qout == IL1_STATE_FENCE}} & ifu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
		;

	gen_dffr #(.DW(32)) cache_addr_dffr ( .dnxt(cache_addr_dnxt), .qout(cache_addr_qout), .CLK(CLK), .RSTn(RSTn));


	assign cache_addr = (il1_state_qout == IL1_STATE_CMISS) ? cache_addr_qout : ifu_addr_req;


cache_mem # ( .DW(DW), .BK(BK), .CB(CB), .CL(CL), .TAG_W(TAG_W) ) i_cache_mem
(
	.cache_addr(cache_addr),
	.cache_en_w(cache_en_w),
	.cache_en_r(cache_en_r),
	.cache_info_wstrb(cache_info_wstrb),
	.cache_info_w(cache_info_w),
	.cache_info_r(cache_info_r),

	.tag_addr(tag_addr),
	.tag_en_w(tag_en_w),
	.tag_en_r(tag_en_r),
	.tag_info_wstrb(tag_info_wstrb),
	.tag_info_w(tag_info_w),
	.tag_info_r(tag_info_r),

	.CLK(CLK),
	.RSTn(RSTn)
);












assign valid_cl_sel = ifu_addr_req[ADDR_LSB +: LINE_W];

generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		assign cb_vhit[cb] = (tag_info_r[TAG_W*cb +: TAG_W] == ifu_addr_req[31 -: TAG_W]) & cache_valid_qout[CL*cb+valid_cl_sel];

		for ( genvar i = 0; i < 64; i = i + 1 ) begin
			assign cache_info_r_T[CB*i+cb] = cache_info_r[64*cb+i];
		end
	end

	for ( genvar i = 0; i < 64; i = i + 1 ) begin
		assign cache_data_r[i] = | (cache_info_r_T[CB*i +: CB] & cb_vhit);
	end


endgenerate







generate
	for ( genvar cl = 0; cl < CL; cl = cl + 1) begin
		for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin

			assign cache_valid_set[CB*cl+cb] = (il1_state_qout == IL1_STATE_CKTAG) & (il1_state_dnxt == IL1_STATE_CMISS) & (cl == valid_cl_sel) & blockReplace[cb];
			assign cache_valid_rst[CB*cl+cb] = (il1_state_qout == IL1_STATE_FENCE) & (il1_state_dnxt == IL1_STATE_CFREE);

			gen_rsffr # (.DW(1)) cache_valid_rsffr (.set_in(cache_valid_set[CB*cl+cb]), .rst_in(cache_valid_rst[CB*cl+cb]), .qout(cache_valid_qout[CB*cl+cb]), .CLK(CLK), .RSTn(RSTn));

		end


	end

endgenerate







assign cache_cl_valid = cache_valid_qout[CB*valid_cl_sel +:CB];

lzp # ( .CW($clog2(CB)) ) l2c_malloc
(
	.in_i(cache_cl_valid),
	.pos_o(cache_block_sel),
	.all1(isCacheBlockRunout),
	.all0()
);

lfsr i_lfsr
(
	.random(random),
	.CLK(CLK)
);

assign blockReplace = 1 << ( isCacheBlockRunout ? random[$clog2(CB):0] : cache_block_sel );



endmodule




