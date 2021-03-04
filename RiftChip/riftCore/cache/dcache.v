/*
* @File name: dcache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-18 19:03:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-04 12:03:53
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


module dcache #
(
	parameter DW = 128,
	parameter BK = 2,
	parameter CB = 4,
	parameter CL = 64
)
(

	//L1 D cache
	output [31:0] DL1_AWADDR,
	output [7:0] DL1_AWLEN,
	output [1:0] DL1_AWBURST,
	output DL1_AWVALID,
	input DL1_AWREADY,

	output [63:0] DL1_WDATA,
	output [7:0] DL1_WSTRB,
	output DL1_WLAST,
	output DL1_WVALID,
	input DL1_WREADY,

	input [1:0] DL1_BRESP,
	input DL1_BVALID,
	output DL1_BREADY,

	output [31:0] DL1_ARADDR,
	output [7:0] DL1_ARLEN,
	output [1:0] DL1_ARBURST,
	output DL1_ARVALID,
	input DL1_ARREADY,

	input [63:0] DL1_RDATA,
	input [1:0] DL1_RRESP,
	input DL1_RLAST,
	input DL1_RVALID,
	output DL1_RREADY,

	//from lsu
	input lsu_req_valid,
	output lsu_req_ready,
	input [31:0] lsu_addr_req,
	input [63:0] lsu_wdata_req,
	input [7:0] lsu_wstrb_req,
	input lsu_wen_req,

	output [31:0] lsu_rdata_rsp,
	output lsu_rsp_valid,
	input lsu_rsp_ready,



	input dl1_fence,
	input CLK,
	input RSTn
);

	localparam DL1_STATE_CFREE = 0;
	localparam DL1_STATE_CREAD = 1;
	localparam DL1_STATE_MWAIT = 2;
	localparam DL1_STATE_CMISS = 3;
	localparam DL1_STATE_FENCE = 4;
	localparam DL1_STATE_WRITE = 5;

	localparam ADDR_LSB = $clog2(DW*BK/8);
	localparam LINE_W = $clog2(CL); 
	localparam TAG_W = 32 - ADDR_LSB - LINE_W;

	wire dl1_awvalid_set, dl1_awvalid_rst, dl1_awvalid_qout;
	wire dl1_wvalid_set, dl1_wvalid_rst, dl1_wvalid_qout;
	wire dl1_bready_set, dl1_bready_rst, dl1_bready_qout;
	wire dl1_arvalid_set, dl1_arvalid_rst, dl1_arvalid_qout;
	wire dl1_rready_set, dl1_rready_rst, dl1_rready_qout;
	wire dl1_aw_req, dl1_ar_req;
	wire dl1_end_r, dl1_end_w;

	wire cache_fence_set;
	wire cache_fence_rst;
	wire cache_fence_qout;

	wire [2:0] dl1_state_dnxt;
	wire [2:0] dl1_state_qout;

	wire [2:0] dl1_state_mode_dir;

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
	
	wire [31:0] chkAddr;
	wire isHazard_r;
	wire wtb_push;
	wire wtb_pop;
	wire [103:0] wtb_data_i;
	wire [103:0] wtb_data_o;
	wire wtb_full;
	wire wtb_empty;


	assign DL1_ARADDR = lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} };
	assign DL1_AWLEN = 8'd0;
	assign DL1_AWBURST = 2'b00;
	assign DL1_AWVALID = dl1_awvalid_qout;


	assign DL1_WSTRB = {8{1'b1}};
	assign DL1_WLAST = 1'b1;
	assign DL1_WVALID = dl1_wvalid_qout;
	assign DL1_BREADY = dl1_bready_qout;


	assign DL1_ARLEN = 8'd3;
	assign DL1_ARBURST = 2'b01;
	assign DL1_ARVALID = dl1_arvalid_qout;
	assign DL1_RREADY = dl1_rready_qout;
	assign dl1_end_r = DL1_RVALID & DL1_RREADY & DL1_RLAST;
	assign dl1_end_w = DL1_WVALID & DL1_WREADY & DL1_WLAST;


	assign dl1_awvalid_set = ~dl1_awvalid_qout & dl1_aw_req;
	assign dl1_awvalid_rst =  dl1_awvalid_qout & DL1_AWREADY ;
	gen_rsffr # (.DW(1)) dl1_awvalid_rsffr (.set_in(dl1_awvalid_set), .rst_in(dl1_awvalid_rst), .qout(dl1_awvalid_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_wvalid_set = (~dl1_wvalid_qout & dl1_aw_req);
	assign dl1_wvalid_rst = (DL1_WREADY & dl1_wvalid_qout & DL1_WLAST) ;
	gen_rsffr # (.DW(1)) dl1_wvalid_rsffr (.set_in(dl1_wvalid_set), .rst_in(dl1_wvalid_rst), .qout(dl1_wvalid_qout), .CLK(CLK), .RSTn(RSTn));

	assign dl1_bready_set = (DL1_BVALID && ~dl1_bready_qout);
	assign dl1_bready_rst = dl1_bready_qout;
	gen_rsffr # (.DW(1)) dl1_bready_rsffr (.set_in(dl1_bready_set), .rst_in(dl1_bready_rst), .qout(dl1_bready_qout), .CLK(CLK), .RSTn(RSTn));
	
	assign dl1_arvalid_set = ~dl1_arvalid_qout & dl1_ar_req;
	assign dl1_arvalid_rst = dl1_arvalid_qout & DL1_ARREADY ;
	gen_rsffr # (.DW(1)) dl1_arvalid_rsffr (.set_in(dl1_arvalid_set), .rst_in(dl1_arvalid_rst), .qout(dl1_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	
	assign dl1_rready_set = DL1_RVALID & (~DL1_RLAST | ~dl1_rready_qout);
	assign dl1_rready_rst = DL1_RVALID &   DL1_RLAST &  dl1_rready_qout;
	gen_rsffr # (.DW(1)) dl1_rready_rsffr (.set_in(dl1_rready_set), .rst_in(dl1_rready_rst), .qout(dl1_rready_qout), .CLK(CLK), .RSTn(RSTn));










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




assign cache_fence_set = dl1_fence;
assign cache_fence_rst = (dl1_state_qout == DL1_STATE_FENCE);
gen_rsffr # (.DW(1)) cache_fence_rsffr ( .set_in(cache_fence_set), .rst_in(cache_fence_rst), .qout(cache_fence_qout), .CLK(CLK), .RSTn(RSTn) );



gen_dffr # (.DW(3)) dl1_state_dffr (.dnxt(dl1_state_dnxt), .qout(dl1_state_qout), .CLK(CLK), .RSTn(RSTn));



assign dl1_state_mode_dir = 
	lsu_req_valid ?
		( (~lsu_wen_req) ? DL1_STATE_CREAD : (~wtb_full ? DL1_STATE_WRITE : DL1_STATE_CFREE) ) :
		 DL1_STATE_CFREE;



assign dl1_state_dnxt = 
		( {3{dl1_state_qout == DL1_STATE_CFREE}} & 
			( dl1_fence ? DL1_STATE_FENCE : dl1_state_mode_dir )
		)
		|
		( {3{dl1_state_qout == DL1_STATE_CREAD}} &
			( (| cb_vhit ) ? dl1_state_mode_dir : ( isHazard_r ? DL1_STATE_MWAIT : DL1_STATE_CMISS)  )
		)
		|
		( {3{dl1_state_qout == DL1_STATE_MWAIT}} &
			(( ~isHazard_r) ? DL1_STATE_CMISS : DL1_STATE_MWAIT)
		)
		|
		( {3{dl1_state_qout == DL1_STATE_CMISS}} & 
			( dl1_end_r ? dl1_state_mode_dir : DL1_STATE_CMISS )
		)
		|
		( {3{dl1_state_qout == DL1_STATE_WRITE}} & 
			dl1_state_mode_dir )
		|
		( {3{dl1_state_qout == DL1_STATE_FENCE}} & (wtb_empty ? DL1_STATE_CFREE : DL1_STATE_FENCE) )		
		;



assign lsu_req_ready = 
	  (dl1_state_qout == DL1_STATE_CREAD)
	| (dl1_state_qout == DL1_STATE_WRITE)
	;


assign lsu_rsp_valid = 
	  ( (dl1_state_qout == DL1_STATE_CREAD) & (| cb_vhit) )
	| ( (dl1_state_qout == DL1_STATE_CMISS) & (cache_addr_qout == lsu_addr_req) )
	| ( (dl1_state_qout == DL1_STATE_WRITE) );

assign dl1_ar_req = 
	(
		  ((dl1_state_qout == DL1_STATE_CREAD) & (dl1_state_dnxt == DL1_STATE_CMISS))
		| ((dl1_state_qout == DL1_STATE_MWAIT) & (dl1_state_dnxt == DL1_STATE_CMISS))
	);









assign lsu_rdata_rsp = 
	  ( {64{dl1_state_qout == DL1_STATE_CREAD}} & cache_data_r )
	| ( {64{dl1_state_qout == DL1_STATE_CMISS}} & DL1_RDATA );



assign cache_addr = (dl1_state_qout == DL1_STATE_CMISS) ? cache_addr_qout : lsu_addr_req;
assign cache_en_w =
	  (cb_vhit & {CB{dl1_state_qout == DL1_STATE_CMISS & DL1_RVALID & DL1_RREADY}})
	| (cb_vhit & {CB{dl1_state_qout == DL1_STATE_WRITE}});

assign cache_en_r = {CB{dl1_state_dnxt == DL1_STATE_CREAD}};
assign cache_info_wstrb = (dl1_state_qout == DL1_STATE_CMISS) ? 8'b11111111 : lsu_wstrb_req;
assign cache_info_w = (dl1_state_qout == DL1_STATE_CMISS) ? DL1_RDATA : lsu_wdata_req;



assign tag_addr = lsu_addr_req;
assign tag_en_w = blockReplace &
			{CB{
				  (dl1_state_qout == DL1_STATE_CREAD & dl1_state_dnxt == DL1_STATE_CMISS)
				| (dl1_state_qout == DL1_STATE_MWAIT & dl1_state_dnxt == DL1_STATE_CMISS)
			}};
assign tag_en_r = {CB{(dl1_state_dnxt == DL1_STATE_CREAD) | (dl1_state_dnxt == DL1_STATE_WRITE) | (dl1_state_qout == DL1_STATE_CMISS & DL1_ARVALID & DL1_ARREADY)}};
assign tag_info_wstrb = {((TAG_W+7)/8){1'b1}};
assign tag_info_w = tag_addr[31 -: TAG_W];


assign cache_addr_dnxt = 
	  ( {32{dl1_state_qout == DL1_STATE_CFREE}} & lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
	| ( {32{dl1_state_qout == DL1_STATE_CREAD}} & lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
	| ( {32{dl1_state_qout == DL1_STATE_WRITE}} & lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
	| ( {32{dl1_state_qout == DL1_STATE_MWAIT}} & lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
	| ( {32{dl1_state_qout == DL1_STATE_CMISS}} & ( (DL1_RVALID & DL1_RREADY) ? cache_addr_qout + 32'b1000 : cache_addr_qout) )
	| ( {32{dl1_state_qout == DL1_STATE_FENCE}} & lsu_addr_req & { {(32-ADDR_LSB){1'b1}}, {ADDR_LSB{1'b0}} } )
	;

gen_dffr #(.DW(32)) cache_addr_dffr ( .dnxt(cache_addr_dnxt), .qout(cache_addr_qout), .CLK(CLK), .RSTn(RSTn));





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






assign valid_cl_sel = lsu_addr_req[ADDR_LSB +: LINE_W];

generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		assign cb_vhit[cb] = (tag_info_r[TAG_W*cb +: TAG_W] == lsu_addr_req[31 -: TAG_W]) & cache_valid_qout[CL*cb+valid_cl_sel];

		for ( genvar i = 0; i < 64; i = i + 1 ) begin
			assign cache_info_r_T[CB*i+cb] = cache_info_r[64*cb+i];
		end
	end

	for ( genvar i = 0; i < 64; i = i + 1 ) begin
		assign cache_data_r[i] = | (cache_info_r_T[CB*i +: CB] & cb_vhit);
	end


endgenerate







generate
	for ( genvar cb = 0; cb < CB; cb = cb + 1 ) begin
		for ( genvar cl = 0; cl < CL; cl = cl + 1) begin

			assign cache_valid_set[CB*cl+cb] =
				(
					  (dl1_state_qout == DL1_STATE_CREAD) & (dl1_state_dnxt == DL1_STATE_CMISS)
					| (dl1_state_qout == DL1_STATE_MWAIT) & (dl1_state_dnxt == DL1_STATE_CMISS)
				)
				& (cl == valid_cl_sel) & blockReplace[cb];

			assign cache_valid_rst[CB*cl+cb] = (dl1_state_qout == DL1_STATE_FENCE) & (dl1_state_dnxt == DL1_STATE_CFREE);

			gen_rsffr # (.DW(1)) cache_valid_rsffr (.set_in(cache_valid_set[CB*cl+cb]), .rst_in(cache_valid_rst[CB*cl+cb]), .qout(cache_valid_qout[CB*cl+cb]), .CLK(CLK), .RSTn(RSTn));

		end


	end

endgenerate








lzp # ( .CW($clog2(CB)) ) dl1_malloc
(
	.in_i(cache_valid_qout[CB*valid_cl_sel +: CB]),
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







// TTTTTTTTTTTTTTTTTTTTTTTXXXXXXX       XXXXXXX
// T:::::::::::::::::::::TX:::::X       X:::::X
// T:::::::::::::::::::::TX:::::X       X:::::X
// T:::::TT:::::::TT:::::TX::::::X     X::::::X
// TTTTTT  T:::::T  TTTTTTXXX:::::X   X:::::XXX
//         T:::::T           X:::::X X:::::X   
//         T:::::T            X:::::X:::::X    
//         T:::::T             X:::::::::X     
//         T:::::T             X:::::::::X     
//         T:::::T            X:::::X:::::X    
//         T:::::T           X:::::X X:::::X   
//         T:::::T        XXX:::::X   X:::::XXX
//       TT:::::::TT      X::::::X     X::::::X
//       T:::::::::T      X:::::X       X:::::X
//       T:::::::::T      X:::::X       X:::::X
//       TTTTTTTTTTT      XXXXXXX       XXXXXXX


















assign chkAddr = lsu_addr_req;
assign wtb_push = (dl1_state_qout == DL1_STATE_WRITE);
assign wtb_pop = dl1_end_w;
		
assign dl1_aw_req = ~wtb_empty & (~DL1_AWVALID & ~DL1_WVALID);

assign {DL1_WDATA, DL1_WSTRB, DL1_AWADDR} = wtb_data_o;



localparam WTB_AW = 3;
localparam WTB_DP = 2**WTB_AW;


assign wtb_data_i = { lsu_wdata_req, lsu_wstrb_req, lsu_addr_req };

wt_block # ( .DW(104), .DP(WTB_DP), .TAG_W(TAG_W) ) i_wt_block
(
	.chkAddr(chkAddr),
	.isHazard_r(isHazard_r),

	.push(wtb_push),
	.data_i(wtb_data_i),

	.pop(wtb_pop),
	.data_o(wtb_data_o),

	.empty(wtb_empty),
	.full(wtb_full),

	.CLK(CLK),
	.RSTn(RSTn)
);










//ASSERT
always @( negedge CLK ) begin

	if ( (dl1_state_qout == DL1_STATE_CMISS) & (DL1_AWVALID | DL1_WVALID) ) begin
		$display("Assert Fail at L1-Dcache");
		$stop;
	end


end


initial begin 
	$info("Cache Miss should operate after no tag hit in dirty buff");
end



endmodule


