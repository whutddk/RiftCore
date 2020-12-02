/*
* @File name: system_crossBar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-02 09:45:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-02 16:23:41
*/

/*
	Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

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


module system_crossBar (

//INNER
	input S_INNER_AXI_ACLK,
	input S_INNER_AXI_ARESETN,

	input [7:0] S_INNER_AXI_AWID,
	input [63:0] S_INNER_AXI_AWADDR,
	input [7:0] S_INNER_AXI_AWLEN,
	input [2:0] S_INNER_AXI_AWSIZE,
	input [1:0] S_INNER_AXI_AWBURST,
	input S_INNER_AXI_AWLOCK,
	input [3:0] S_INNER_AXI_AWCACHE,
	input [2:0] S_INNER_AXI_AWPROT,
	input [3:0] S_INNER_AXI_AWQOS,
	input [3:0] S_INNER_AXI_AWREGION,
	input [7:0] S_INNER_AXI_AWUSER,
	input S_INNER_AXI_AWVALID,
	output S_INNER_AXI_AWREADY,

	input [63:0] S_INNER_AXI_WDATA,
	input [7:0] S_INNER_AXI_WSTRB,
	input S_INNER_AXI_WLAST,
	input [7:0] S_INNER_AXI_WUSER,
	input S_INNER_AXI_WVALID,
	output S_INNER_AXI_WREADY,

	output [7:0] S_INNER_AXI_BID,
	output [1:0] S_INNER_AXI_BRESP,
	output [7:0] S_INNER_AXI_BUSER,
	output S_INNER_AXI_BVALID,
	input S_INNER_AXI_BREADY,

	input [7:0] S_INNER_AXI_ARID,
	input [63:0] S_INNER_AXI_ARADDR,
	input [7:0] S_INNER_AXI_ARLEN,
	input [2:0] S_INNER_AXI_ARSIZE,
	input [1:0] S_INNER_AXI_ARBURST,
	input S_INNER_AXI_ARLOCK,
	input [3:0] S_INNER_AXI_ARCACHE,
	input [2:0] S_INNER_AXI_ARPROT,
	input [3:0] S_INNER_AXI_ARQOS,
	input [3:0] S_INNER_AXI_ARREGION,
	input [7 0] S_INNER_AXI_ARUSER,
	input S_INNER_AXI_ARVALID,
	output S_INNER_AXI_ARREADY,
	output [7:0] S_INNER_AXI_RID,

	output [63:0] S_INNER_AXI_RDATA,
	output [1:0] S_INNER_AXI_RRESP,
	output S_INNER_AXI_RLAST,
	output [7:0] S_INNER_AXI_RUSER,
	output S_INNER_AXI_RVALID,
	input S_INNER_AXI_RREADY,



//I-CACHE
	input S_ICACHE_AXI_ACLK,
	input S_ICACHE_AXI_ARESETN,

	input [7:0] S_ICACHE_AXI_AWID,
	input [63:0] S_ICACHE_AXI_AWADDR,
	input [7:0] S_ICACHE_AXI_AWLEN,
	input [2:0] S_ICACHE_AXI_AWSIZE,
	input [1:0] S_ICACHE_AXI_AWBURST,
	input S_ICACHE_AXI_AWLOCK,
	input [3:0] S_ICACHE_AXI_AWCACHE,
	input [2:0] S_ICACHE_AXI_AWPROT,
	input [3:0] S_ICACHE_AXI_AWQOS,
	input [3:0] S_ICACHE_AXI_AWREGION,
	input [7:0] S_ICACHE_AXI_AWUSER,
	input S_ICACHE_AXI_AWVALID,
	output S_ICACHE_AXI_AWREADY,

	input [63:0] S_ICACHE_AXI_WDATA,
	input [7:0] S_ICACHE_AXI_WSTRB,
	input S_ICACHE_AXI_WLAST,
	input [7:0] S_ICACHE_AXI_WUSER,
	input S_ICACHE_AXI_WVALID,
	output S_ICACHE_AXI_WREADY,

	output [7:0] S_ICACHE_AXI_BID,
	output [1:0] S_ICACHE_AXI_BRESP,
	output [7:0] S_ICACHE_AXI_BUSER,
	output S_ICACHE_AXI_BVALID,
	input S_ICACHE_AXI_BREADY,

	input [7:0] S_ICACHE_AXI_ARID,
	input [63:0] S_ICACHE_AXI_ARADDR,
	input [7:0] S_ICACHE_AXI_ARLEN,
	input [2:0] S_ICACHE_AXI_ARSIZE,
	input [1:0] S_ICACHE_AXI_ARBURST,
	input S_ICACHE_AXI_ARLOCK,
	input [3:0] S_ICACHE_AXI_ARCACHE,
	input [2:0] S_ICACHE_AXI_ARPROT,
	input [3:0] S_ICACHE_AXI_ARQOS,
	input [3:0] S_ICACHE_AXI_ARREGION,
	input [7 0] S_ICACHE_AXI_ARUSER,
	input S_ICACHE_AXI_ARVALID,
	output S_ICACHE_AXI_ARREADY,
	output [7:0] S_ICACHE_AXI_RID,

	output [63:0] S_ICACHE_AXI_RDATA,
	output [1:0] S_ICACHE_AXI_RRESP,
	output S_ICACHE_AXI_RLAST,
	output [7:0] S_ICACHE_AXI_RUSER,
	output S_ICACHE_AXI_RVALID,
	input S_ICACHE_AXI_RREADY,

	//D-CACHE
	input S_DCACHE_AXI_ACLK,
	input S_DCACHE_AXI_ARESETN,

	input [7:0] S_DCACHE_AXI_AWID,
	input [63:0] S_DCACHE_AXI_AWADDR,
	input [7:0] S_DCACHE_AXI_AWLEN,
	input [2:0] S_DCACHE_AXI_AWSIZE,
	input [1:0] S_DCACHE_AXI_AWBURST,
	input S_DCACHE_AXI_AWLOCK,
	input [3:0] S_DCACHE_AXI_AWCACHE,
	input [2:0] S_DCACHE_AXI_AWPROT,
	input [3:0] S_DCACHE_AXI_AWQOS,
	input [3:0] S_DCACHE_AXI_AWREGION,
	input [7:0] S_DCACHE_AXI_AWUSER,
	input S_DCACHE_AXI_AWVALID,
	output S_DCACHE_AXI_AWREADY,

	input [63:0] S_DCACHE_AXI_WDATA,
	input [7:0] S_DCACHE_AXI_WSTRB,
	input S_DCACHE_AXI_WLAST,
	input [7:0] S_DCACHE_AXI_WUSER,
	input S_DCACHE_AXI_WVALID,
	output S_DCACHE_AXI_WREADY,

	output [7:0] S_DCACHE_AXI_BID,
	output [1:0] S_DCACHE_AXI_BRESP,
	output [7:0] S_DCACHE_AXI_BUSER,
	output S_DCACHE_AXI_BVALID,
	input S_DCACHE_AXI_BREADY,

	input [7:0] S_DCACHE_AXI_ARID,
	input [63:0] S_DCACHE_AXI_ARADDR,
	input [7:0] S_DCACHE_AXI_ARLEN,
	input [2:0] S_DCACHE_AXI_ARSIZE,
	input [1:0] S_DCACHE_AXI_ARBURST,
	input S_DCACHE_AXI_ARLOCK,
	input [3:0] S_DCACHE_AXI_ARCACHE,
	input [2:0] S_DCACHE_AXI_ARPROT,
	input [3:0] S_DCACHE_AXI_ARQOS,
	input [3:0] S_DCACHE_AXI_ARREGION,
	input [7 0] S_DCACHE_AXI_ARUSER,
	input S_DCACHE_AXI_ARVALID,
	output S_DCACHE_AXI_ARREADY,
	output [7:0] S_DCACHE_AXI_RID,

	output [63:0] S_DCACHE_AXI_RDATA,
	output [1:0] S_DCACHE_AXI_RRESP,
	output S_DCACHE_AXI_RLAST,
	output [7:0] S_DCACHE_AXI_RUSER,
	output S_DCACHE_AXI_RVALID,
	input S_DCACHE_AXI_RREADY,




//system bus
	input M_SYS_AXI_ACLK,
	input M_SYS_AXI_ARESETN,

	output [7:0] M_SYS_AXI_AWID,
	output [63:0] M_SYS_AXI_AWADDR,
	output [7:0] M_SYS_AXI_AWLEN,
	output [2:0] M_SYS_AXI_AWSIZE,
	output [1:0] M_SYS_AXI_AWBURST,
	output M_SYS_AXI_AWLOCK,
	output [3:0] M_SYS_AXI_AWCACHE,
	output [2:0] M_SYS_AXI_AWPROT,
	output [3:0] M_SYS_AXI_AWQOS,
	output [7:0] M_SYS_AXI_AWUSER,
	output M_SYS_AXI_AWVALID,
	input M_SYS_AXI_AWREADY,
	output [63:0] M_SYS_AXI_WDATA,
	output [7:0] M_SYS_AXI_WSTRB,
	output M_SYS_AXI_WLAST,
	output [7:0] M_SYS_AXI_WUSER,
	output M_SYS_AXI_WVALID,
	input M_SYS_AXI_WREADY,
	input [7:0] M_SYS_AXI_BID,
	input [1:0] M_SYS_AXI_BRESP,
	input [7:0] M_SYS_AXI_BUSER,
	input M_SYS_AXI_BVALID,
	output M_SYS_AXI_BREADY,
	output [7:0] M_SYS_AXI_ARID,
	output [63:0] M_SYS_AXI_ARADDR,
	output [7:0] M_SYS_AXI_ARLEN,
	output [2:0] M_SYS_AXI_ARSIZE,
	output [1:0] M_SYS_AXI_ARBURST,
	output M_SYS_AXI_ARLOCK,
	output [3:0] M_SYS_AXI_ARCACHE,
	output [2:0] M_SYS_AXI_ARPROT,
	output [3:0] M_SYS_AXI_ARQOS,
	output [7:0] M_SYS_AXI_ARUSER,
	output M_SYS_AXI_ARVALID,
	input M_SYS_AXI_ARREADY,
	input [7:0] M_SYS_AXI_RID,
	input [63 0] M_SYS_AXI_RDATA,
	input [1:0] M_SYS_AXI_RRESP,
	input M_SYS_AXI_RLAST,
	input [7 0] M_SYS_AXI_RUSER,
	input M_SYS_AXI_RVALID,
	output M_SYS_AXI_RREADY,


//MEMORY bus
	input M_MEM_AXI_ACLK,
	input M_MEM_AXI_ARESETN,

	output [7:0] M_MEM_AXI_AWID,
	output [63:0] M_MEM_AXI_AWADDR,
	output [7:0] M_MEM_AXI_AWLEN,
	output [2:0] M_MEM_AXI_AWSIZE,
	output [1:0] M_MEM_AXI_AWBURST,
	output M_MEM_AXI_AWLOCK,
	output [3:0] M_MEM_AXI_AWCACHE,
	output [2:0] M_MEM_AXI_AWPROT,
	output [3:0] M_MEM_AXI_AWQOS,
	output [7:0] M_MEM_AXI_AWUSER,
	output M_MEM_AXI_AWVALID,
	input M_MEM_AXI_AWREADY,
	output [63:0] M_MEM_AXI_WDATA,
	output [7:0] M_MEM_AXI_WSTRB,
	output M_MEM_AXI_WLAST,
	output [7:0] M_MEM_AXI_WUSER,
	output M_MEM_AXI_WVALID,
	input M_MEM_AXI_WREADY,
	input [7:0] M_MEM_AXI_BID,
	input [1:0] M_MEM_AXI_BRESP,
	input [7:0] M_MEM_AXI_BUSER,
	input M_MEM_AXI_BVALID,
	output M_MEM_AXI_BREADY,
	output [7:0] M_MEM_AXI_ARID,
	output [63:0] M_MEM_AXI_ARADDR,
	output [7:0] M_MEM_AXI_ARLEN,
	output [2:0] M_MEM_AXI_ARSIZE,
	output [1:0] M_MEM_AXI_ARBURST,
	output M_MEM_AXI_ARLOCK,
	output [3:0] M_MEM_AXI_ARCACHE,
	output [2:0] M_MEM_AXI_ARPROT,
	output [3:0] M_MEM_AXI_ARQOS,
	output [7:0] M_MEM_AXI_ARUSER,
	output M_MEM_AXI_ARVALID,
	input M_MEM_AXI_ARREADY,
	input [7:0] M_MEM_AXI_RID,
	input [63 0] M_MEM_AXI_RDATA,
	input [1:0] M_MEM_AXI_RRESP,
	input M_MEM_AXI_RLAST,
	input [7 0] M_MEM_AXI_RUSER,
	input M_MEM_AXI_RVALID,
	output M_MEM_AXI_RREADY,

//perip bus
	output [7:0] M_PERIP_AXI_AWADDR,
	output [2:0] M_PERIP_AXI_AWPROT,
	output M_PERIP_AXI_AWVALID,
	input M_PERIP_AXI_AWREADY,

	output [31:0] M_PERIP_AXI_WDATA,
	output [3:0] M_PERIP_AXI_WSTRB,
	output M_PERIP_AXI_WVALID,
	input M_PERIP_AXI_WREADY,

	input [1:0] M_PERIP_AXI_BRESP,
	input M_PERIP_AXI_BVALID,
	output M_PERIP_AXI_BREADY,

	output [7:0] M_PERIP_AXI_ARADDR,
	output [2:0] M_PERIP_AXI_ARPROT,
	output M_PERIP_AXI_ARVALID,
	input M_AXI_ARREADY,

	input [31:0] M_PERIP_AXI_RDATA,
	input [1:0] M_PERIP_AXI_RRESP,
	input M_PERIP_AXI_RVALID,
	output M_PERIP_AXI_RREADY	
);

endmodule













