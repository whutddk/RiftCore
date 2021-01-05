/*
* @File name: inner_crossBar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-02 14:51:36
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:03:55
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


module inner_crossBar (

	// master








// IIIIIIIIII     FFFFFFFFFFFFFFFFFFFFFF     UUUUUUUU     UUUUUUUU
// I::::::::I     F::::::::::::::::::::F     U::::::U     U::::::U
// I::::::::I     F::::::::::::::::::::F     U::::::U     U::::::U
// II::::::II     FF::::::FFFFFFFFF::::F     UU:::::U     U:::::UU
//   I::::I         F:::::F       FFFFFF      U:::::U     U:::::U 
//   I::::I         F:::::F                   U:::::D     D:::::U 
//   I::::I         F::::::FFFFFFFFFF         U:::::D     D:::::U 
//   I::::I         F:::::::::::::::F         U:::::D     D:::::U 
//   I::::I         F:::::::::::::::F         U:::::D     D:::::U 
//   I::::I         F::::::FFFFFFFFFF         U:::::D     D:::::U 
//   I::::I         F:::::F                   U:::::D     D:::::U 
//   I::::I         F:::::F                   U::::::U   U::::::U 
// II::::::II     FF:::::::FF                 U:::::::UUU:::::::U 
// I::::::::I     F::::::::FF                  UU:::::::::::::UU  
// I::::::::I     F::::::::FF                    UU:::::::::UU    
// IIIIIIIIII     FFFFFFFFFFF                      UUUUUUUUU      

	input [63:0] S_IFU_AXI_ARADDR,
	input S_IFU_AXI_ARVALID,
	output S_IFU_AXI_ARREADY,

	output [31:0] S_IFU_AXI_RDATA,
	output [1:0] S_IFU_AXI_RRESP,
	output S_IFU_AXI_RVALID,
	input S_IFU_AXI_RREADY,


// LLLLLLLLLLL                SSSSSSSSSSSSSSS UUUUUUUU     UUUUUUUU
// L:::::::::L              SS:::::::::::::::SU::::::U     U::::::U
// L:::::::::L             S:::::SSSSSS::::::SU::::::U     U::::::U
// LL:::::::LL             S:::::S     SSSSSSSUU:::::U     U:::::UU
//   L:::::L               S:::::S             U:::::U     U:::::U 
//   L:::::L               S:::::S             U:::::D     D:::::U 
//   L:::::L                S::::SSSS          U:::::D     D:::::U 
//   L:::::L                 SS::::::SSSSS     U:::::D     D:::::U 
//   L:::::L                   SSS::::::::SS   U:::::D     D:::::U 
//   L:::::L                      SSSSSS::::S  U:::::D     D:::::U 
//   L:::::L                           S:::::S U:::::D     D:::::U 
//   L:::::L         LLLLLL            S:::::S U::::::U   U::::::U 
// LL:::::::LLLLLLLLL:::::LSSSSSSS     S:::::S U:::::::UUU:::::::U 
// L::::::::::::::::::::::LS::::::SSSSSS:::::S  UU:::::::::::::UU  
// L::::::::::::::::::::::LS:::::::::::::::SS     UU:::::::::UU    
// LLLLLLLLLLLLLLLLLLLLLLLL SSSSSSSSSSSSSSS         UUUUUUUUU      


	input [63:0] S_LSU_AXI_AWADDR,
	input S_LSU_AXI_AWVALID,
	output S_LSU_AXI_AWREADY,

	input [63:0] S_LSU_AXI_WDATA,
	input [7:0] S_LSU_AXI_WSTRB,
	input S_LSU_AXI_WVALID,
	output S_LSU_AXI_WREADY,

	output [7:0] S_LSU_AXI_BID,
	output [1:0] S_LSU_AXI_BRESP,
	output [7:0] S_LSU_AXI_BUSER,
	output S_LSU_AXI_BVALID,
	input S_LSU_AXI_BREADY,

	input [7:0] S_LSU_AXI_ARID,
	input [63:0] S_LSU_AXI_ARADDR,
	input [7:0] S_LSU_AXI_ARLEN,
	input [2:0] S_LSU_AXI_ARSIZE,
	input [1:0] S_LSU_AXI_ARBURST,
	// input S_LSU_AXI_ARLOCK,
	// input [3:0] S_LSU_AXI_ARCACHE,
	// input [2:0] S_LSU_AXI_ARPROT,
	// input [3:0] S_LSU_AXI_ARQOS,
	// input [3:0] S_LSU_AXI_ARREGION,
	input [7 0] S_LSU_AXI_ARUSER,
	input S_LSU_AXI_ARVALID,
	output S_LSU_AXI_ARREADY,
	output [7:0] S_LSU_AXI_RID,

	output [63:0] S_LSU_AXI_RDATA,
	output [1:0] S_LSU_AXI_RRESP,
	output S_LSU_AXI_RLAST,
	output [7:0] S_LSU_AXI_RUSER,
	output S_LSU_AXI_RVALID,
	input S_LSU_AXI_RREADY,


//slave



// system bus out

	output [7:0] M_SYS_AXI_AWID,
	output [63:0] M_SYS_AXI_AWADDR,
	output [7:0] M_SYS_AXI_AWLEN,
	output [2:0] M_SYS_AXI_AWSIZE,
	output [1:0] M_SYS_AXI_AWBURST,
	// output M_SYS_AXI_AWLOCK,
	// output [3:0] M_SYS_AXI_AWCACHE,
	// output [2:0] M_SYS_AXI_AWPROT,
	// output [3:0] M_SYS_AXI_AWQOS,
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
	// output M_SYS_AXI_ARLOCK,
	// output [3:0] M_SYS_AXI_ARCACHE,
	// output [2:0] M_SYS_AXI_ARPROT,
	// output [3:0] M_SYS_AXI_ARQOS,
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

// Icache

	input icache_enable,

	output [63:0] M_ICACHE_AXI_ARADDR,
	output M_ICACHE_AXI_ARVALID,
	input M_ICACHE_AXI_ARREADY,

	input [31:0] M_ICACHE_AXI_RDATA,
	input [1:0] M_ICACHE_AXI_RRESP,
	input M_ICACHE_AXI_RVALID,
	output M_ICACHE_AXI_RREADY,

// Dcache

	input dcache_enable,

	output [63:0] M_DCACHE_AXI_AWADDR,
	output M_DCACHE_AXI_AWVALID,
	input M_DCACHE_AXI_AWREADY,

	output [63:0] M_DCACHE_AXI_WDATA,
	output [7:0] M_DCACHE_AXI_WSTRB,
	output M_DCACHE_AXI_WVALID,
	input M_DCACHE_AXI_WREADY,

	input [1:0] M_DCACHE_AXI_BRESP,
	input M_DCACHE_AXI_BVALID,
	output M_DCACHE_AXI_BREADY,

	output [63:0] M_DCACHE_AXI_ARADDR,
	output M_DCACHE_AXI_ARVALID,
	input M_DCACHE_AXI_ARREADY,

	input [63 0] M_DCACHE_AXI_RDATA,
	input [1:0] M_DCACHE_AXI_RRESP,
	input M_DCACHE_AXI_RVALID,
	output M_DCACHE_AXI_RREADY

















	input CLK,
	input RSTn

);




	//i fetch





	wire isIFUSelIcache = ( |S_IFU_AXI_ARADDR[63:32]) & icache_enable;



	assign S_IFU_AXI_RDATA = ({32{isIFUSelIcache}} & M_ICACHE_AXI_RDATA)
							|


	assign S_IFU_AXI_RRESP = ({2{isIFUSelIcache}} & M_ICACHE_AXI_RRESP)
							|


	output S_IFU_AXI_RVALID = (isIFUSelIcache & M_ICACHE_AXI_RVALID)
							|


	assign S_IFU_AXI_ARREADY = (isIFUSelIcache & M_ICACHE_AXI_ARREADY)
								|



	assign M_ICACHE_AXI_ARADDR = S_IFU_AXI_ARADDR;
	assign M_ICACHE_AXI_ARVALID = isIFUSelIcache & S_IFU_AXI_ARVALID;
	assign M_ICACHE_AXI_RREADY = (isIFUSelIcache & S_IFU_AXI_RREADY)
								|







	output [63:0] M_PB_AXI_AWADDR,
	output M_PB_AXI_AWVALID,
	input M_PB_AXI_AWREADY,

	output [63:0] M_PB_AXI_WDATA,
	output [7:0] M_PB_AXI_WSTRB,
	output M_PB_AXI_WVALID,
	input M_PB_AXI_WREADY,

	input [1:0] M_PB_AXI_BRESP,
	input M_PB_AXI_BVALID,
	output M_PB_AXI_BREADY,

	output [63:0] M_PB_AXI_ARADDR,
	output M_PB_AXI_ARVALID,
	input M_PB_AXI_ARREADY,

	input [63 0] M_PB_AXI_RDATA,
	input [1:0] M_PB_AXI_RRESP,
	input M_PB_AXI_RVALID,
	output M_PB_AXI_RREADY,



	output [7:0] M_SYS_AXI_AWID,
	output [63:0] M_SYS_AXI_AWADDR,
	output [7:0] M_SYS_AXI_AWLEN,
	output [2:0] M_SYS_AXI_AWSIZE,
	output [1:0] M_SYS_AXI_AWBURST,
	// output M_SYS_AXI_AWLOCK,
	// output [3:0] M_SYS_AXI_AWCACHE,
	// output [2:0] M_SYS_AXI_AWPROT,
	// output [3:0] M_SYS_AXI_AWQOS,
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
	// output M_SYS_AXI_ARLOCK,
	// output [3:0] M_SYS_AXI_ARCACHE,
	// output [2:0] M_SYS_AXI_ARPROT,
	// output [3:0] M_SYS_AXI_ARQOS,
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


endmodule















