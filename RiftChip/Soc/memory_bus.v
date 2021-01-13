/*
* @File name: memory_bus
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 17:31:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-13 17:44:57
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



module memory_bus #
(
	parameter SRAM_AW = 11
)
(

	input mem_mstReq_valid,
	input [63:0] mem_addr,
	input [63:0] mem_data_w,
	output [63:0] mem_data_r,
	input [7:0] mem_wstrb,
	output mem_slvRsp_valid,

	input CLK,
	input RSTn
);

wire isSRAM_dnxt;
wire isSRAM_qout;

wire isAXI_dnxt;
wire isAXI_qout;

wire [63:0] sram_addr;
wire [127:0] sram_data_r;
wire [127:0] sram_data_w;
wire [15:0] sram_wstrb;

wire [10:0] sram_addr_odd;
wire [10:0] sram_addr_eve;

wire [63:0] sram_data_odd_w;
wire [63:0] sram_data_eve_w;

wire [63:0] sram_data_odd_r;
wire [63:0] sram_data_eve_r;

wire [7:0] sram_wstrb_odd;
wire [7:0] sram_wstrb_eve;

wire sram_wen_odd;
wire sram_wen_eve;

wire sram_reAlign_dnxt;
wire sram_reAlign_qout;

wire [2:0] addr_shift_dnxt;
wire [2:0] addr_shift_qout;
wire [2:0] byte_shift_dnxt;
wire [2:0] byte_shift_qout;

assign isSRAM_dnxt = (mem_addr | 64'h0FFF_FFFF) == 64'h8FFF_FFFF;
assign isAXI_dnxt  = (mem_addr | 64'h0FFF_FFFF) == 64'h9FFF_FFFF;
assign sram_reAlign_dnxt = mem_addr[3];
assign addr_shift_dnxt = mem_addr[2:0];
assign byte_shift_dnxt = addr_shift_dnxt << 3;
assign byte_shift_qout = addr_shift_qout << 3;

gen_dffren # (.DW(1)) isSRAM_dffren ( .dnxt(isSRAM_dnxt), .qout(isSRAM_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn) );
gen_dffren # (.DW(1)) isAXI_dffren ( .dnxt(isAXI_dnxt), .qout(isAXI_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn) );
gen_dffren # (.DW(1)) sram_reAlign_dffren ( .dnxt(sram_reAlign_dnxt), .qout(sram_reAlign_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn));
gen_dffren # (.DW(3)) addr_shift_dffren ( .dnxt(addr_shift_dnxt), .qout(addr_shift_qout), .en(mem_mstReq_valid), .CLK(CLK), .RSTn(RSTn));


assign mem_data_r = ({64{isSRAM_qout}} & sram_data_r[ byte_shift_qout +: 64]);
assign sram_data_r = (~sram_reAlign_qout) ? {sram_data_odd_r, sram_data_eve_r} : {sram_data_eve_r, sram_data_odd_r};


assign sram_data_w = mem_data_w << (byte_shift_dnxt);
assign sram_data_odd_w = (~sram_reAlign_dnxt) ? sram_data_w[127:64] : sram_data_w[63:0];
assign sram_data_eve_w = (~sram_reAlign_dnxt) ? sram_data_w[63:0] : sram_data_w[127:64];

assign sram_wstrb = mem_wstrb << (addr_shift_dnxt);
assign sram_wstrb_odd = ((~sram_reAlign_dnxt) ? sram_wstrb[15:8] : sram_wstrb[7:0]);
assign sram_wstrb_eve = ((~sram_reAlign_dnxt) ? sram_wstrb[7:0] : sram_wstrb[15:8]);


assign sram_addr = isSRAM_dnxt ? mem_addr : 64'b0;
assign sram_addr_odd = sram_addr[4 +: SRAM_AW];
assign sram_addr_eve = ( ~sram_reAlign_dnxt ) ? sram_addr[4 +: SRAM_AW] : sram_addr[4 +: SRAM_AW] + 'd1;


gen_sram # ( .DW(64), .AW(SRAM_AW) ) i_sram_odd
(
	.data_w(sram_data_odd_w),
	.data_r(sram_data_odd_r),
	.data_wstrb(sram_wstrb_odd),
	.en(isSRAM_dnxt),
	.addr(sram_addr_odd),

	.CLK(CLK)
);

gen_sram # ( .DW(64), .AW(SRAM_AW) ) i_sram_eve
(
	.data_w(sram_data_eve_w),
	.data_r(sram_data_eve_r),
	.data_wstrb(sram_wstrb_eve),
	.en(isSRAM_dnxt),
	.addr(sram_addr_eve),

	.CLK(CLK)
);




gen_dffr # (.DW(1)) sram_handshake ( .dnxt(mem_mstReq_valid), .qout(mem_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));






endmodule










