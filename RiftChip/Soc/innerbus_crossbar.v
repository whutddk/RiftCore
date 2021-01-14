/*
* @File name: innerbus_crossbar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-31 17:04:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-14 15:55:38
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

module innerbus_crossbar (
	//DM
	input dm_req_kill,
	input dm_mstReq_valid,
	output dm_mstReq_ready,
	input [63:0] dm_addr,
	input [63:0] dm_data_w,
	output [63:0] dm_data_r,
	input [7:0] dm_wstrb,
	input dm_wen,
	output dm_slvRsp_valid,
	// input dm_mstRsp_ready,

	//IFU
	input ifu_req_kill,
	input ifu_mstReq_valid,
	output ifu_mstReq_ready,
	input [63:0] ifu_addr,
	input [63:0] ifu_data_w,
	output [63:0] ifu_data_r,
	input [7:0] ifu_wstrb,
	input ifu_wen,
	output ifu_slvRsp_valid,
	// input ifu_mstRsp_ready,

	//LSU
	input lsu_req_kill,
	input lsu_mstReq_valid,
	output lsu_mstReq_ready,
	input [63:0] lsu_addr,
	input [63:0] lsu_data_w,
	output [63:0] lsu_data_r,
	input [7:0] lsu_wstrb,
	input lsu_wen,
	output lsu_slvRsp_valid,
	// input lsu_mstRsp_ready,








	//CLINT
	output clint_mstReq_valid,
	input clint_mstReq_ready,
	output [63:0] clint_addr,
	output [63:0] clint_data_w,
	input [63:0] clint_data_r,
	output [7:0] clint_wstrb,
	output clint_wen,
	input clint_slvRsp_valid,
	// output clint_mstRsp_ready,

	//PLIC
	output plic_mstReq_valid,
	input plic_mstReq_ready,
	output [63:0] plic_addr,
	output [63:0] plic_data_w,
	input [63:0] plic_data_r,
	output [7:0] plic_wstrb,
	output plic_wen,
	input plic_slvRsp_valid,
	// output plic_mstRsp_ready,


	//system bus
	output sysbus_mstReq_valid,
	input sysbus_mstReq_ready,
	output [63:0] sysbus_addr,
	output [63:0] sysbus_data_w,
	input [63:0] sysbus_data_r,
	output [7:0] sysbus_wstrb,
	output sysbus_wen,
	input sysbus_slvRsp_valid,
	// output sysbus_mstRsp_ready,

	//peripherals bus
	output perip_mstReq_valid,
	input perip_mstReq_ready,
	output [63:0] perip_addr,
	output [63:0] perip_data_w,
	input [63:0] perip_data_r,
	output [7:0] perip_wstrb,
	output perip_wen,
	input perip_slvRsp_valid,
	// output perip_mstRsp_ready,

	//mem bus
	output mem_mstReq_valid,
	input mem_mstReq_ready,
	output [63:0] mem_addr,
	output [63:0] mem_data_w,
	input [63:0] mem_data_r,
	output [7:0] mem_wstrb,
	output mem_wen,
	input mem_slvRsp_valid,
	// output mem_mstRsp_ready,

	input CLK,
	input RSTn


);



// MMMMMMMM               MMMMMMMM   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTT
// M:::::::M             M:::::::M SS:::::::::::::::ST:::::::::::::::::::::T
// M::::::::M           M::::::::MS:::::SSSSSS::::::ST:::::::::::::::::::::T
// M:::::::::M         M:::::::::MS:::::S     SSSSSSST:::::TT:::::::TT:::::T
// M::::::::::M       M::::::::::MS:::::S            TTTTTT  T:::::T  TTTTTT
// M:::::::::::M     M:::::::::::MS:::::S                    T:::::T        
// M:::::::M::::M   M::::M:::::::M S::::SSSS                 T:::::T        
// M::::::M M::::M M::::M M::::::M  SS::::::SSSSS            T:::::T        
// M::::::M  M::::M::::M  M::::::M    SSS::::::::SS          T:::::T        
// M::::::M   M:::::::M   M::::::M       SSSSSS::::S         T:::::T        
// M::::::M    M:::::M    M::::::M            S:::::S        T:::::T        
// M::::::M     MMMMM     M::::::M            S:::::S        T:::::T        
// M::::::M               M::::::MSSSSSSS     S:::::S      TT:::::::TT      
// M::::::M               M::::::MS::::::SSSSSS:::::S      T:::::::::T      
// M::::::M               M::::::MS:::::::::::::::SS       T:::::::::T      
// MMMMMMMM               MMMMMMMM SSSSSSSSSSSSSSS         TTTTTTTTTTT      










	//mst dm ifu lsu
	//slv clint plic sys-bus perip-bus mem-bus






	wire ifu_req_bp_valid_i;
	wire [64+64+8+1-1:0] ifu_req_bp_data_i;
	wire ifu_req_bp_ready_i;
	wire ifu_req_bp_valid_o;
	wire [64+64+8+1-1:0] ifu_req_bp_data_o;
	wire ifu_req_bp_ready_o;


	wire lsu_req_bp_valid_i;
	wire [64+64+8+1-1:0] lsu_req_bp_data_i;
	wire lsu_req_bp_ready_i;
	wire lsu_req_bp_valid_o;
	wire [64+64+8+1-1:0] lsu_req_bp_data_o;
	wire lsu_req_bp_ready_o;


	assign ifu_req_bp_valid_i = ifu_mstReq_valid;
	assign lsu_req_bp_valid_i = lsu_mstReq_valid;

	assign ifu_req_bp_data_i  = { ifu_addr, ifu_data_w, ifu_wstrb, ifu_wen };
	assign lsu_req_bp_data_i  = { lsu_addr, lsu_data_w, lsu_wstrb, lsu_wen };

	assign ifu_req_bp_ready_o = arbi_ready & ~dm_mstReq_valid;
	assign lsu_req_bp_ready_o = arbi_ready & ~dm_mstReq_valid & ~ifu_mstReq_valid;	

	assign dm_mstReq_ready  = arbi_ready & ifu_req_bp_ready_i & lsu_req_bp_ready_i & ~dm_mstReq_valid & ~ifu_mstReq_valid & ~lsu_mstReq_valid;
	assign ifu_mstReq_ready = arbi_ready & ifu_req_bp_ready_i & lsu_req_bp_ready_i & ~dm_mstReq_valid & ~ifu_mstReq_valid & ~lsu_mstReq_valid;
	assign lsu_mstReq_ready = arbi_ready & ifu_req_bp_ready_i & lsu_req_bp_ready_i & ~dm_mstReq_valid & ~ifu_mstReq_valid & ~lsu_mstReq_valid;


	gen_bypassfifo # ( .DW(64+64+8+1) ) ifu_req_bp
	(
		.valid_i(ifu_req_bp_valid_i),
		.data_i(ifu_req_bp_data_i),
		.ready_i(ifu_req_bp_ready_i),

		.valid_o(ifu_req_bp_valid_o),
		.data_o(ifu_req_bp_data_o),
		.ready_o(ifu_req_bp_ready_o),

		.flush(ifu_req_kill),
		.CLK(CLK),
		.RSTn(RSTn)
	);


	gen_bypassfifo # ( .DW(64+64+8+1) ) lsu_req_bp
	(
		.valid_i(lsu_req_bp_valid_i),
		.data_i(lsu_req_bp_data_i),
		.ready_i(lsu_req_bp_ready_i),

		.valid_o(lsu_req_bp_valid_o),
		.data_o(lsu_req_bp_data_o),
		.ready_o(lsu_req_bp_ready_o),

		.flush(lsu_req_kill),
		.CLK(CLK),
		.RSTn(RSTn)
	);










	wire arbi_ready;
	wire [64+64+8+1-1:0] arbi_data_info_w;
	wire [63:0] arbi_data_r;
	wire arbi_Rsp;
	wire [63:0] arbi_addr;


	wire isDMReq_set, isDMReq_rst, isDMReq_qout;
	wire isIFUReq_set, isIFUReq_rst, isIFUReq_qout;
	wire isLSUReq_set, isLSUReq_rst, isLSUReq_qout;

	assign isDMReq_set = dm_mstReq_valid & ~dm_req_kill;
	assign isIFUReq_set = ~dm_mstReq_valid & ifu_req_bp_valid_o & ~ifu_req_kill;
	assign isLSUReq_set = ~dm_mstReq_valid & ~ifu_req_bp_valid_o & lsu_req_bp_valid_o & ~lsu_req_kill;

	assign isDMReq_rst = arbi_Rsp  | dm_req_kill;
	assign isIFUReq_rst = arbi_Rsp | ifu_req_kill;
	assign isLSUReq_rst = arbi_Rsp | lsu_req_kill;


	gen_rsffr # ( .DW(1) ) isDMReq_rsffr  (.set_in(isDMReq_set), .rst_in(isDMReq_rst), .qout(isDMReq_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # ( .DW(1) ) isIFUReq_rsffr (.set_in(isIFUReq_set), .rst_in(isIFUReq_rst), .qout(isIFUReq_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr # ( .DW(1) ) isLSUReq_rsffr (.set_in(isLSUReq_set), .rst_in(isLSUReq_rst), .qout(isLSUReq_qout), .CLK(CLK), .RSTn(RSTn));


	assign arbi_ready = ~isDMReq_qout & ~isIFUReq_qout & ~isLSUReq_qout & slv_ready;
	assign arbi_data_info_w = 
				({(64+64+8+1){isDMReq_set}} & { dm_addr, dm_data_w, dm_wstrb, dm_wen })
				|
				({(64+64+8+1){isIFUReq_set}} & ifu_req_bp_data_o)
				|
				({(64+64+8+1){isLSUReq_set}} & lsu_req_bp_data_o);

	assign arbi_data_r = 
				({64{clint_slvRsp_valid}} & clint_data_r)
				|
				({64{plic_slvRsp_valid}} & plic_data_r)				
				|
				({64{sysbus_slvRsp_valid}} & sysbus_data_r)	
				|
				({64{perip_slvRsp_valid}} & perip_data_r)	
				|
				({64{mem_slvRsp_valid}} & mem_data_r);


	assign dm_data_r  = arbi_data_r;
	assign ifu_data_r = arbi_data_r;
	assign lsu_data_r = arbi_data_r;

	assign arbi_Rsp = clint_slvRsp_valid | plic_slvRsp_valid | sysbus_slvRsp_valid | perip_slvRsp_valid | mem_slvRsp_valid;

	assign  dm_slvRsp_valid = isDMReq_qout & arbi_Rsp;
	assign ifu_slvRsp_valid = isIFUReq_qout & arbi_Rsp;
	assign lsu_slvRsp_valid = isLSUReq_qout & arbi_Rsp;



//    SSSSSSSSSSSSSSS LLLLLLLLLLL     VVVVVVVV           VVVVVVVV
//  SS:::::::::::::::SL:::::::::L     V::::::V           V::::::V
// S:::::SSSSSS::::::SL:::::::::L     V::::::V           V::::::V
// S:::::S     SSSSSSSLL:::::::LL     V::::::V           V::::::V
// S:::::S              L:::::L        V:::::V           V:::::V 
// S:::::S              L:::::L         V:::::V         V:::::V  
//  S::::SSSS           L:::::L          V:::::V       V:::::V   
//   SS::::::SSSSS      L:::::L           V:::::V     V:::::V    
//     SSS::::::::SS    L:::::L            V:::::V   V:::::V     
//        SSSSSS::::S   L:::::L             V:::::V V:::::V      
//             S:::::S  L:::::L              V:::::V:::::V       
//             S:::::S  L:::::L         LLLLLLV:::::::::V        
// SSSSSSS     S:::::SLL:::::::LLLLLLLLL:::::L V:::::::V         
// S::::::SSSSSS:::::SL::::::::::::::::::::::L  V:::::V          
// S:::::::::::::::SS L::::::::::::::::::::::L   V:::V           
//  SSSSSSSSSSSSSSS   LLLLLLLLLLLLLLLLLLLLLLLL    VVV            

	wire slv_ready;
	wire isReq;

	assign isReq = isDMReq_set | isIFUReq_set | isLSUReq_set;
	assign slv_ready = clint_mstReq_ready & plic_mstReq_ready & sysbus_mstReq_ready & perip_mstReq_ready & mem_mstReq_ready;
	assign arbi_addr = arbi_data_info_w[ 73 +:64 ];


	assign isDMReq_rst = clint_slvRsp_valid | plic_slvRsp_valid | sysbus_slvRsp_valid | perip_slvRsp_valid | mem_slvRsp_valid;
	assign isIFUReq_rst = clint_slvRsp_valid | plic_slvRsp_valid | sysbus_slvRsp_valid | perip_slvRsp_valid | mem_slvRsp_valid;
	assign isLSUReq_rst = clint_slvRsp_valid | plic_slvRsp_valid | sysbus_slvRsp_valid | perip_slvRsp_valid | mem_slvRsp_valid;


	assign clint_mstReq_valid = isReq & ((arbi_addr | 64'hFF_FFFF) == 64'h02FF_FFFF); //0x0200_0000~0x02ff_ffff
	assign plic_mstReq_valid = isReq & ((arbi_addr | 64'hFF_FFFF) == 64'h03FF_FFFF); //0x0300_0000~0x03ff_ffff
	assign sysbus_mstReq_valid = isReq & ((arbi_addr | 64'h3FFF_FFFF) == 64'h7FFF_FFFF); //0x4000_0000~0x7fff_ffff
	assign perip_mstReq_valid = isReq & ((arbi_addr | 64'h1FFF_FFFF) == 64'h3FFF_FFFF); //0x2000_0000~0x3fff_ffff
	assign mem_mstReq_valid = isReq & ((arbi_addr | 64'h7FFF_FFFF) == 64'hFFFF_FFFF); //0x8000_0000~0xffff_ffff

	assign { clint_addr, clint_data_w, clint_wstrb, clint_wen } = arbi_data_info_w;
	assign { plic_addr, plic_data_w, plic_wstrb, plic_wen } = arbi_data_info_w;
	assign { sysbus_addr, sysbus_data_w, sysbus_wstrb, sysbus_wen } = arbi_data_info_w;
	assign { perip_addr, perip_data_w, perip_wstrb, perip_wen } = arbi_data_info_w;
	assign { mem_addr, mem_data_w, mem_wstrb, mem_wen } = arbi_data_info_w;

	// assign clint_mstRsp_ready = 1'b1;
	// assign plic_mstRsp_ready = 1'b1;
	// assign sysbus_mstRsp_ready = 1'b1;
	// assign perip_mstRsp_ready = 1'b1;
	// assign mem_mstRsp_ready = 1'b1;



// assert


always @(posedge CLK) begin
	if ( (isDMReq_qout&isIFUReq_qout) | (isLSUReq_qout & (isDMReq_qout^isIFUReq_qout)) ) begin
		$display("Assert Fail at Xbar");
		$finish;
	end
end





endmodule








