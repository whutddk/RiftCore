/*
* @File name: innerbus_crossbar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-31 17:04:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 10:54:16
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
	input dm_mstReq_valid,
	input [63:0] dm_addr,
	input [63:0] dm_data_w,
	output [63:0] dm_data_r,
	input [7:0] dm_wstrb,
	input dm_wen,

	output dm_slvRsp_valid,
	// input dm_mstRsp_ready,

	//LSU
	input lsu_mstReq_valid,
	input [63:0] lsu_addr,
	input [63:0] lsu_data_w,
	output [63:0] lsu_data_r,
	input [7:0] lsu_wstrb,
	input lsu_wen,

	output lsu_slvRsp_valid,
	// input lsu_mstRsp_ready,

	//IFU
	input ifu_mstReq_valid,
	input [63:0] ifu_addr,
	input [63:0] ifu_data_w,
	output [63:0] ifu_data_r,
	input [7:0] ifu_wstrb,
	input ifu_wen,

	output ifu_slvRsp_valid,
	// input ifu_mstRsp_ready,






	//CLINT
	output clint_mstReq_valid,
	output [63:0] clint_addr,
	output [63:0] clint_data_w,
	input [63:0] clint_data_r,
	output [7:0] clint_wstrb,
	output clint_wen,

	input clint_slvRsp_valid,
	// output clint_mstRsp_ready,

	//PLIC
	output plic_mstReq_valid,
	output [63:0] plic_addr,
	output [63:0] plic_data_w,
	input [63:0] plic_data_r,
	output [7:0] plic_wstrb,
	output plic_wen,

	input plic_slvRsp_valid,
	// output plic_mstRsp_ready,


	//system bus
	output sysbus_mstReq_valid,
	output [63:0] sysbus_addr,
	output [63:0] sysbus_data_w,
	input [63:0] sysbus_data_r,
	output [7:0] sysbus_wstrb,
	output sysbus_wen,

	input sysbus_slvRsp_valid,
	// output sysbus_mstRsp_ready,

	//peripherals bus
	output perip_mstReq_valid,
	output [63:0] perip_addr,
	output [63:0] perip_data_w,
	input [63:0] perip_data_r,
	output [7:0] perip_wstrb,
	output perip_wen,

	input perip_slvRsp_valid,
	// output perip_mstRsp_ready,

	//mem bus
	output mem_mstReq_valid,
	output [63:0] mem_addr,
	output [63:0] mem_data_w,
	input [63:0] mem_data_r,
	output [7:0] mem_wstrb,
	output mem_wen,

	input mem_slvRsp_valid,
	// output mem_mstRsp_ready,
);


	//mst dm ifu lsu
	//slv clint plic sys-bus perip-bus mem-bus

	wire isClintInUsed_set;
	wire isPlicInUsed_set;
	wire isSysbusInUsed_set;
	wire isPeripbusInUsed_set;
	wire isMembusInUsed_set;
	wire isClintInUsed_rst;
	wire isPlicInUsed_rst;
	wire isSysbusInUsed_rst;
	wire isPeripbusInUsed_rst;
	wire isMembusInUsed_rst;
	wire isClintInUsed_qout;
	wire isPlicInUsed_qout;
	wire isSysbusInUsed_qout;
	wire isPeripbusInUsed_qout;
	wire isMembusInUsed_qout;


	wire isReq;
	wire isDMReq_set;
	wire isIFUReq_set;
	wire isLSUReq_set;
	wire isDMReq_rst;
	wire isIFUReq_rst;
	wire isLSUReq_rst;
	wire isDMReq_qout;
	wire isIFUReq_qout;
	wire isLSUReq_qout;


	assign isDMReq_set = dm_mstReq_valid;
	assign isIFUReq_set = ~dm_mstReq_valid & ifu_mstReq_valid;
	assign isLSUReq_set = ~dm_mstReq_valid & ~ifu_mstReq_valid & lsu_mstReq_valid;
	assign isReq = isDMReq_set | isIFUReq_set | isLSUReq_set;

	wire [63:0] arbi_addr = ({64{isDMReq_set}} & dm_addr)
							|
							({64{isIFUReq_set}} & ifu_addr)
							|
							({64{isLSUReq_set}} & lsu_addr);

	wire [63:0] arbi_data_w = 
					({64{isDMReq_set}} & dm_data_w)
					|
					({64{isIFUReq_set}} & ifu_data_w)
					|
					({64{isLSUReq_set}} & lsu_data_w);


	wire [7:0] arbi_wstrb = 
					({8{isDMReq_set}} & dm_wstrb)
					|
					({8{isIFUReq_set}} & ifu_wstrb)
					|
					({8{isLSUReq_set}} & lsu_wstrb);

	wire arbi_wen = 
					( isDMReq_set & dm_wen)
					|
					( isIFUReq_set & ifu_wen)
					|
					( isLSUReq_set & lsu_wen);

	assign clint_mstReq_valid = isReq & ((arbi_addr | 64'hFF_FFFF) == 64'h02FF_FFFF); //0x0200_0000~0x02ff_ffff
	assign plic_mstReq_valid = isReq & ((arbi_addr | 64'hFF_FFFF) == 64'h03FF_FFFF); //0x0300_0000~0x03ff_ffff
	assign sysbus_mstReq_valid = isReq & ((arbi_addr | 64'h3FFF_FFFF) == 64'h7FFF_FFFF); //0x4000_0000~0x7fff_ffff
	assign perip_mstReq_valid = isReq & ((arbi_addr | 64'h1FFF_FFFF) == 64'h3FFF_FFFF); //0x2000_0000~0x3fff_ffff
	assign mem_mstReq_valid = isReq & ((arbi_addr | 64'h7FFF_FFFF) == 64'hFFFF_FFFF); //0x8000_0000~0xffff_ffff





	wire [63:0] arbi_data_r = 
				({64{clint_mstReq_valid & clint_slvRsp_valid}} & clint_data_r)
				|
				({64{plic_mstReq_valid & plic_slvRsp_valid}} & plic_data_r)
				|
				({64{sysbus_mstReq_valid & sysbus_slvRsp_valid}} & sysbus_data_r)
				|
				({64{perip_mstReq_valid & perip_slvRsp_valid}} & perip_data_r)
				|
				({64{mem_mstReq_valid & mem_slvRsp_valid}} & mem_data_r);


	wire arbi_rsp_valid = clint_slvRsp_valid | plic_slvRsp_valid | sysbus_slvRsp_valid | perip_slvRsp_valid | mem_slvRsp_valid;
	// wire arbi_mstrsp_ready = 
	// 			(isDMReq_set & dm_mstRsp_ready)
	// 			|
	// 			(isIFUReq_set & ifu_mstRsp_ready)
	// 			|
	// 			(isLSUReq_set & lsu_mstRsp_ready);



	assign clint_addr = {64{clint_mstReq_valid}} & arbi_addr;
	assign plic_addr = {64{plic_mstReq_valid}} & arbi_addr;
	assign sysbus_addr = {64{sysbus_mstReq_valid}} & arbi_addr;
	assign perip_addr = {64{perip_mstReq_valid}} & arbi_addr;
	assign mem_addr = {64{mem_mstReq_valid}} & arbi_addr;

	assign clint_data_w = {64{clint_mstReq_valid}} & arbi_data_w;
	assign plic_data_w = {64{plic_mstReq_valid}} & arbi_data_w;
	assign sysbus_data_w = {64{sysbus_mstReq_valid}} & arbi_data_w;
	assign perip_data_w = {64{perip_mstReq_valid}} & arbi_data_w;
	assign mem_data_w = {64{mem_mstReq_valid}} & arbi_data_w;

	assign clint_wstrb = {8{clint_mstReq_valid}} & arbi_wstrb;
	assign plic_wstrb = {8{plic_mstReq_valid}} & arbi_wstrb;
	assign sysbus_wstrb = {8{sysbus_mstReq_valid}} & arbi_wstrb;
	assign perip_wstrb = {8{perip_mstReq_valid}} & arbi_wstrb;
	assign mem_wstrb = {8{mem_mstReq_valid}} & arbi_wstrb;


	assign clint_wen = clint_mstReq_valid & arbi_wen;
	assign plic_wen = plic_mstReq_valid & arbi_wen;
	assign sysbus_wen = sysbus_mstReq_valid & arbi_wen;
	assign perip_wen = perip_mstReq_valid & arbi_wen;
	assign mem_wen = mem_mstReq_valid & arbi_wen;






	assign dm_slvRsp_valid = arbi_rsp_valid & isDMReq_set;
	assign lsu_slvRsp_valid = arbi_rsp_valid & isLSUReq_set;
	assign ifu_slvRsp_valid = arbi_rsp_valid & isIFUReq_set;



	// assign clint_mstRsp_ready = arbi_mstrsp_ready & clint_mstReq_valid;
	// assign plic_mstRsp_ready = arbi_mstrsp_ready & plic_mstReq_valid;
	// assign sysbus_mstRsp_ready = arbi_mstrsp_ready & sysbus_mstReq_valid;
	// assign perip_mstRsp_ready = arbi_mstrsp_ready & perip_mstReq_valid;
	// assign mem_mstRsp_ready = arbi_mstrsp_ready & mem_mstReq_valid;





endmodule








