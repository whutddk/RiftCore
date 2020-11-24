/*
* @File name: DTM
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:33:45
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-24 15:29:20
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


module DTM (


	//from host
	input JTAG_TCK,
	input JTAG_TDI,
	output JTAG_TDO,
	input JTAG_TMS,
	input JTAG_TRST,

	//from AXI lite

	input M_AXI_ACLK,
	input M_AXI_ARESETN,

	output [7 : 0] M_AXI_AWADDR,
	output [2 : 0] M_AXI_AWPROT,
	output M_AXI_AWVALID,
	input M_AXI_AWREADY,

	output [31 : 0] M_AXI_WDATA,
	output [3 : 0] M_AXI_WSTRB,
	output M_AXI_WVALID,
	input M_AXI_WREADY,

	input [1 : 0] M_AXI_BRESP,
	input M_AXI_BVALID,
	output M_AXI_BREADY,

	output [7 : 0] M_AXI_ARADDR,
	output [2 : 0] M_AXI_ARPROT,
	output M_AXI_ARVALID,
	input M_AXI_ARREADY,

	input [31 : 0] M_AXI_RDATA,
	input [1 : 0] M_AXI_RRESP,
	input M_AXI_RVALID,
	output M_AXI_RREADY



);















dtm_axi (
	input M_AXI_ACLK,
	input M_AXI_ARESETN,

	output [7 : 0] M_AXI_AWADDR,
	output [2 : 0] M_AXI_AWPROT,
	output M_AXI_AWVALID,
	input M_AXI_AWREADY,

	output [31 : 0] M_AXI_WDATA,
	output [3 : 0] M_AXI_WSTRB,
	output M_AXI_WVALID,
	input M_AXI_WREADY,

	input [1 : 0] M_AXI_BRESP,
	input M_AXI_BVALID,
	output M_AXI_BREADY,

	output [7 : 0] M_AXI_ARADDR,
	output [2 : 0] M_AXI_ARPROT,
	output M_AXI_ARVALID,
	input M_AXI_ARREADY,

	input [31 : 0] M_AXI_RDATA,
	input [1 : 0] M_AXI_RRESP,
	input M_AXI_RVALID,
	output M_AXI_RREADY
	
);






endmodule







