/*
* @File name: riftChip
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 16:48:50
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-15 15:55:51
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


	wire [63:0] IFU_ARADDR;
	wire [2:0] IFU_ARPROT;
	wire IFU_ARVALID;
	wire IFU_ARREADY;
	wire [63:0] IFU_RDATA;
	wire [1:0] IFU_RRESP;
	wire IFU_RVALID;
	wire IFU_RREADY;

	wire [63:0] LSU_AWADDR;
	wire [2:0] LSU_AWPROT;
	wire LSU_AWVALID;
	wire LSU_AWREADY;
	wire [63:0] LSU_WDATA;
	wire [7:0] LSU_WSTRB;
	wire LSU_WVALID;
	wire LSU_WREADY;
	wire [1:0] LSU_BRESP;
	wire LSU_BVALID;
	wire LSU_BREADY;
	wire [63:0] LSU_ARADDR;
	wire [2:0] LSU_ARPROT;
	wire LSU_ARVALID;
	wire LSU_ARREADY;
	wire [63:0] LSU_RDATA;
	wire [1:0] LSU_RRESP;
	wire LSU_RVALID;
	wire LSU_RREADY;



riftCore i_riftCore(
	
	.isExternInterrupt(1'b0),
	.isRTimerInterrupt(1'b0),
	.isSoftwvInterrupt(1'b0),

	.IFU_ARADDR(IFU_ARADDR),
	.IFU_ARPROT(IFU_ARPROT),
	.IFU_ARVALID(IFU_ARVALID),
	.IFU_ARREADY(IFU_ARREADY),
	.IFU_RDATA(IFU_RDATA),
	.IFU_RRESP(IFU_RRESP),
	.IFU_RVALID(IFU_RVALID),
	.IFU_RREADY(IFU_RREADY),

	.LSU_AWADDR(LSU_AWADDR),
	.LSU_AWPROT(LSU_AWPROT),
	.LSU_AWVALID(LSU_AWVALID),
	.LSU_AWREADY(LSU_AWREADY),
	.LSU_WDATA(LSU_WDATA),
	.LSU_WSTRB(LSU_WSTRB),
	.LSU_WVALID(LSU_WVALID),
	.LSU_WREADY(LSU_WREADY),
	.LSU_BRESP(LSU_BRESP),
	.LSU_BVALID(LSU_BVALID),
	.LSU_BREADY(LSU_BREADY),
	.LSU_ARADDR(LSU_ARADDR),
	.LSU_ARPROT(LSU_ARPROT),
	.LSU_ARVALID(LSU_ARVALID),
	.LSU_ARREADY(LSU_ARREADY),
	.LSU_RDATA(LSU_RDATA),
	.LSU_RRESP(LSU_RRESP),
	.LSU_RVALID(LSU_RVALID),
	.LSU_RREADY(LSU_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
	
);


axi_ccm i_axi_iccm(

	.S_AXI_AWADDR(64'b0),
	.S_AXI_AWVALID(1'b0),
	.S_AXI_AWREADY(),
	.S_AXI_WDATA(64'b0),   
	.S_AXI_WSTRB(8'b0),
	.S_AXI_WVALID(1'b0),
	.S_AXI_WREADY(),
	.S_AXI_BRESP(),
	.S_AXI_BVALID(),
	.S_AXI_BREADY(1'b1),

	.S_AXI_ARADDR(IFU_ARADDR),
	.S_AXI_ARVALID(IFU_ARVALID),
	.S_AXI_ARREADY(IFU_ARREADY),
	.S_AXI_RDATA(IFU_RDATA),
	.S_AXI_RRESP(IFU_RRESP),
	.S_AXI_RVALID(IFU_RVALID),
	.S_AXI_RREADY(IFU_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
);





axi_ccm i_axi_dccm(
	.S_AXI_AWADDR(LSU_AWADDR),
	.S_AXI_AWVALID(LSU_AWVALID),
	.S_AXI_AWREADY(LSU_AWREADY),
	.S_AXI_WDATA(LSU_WDATA),   
	.S_AXI_WSTRB(LSU_WSTRB),
	.S_AXI_WVALID(LSU_WVALID),
	.S_AXI_WREADY(LSU_WREADY),
	.S_AXI_BRESP(LSU_BRESP),
	.S_AXI_BVALID(LSU_BVALID),
	.S_AXI_BREADY(LSU_BREADY),
	.S_AXI_ARADDR(LSU_ARADDR),
	.S_AXI_ARVALID(LSU_ARVALID),
	.S_AXI_ARREADY(LSU_ARREADY),
	.S_AXI_RDATA(LSU_RDATA),
	.S_AXI_RRESP(LSU_RRESP),
	.S_AXI_RVALID(LSU_RVALID),
	.S_AXI_RREADY(LSU_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
);




endmodule






