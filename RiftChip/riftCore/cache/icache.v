/*
* @File name: icache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-09 17:53:14
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-02 10:52:22
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
	parameter DW = 256,
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


	wire il1_arvalid_set, il1_arvalid_rst, il1_arvalid_qout;
	wire il1_rready_set, il1_rready_rst, il1_rready_qout;
	wire il1_ar_req;
	wire il1_end_r;

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


	localparam IL1_CFREE = 0;
	localparam IL1_CKTAG = 1;
	localparam IL1_CMISS = 2;
	localparam IL1_FENCE = 3;


	localparam ADDR_LSB = $clog2(DW/8);
	localparam LINE_W = $clog2(CL); 
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;

	wire cache_fence_set;
	wire cache_fence_rst;
	wire cache_fence_qout;


assign cache_fence_set = il1_fence;
assign cache_fence_rst = (il1_state_qout == L2C_FENCE);
gen_rsffr # (.DW(1)) cache_fence_rsffr ( .set_in(cache_fence_set), .rst_in(cache_fence_rst), .qout(cache_fence_qout), .CLK(CLK), .RSTn(RSTn) );





wire [1:0] il1_state_dnxt;
wire [1:0] il1_state_qout;

gen_dffr # (.DW(2)) il1_state_dffr (.dnxt(il1_state_dnxt), .qout(il1_state_qout), .CLK(CLK), .RSTn(RSTn));


assign il1_state_dnxt = 
	( {2{il1_state_qout == IL1_CFREE}} & cache_fence_qout ? IL1_FENCE : ((ifu_req_valid & ifu_req_ready) ? IL1_CKTAG : IL1_CFREE) )
	|
	( {2{il1_state_qout == IL1_CKTAG}} & ((| cb_vhit ) ? ((ifu_req_valid & ifu_req_ready) ? IL1_CKTAG : IL1_CFREE) : IL1_CMISS) )
	|
	( {2{il1_state_qout == IL1_CMISS}} & (il1_end_r ? ((ifu_req_valid & ifu_req_ready) ? IL1_CKTAG : IL1_CFREE) : IL1_CMISS) )
	|
	( {2{il1_state_qout == IL1_FENCE}} & IL1_CFREE )
	;



assign ifu_req_ready = 
	( (il1_state_qout == IL1_CFREE) & ~cache_fence_qout)
	|
	( (il1_state_qout == IL1_CKTAG) & (| cb_vhit))
	|
	( (il1_state_qout == IL1_CMISS) & il1_end_r );


assign ifu_rsp_valid = 
	( (il1_state_qout == IL1_CKTAG) & (| cb_vhit ) )
	|
	( (il1_state_qout == IL1_CMISS) & ifu_rsp_valid & ifu_rsp_ready & (cache_addr_qout == ifu_addr_req) );

assign ifu_data_rsp = 
	( {64{il1_state_qout == IL1_CKTAG}} & cache_data_r )
	| ( {64{il1_state_qout == IL1_CMISS}} & IL1_RDATA );






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





	assign cache_en_w = cb_vhit & {CB{il1_state_qout == IL1_CMISS & IL1_RVALID & IL1_RREADY}};
	assign cache_en_r = {CB{il1_state_dnxt == IL1_CKTAG}};
	assign cache_info_wstrb = 8'b11111111;
	assign cache_info_w = IL1_RDATA;

	assign tag_addr = ifu_addr_req;
	assign tag_en_w = blockReplace & {CB{il1_state_qout == IL1_CKTAG & il1_state_dnxt == IL1_CMISS}};
	assign tag_en_r = {CB{il1_state_dnxt == IL1_CKTAG}};
	assign tag_info_wstrb = {((TAG_W+7)/8){1'b1}};
	assign tag_info_w = tag_addr[31:ADDR_LSB];


	assign cache_addr_dnxt = 
		  ( {32{il1_state_qout == IL1_CFREE}} & ifu_addr_req )
		| ( {32{il1_state_qout == IL1_CKTAG}} & cache_addr_qout )
		| ( {32{il1_state_qout == IL1_CMISS}} & ( (IL1_RVALID & IL1_RREADY) ? cache_addr_qout + 32'b1000 : cache_addr_qout) )
		| ( {32{il1_state_qout == IL1_FENCE}} & cache_addr_qout )
		;

	gen_dffr #(.DW(32)) cache_addr_dffr ( .dnxt(cache_addr_dnxt), .qout(cache_addr_qout), .CLK(CLK), .RSTn(RSTn));





cache_mem # ( .DW(DW), .BK(1), .CB(CB), .CL(CL), .TAG_W(TAG_W) ) i_cache_mem
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








	wire [CB-1:0] cb_vhit;
	wire [CL-1:0] valid_cl_sel;
	wire [63:0] cache_data_r;
	wire [64*CB-1:0] cache_info_r_T;





assign valid_cl_sel = tag_addr[ADDR_LSB +: $clog2(CL)];

generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		assign cb_vhit[cb] = (tag_info_r[TAG_W*cb +: TAG_W] == tag_addr[31:ADDR_LSB]) & cache_valid_qout[CL*cb+valid_cl_sel];

		for ( genvar i = 0; i < 64; i = i + 1 ) begin
			assign cache_info_r_T[CB*i+cb] = cache_info_r[64*cb+i];
		end
	end

	for ( genvar i = 0; i < 64; i = i + 1 ) begin
		assign cache_data_r[i] = | (cache_info_r_T[CB*i +: CB] & cb_vhit);
	end


endgenerate





	wire [CL*CB-1:0] cache_valid_set;
	wire [CL*CB-1:0] cache_valid_rst;
	wire [CL*CB-1:0] cache_valid_qout;

generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		for ( genvar cl = 0; cl < CL; cl = cl + 1) begin

			assign cache_valid_set[CL*cb+cl] = (il1_state_qout == IL1_CKTAG) & (il1_state_dnxt == IL1_CMISS) & (cl == valid_cl_sel) & blockReplace[cb];
			assign cache_valid_rst[CL*cb+cl] = (il1_state_qout == IL1_FENCE) & (il1_state_dnxt == IL1_CFREE);

			gen_rsffr # (.DW(1)) cache_valid_rsffr (.set_in(cache_valid_set[CL*cb+cl]), .rst_in(cache_valid_rst[CL*cb+cl]), .qout(cache_valid_qout[CL*cb+cl]), .CLK(CLK), .RSTn(RSTn));

		end


	end

endgenerate





	wire isCacheBlockRunout;
	wire [$clog2(CB)-1:0] cache_block_sel;
	wire [15:0] random;
	wire [CB-1:0] blockReplace;



lzp # ( .CW($clog2(CB)) ) l2c_malloc
(
	.in_i(cache_valid_qout[CB*valid_cl_sel +:CB]),
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




