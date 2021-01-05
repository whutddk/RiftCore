/*
* @File name: memory_bus
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 17:31:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:45:09
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



module memory_bus
(
	parameter SRAM_AW = 12
)
(

	input mem_mstReq_valid,
	input [63:0] mem_addr,
	input [63:0] mem_data_w,
	output [63:0] mem_data_r,
	input [7:0] mem_wstrb,
	input mem_wen,
	output mem_slvRsp_valid,

	input CLK,
	input RSTn
);


wire isSRAM;
wire isAXI;

wire [63:0] sram_addr;
wire [63:0] sram_data_r;
wire [63:0] sram_data_w;


wire [11:0] sram_addr_odd;
wire [11:0] sram_addr_eve;

wire [31:0] sram_data_odd_w;
wire [31:0] sram_data_eve_w;

wire [31:0] sram_data_odd_r;
wire [31:0] sram_data_eve_r;

wire [3:0] sram_wstrb_odd;
wire [3:0] sram_wstrb_eve;

wire sram_wen_odd;
wire sram_wen_eve;

wire sram_reAlign;


assign isSRAM = mem_mstReq_valid & ((mem_addr | 64'h0FFF_FFFF) == 64'H8FFF_FFFF);
assign isAXI  = mem_mstReq_valid & ((mem_addr | 64'h0FFF_FFFF) == 64'H9FFF_FFFF);
assign sram_reAlign = mem_addr[2];


assign mem_data_r = ({64{isSRAM}} & sram_data_r);
assign sram_data_r = (~sram_reAlign) ? {sram_data_odd_r, sram_data_eve_r} : {sram_data_eve_r, sram_data_odd_r}

assign sram_data_odd_w = (~sram_reAlign) ? mem_data_w[63:32] : mem_data_w[31:0];
assign sram_data_eve_w = (~sram_reAlign) ? mem_data_w[31:0] : mem_data_w[63:32];

assign sram_wstrb_odd = (~sram_reAlign) ? mem_wstrb[7:4] : mem_wstrb[3:0];
assign sram_wstrb_eve = (~sram_reAlign) ? mem_wstrb[3:0] : mem_wstrb[7:4];

assign sram_addr = isSRAM ? mem_addr : 64'b0;
assign sram_addr_odd = sram_addr[3 +: SRAM_AW]
assign sram_addr_eve = ( ~sram_reAlign ) ? sram_addr[3 +: SRAM_AW] : sram_addr[3 +: SRAM_AW] + 'd1;

assign sram_wen_odd = isSRAM & mem_wen;
assign sram_wen_eve = isSRAM & mem_wen;

gen_sram # ( .DW(32), .AW(SRAM_AW) ) i_sram_odd
(
	.data_w(sram_data_odd_w),
	.data_r(sram_data_odd_r),
	.data_wstrb(sram_wstrb_odd),
	.wen(sram_wen_odd),
	.addr(sram_addr_odd),

	.CLK(CLK),
	.RSTn(RSTn)
);

gen_sram # ( .DW(32), .AW(SRAM_AW) ) i_sram_eve
(
	.data_w(sram_data_eve_w),
	.data_r(sram_data_eve_r),
	.data_wstrb(sram_wstrb_eve),
	.wen(sram_wen_eve),
	.addr(sram_addr_eve),

	.CLK(CLK),
	.RSTn(RSTn)
);




gen_dffr # (.DW(1)) sram_handshake ( .dnxt(mem_mstReq_valid), .qout(mem_slvRsp_valid), .CLK(CLK), .RSTn(RSTn));






endmodule










