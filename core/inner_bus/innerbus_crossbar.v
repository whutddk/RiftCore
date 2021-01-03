/*
* @File name: innerbus_crossbar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-31 17:04:44
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:04:36
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
	output dm_mstReq_valid,
	input dm_slvReq_ready,
	output [63:0] dm_addr,
	output [63:0] dm_data_w,
	input [63:0] dm_data_r,
	output [7:0] dm_wstrb,

	input dm_slvRsp_valid,
	output dm_mstRsp_ready,

	//LSU
	output lsu_mstReq_valid,
	input lsu_slvReq_ready,
	output [63:0] lsu_addr,
	output [63:0] lsu_data_w,
	input [63:0] lsu_data_r,
	output [7:0] lsu_wstrb,

	input lsu_slvRsp_valid,
	output lsu_mstRsp_ready,

	//IFU
	output ifu_mstReq_valid,
	input ifu_slvReq_ready,
	output [63:0] ifu_addr,
	output [63:0] ifu_data_w,
	input [63:0] ifu_data_r,
	output [7:0] ifu_wstrb,

	input ifu_slvRsp_valid,
	output ifu_mstRsp_ready,






	//CLINT
	input clint_mstReq_valid,
	output clint_slvReq_ready,
	input [63:0] clint_addr,
	input [63:0] clint_data_w,
	output [63:0] clint_data_r,
	input [7:0] clint_wstrb,

	output clint_slvRsp_valid,
	input clint_mstRsp_ready,

	//PLIC
	input plic_mstReq_valid,
	output plic_slvReq_ready,
	input [63:0] plic_addr,
	input [63:0] plic_data_w,
	output [63:0] plic_data_r,
	input [7:0] plic_wstrb,

	output plic_slvRsp_valid,
	input plic_mstRsp_ready,


	//system bus
	input sysbus_mstReq_valid,
	output sysbus_slvReq_ready,
	input [63:0] sysbus_addr,
	input [63:0] sysbus_data_w,
	output [63:0] sysbus_data_r,
	input [7:0] sysbus_wstrb,

	output sysbus_slvRsp_valid,
	input sysbus_mstRsp_ready,

	//peripherals bus
	input perip_mstReq_valid,
	output perip_slvReq_ready,
	input [63:0] perip_addr,
	input [63:0] perip_data_w,
	output [63:0] perip_data_r,
	input [7:0] perip_wstrb,

	output perip_slvRsp_valid,
	input perip_mstRsp_ready,

	//mem bus
	input mem_mstReq_valid,
	output mem_slvReq_ready,
	input [63:0] mem_addr,
	input [63:0] mem_data_w,
	output [63:0] mem_data_r,
	input [7:0] mem_wstrb,

	output mem_slvRsp_valid,
	input mem_mstRsp_ready,
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

wire [63:0] arbi_addr = 

assign isClintInUsed_set = isReq & 
assign isPlicInUsed_set = isReq & 
assign isSysbusInUsed_set = isReq & 
assign isPeripbusInUsed_set = isReq & 
assign isMembusInUsed_set = isReq & 







endmodule








