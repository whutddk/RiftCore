/*
* @File name: riftChip
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 16:48:50
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-13 19:11:19
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


module riftChip (

	input CLK,
	input RSTn
);


	wire mem_mstReq_valid;
	wire [63:0] mem_addr;
	wire [63:0] mem_data_w;
	wire [63:0] mem_data_r;
	wire [7:0] mem_wstrb;
	wire mem_wen;
	wire mem_slvRsp_valid;


	wire ifu_mstReq_valid;
	wire [63:0] ifu_addr;
	wire [63:0] ifu_data_r;
	wire ifu_slvRsp_valid;

	wire lsu_mstReq_valid;
	wire [63:0] lsu_addr;
	wire [63:0] lsu_data_w;
	wire [63:0] lsu_data_r;
	wire [7:0] lsu_wstrb;
	wire lsu_slvRsp_valid;



riftCore i_riftCore(
	
	.isExternInterrupt(1'b0),
	.isRTimerInterrupt(1'b0),
	.isSoftwvInterrupt(1'b0),

	.ifu_mstReq_valid(ifu_mstReq_valid),
	.ifu_addr(ifu_addr),
	.ifu_data_r(ifu_data_r),
	.ifu_slvRsp_valid(ifu_slvRsp_valid),

	.lsu_mstReq_valid(lsu_mstReq_valid),
	.lsu_addr(lsu_addr),
	.lsu_data_w(lsu_data_w),
	.lsu_data_r(lsu_data_r),
	.lsu_wstrb(lsu_wstrb),
	.lsu_slvRsp_valid(lsu_slvRsp_valid),

	.CLK(CLK),
	.RSTn(RSTn)
	
);


memory_bus i_memory_bus
(

  .mem_mstReq_valid(ifu_mstReq_valid),
  .mem_addr(ifu_addr),
  .mem_data_w(64'b0),
  .mem_data_r(ifu_data_r),
  .mem_wstrb(8'b0),
  .mem_slvRsp_valid(ifu_slvRsp_valid),

  .CLK(CLK),
  .RSTn(RSTn)
);


memory_bus i_memory_bus2
(

  .mem_mstReq_valid(lsu_mstReq_valid),
  .mem_addr(lsu_addr),
  .mem_data_w(lsu_data_w),
  .mem_data_r(lsu_data_r),
  .mem_wstrb(lsu_wstrb),
  .mem_slvRsp_valid(lsu_slvRsp_valid),

  .CLK(CLK),
  .RSTn(RSTn)
);






// innerbus_crossbar i_Xbar(

// 	.dm_mstReq_valid(1'b0),
// 	.dm_addr(64'b0),
// 	.dm_data_w(64'b0),
// 	.dm_data_r(),
// 	.dm_wstrb(8'b0),
// 	.dm_wen(1'b0),
// 	.dm_slvRsp_valid(),

// 	.lsu_mstReq_valid(1'b0),
// 	.lsu_addr(64'b0),
// 	.lsu_data_w(64'b0),
// 	.lsu_data_r(),
// 	.lsu_wstrb(8'b0),
// 	.lsu_wen(1'b0),
// 	.lsu_slvRsp_valid(),

// 	.ifu_mstReq_valid(ifu_mstReq_valid),
// 	.ifu_addr(ifu_addr),
// 	.ifu_data_w(64'b0),
// 	.ifu_data_r(ifu_data_r),
// 	.ifu_wstrb(8'b0),
// 	.ifu_wen(1'b0),
// 	.ifu_slvRsp_valid(ifu_slvRsp_valid),



// 	.clint_mstReq_valid(),
// 	.clint_addr(),
// 	.clint_data_w(),
// 	.clint_data_r(64'b0),
// 	.clint_wstrb(),
// 	.clint_wen(),
// 	.clint_slvRsp_valid(1'b1),

// 	.plic_mstReq_valid(),
// 	.plic_addr(),
// 	.plic_data_w(),
// 	.plic_data_r(64'b0),
// 	.plic_wstrb(),
// 	.plic_wen(),
// 	.plic_slvRsp_valid(1'b1),

// 	.sysbus_mstReq_valid(),
// 	.sysbus_addr(),
// 	.sysbus_data_w(),
// 	.sysbus_data_r(64'b0),
// 	.sysbus_wstrb(),
// 	.sysbus_wen(),
// 	.sysbus_slvRsp_valid(1'b1),

// 	.perip_mstReq_valid(),
// 	.perip_addr(),
// 	.perip_data_w(),
// 	.perip_data_r(64'b0),
// 	.perip_wstrb(),
// 	.perip_wen(),
// 	.perip_slvRsp_valid(1'b1),

// 	.mem_mstReq_valid(mem_mstReq_valid),
// 	.mem_addr(mem_addr),
// 	.mem_data_w(mem_data_w),
// 	.mem_data_r(mem_data_r),
// 	.mem_wstrb(mem_wstrb),
// 	.mem_wen(mem_wen),
// 	.mem_slvRsp_valid(mem_slvRsp_valid)

// );





endmodule






