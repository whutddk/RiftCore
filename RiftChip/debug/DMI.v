/*
* @File name: DMI
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:35:08
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-25 18:58:58
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


module DMI (

	// master
	input [4:0] M_AXI_AWADDR,
	input [2:0] M_AXI_AWPROT,
	input M_AXI_AWVALID,
	output M_AXI_AWREADY,

	input [31:0] M_AXI_WDATA,
	input [3:0] M_AXI_WSTRB,
	input M_AXI_WVALID,
	output M_AXI_WREADY,

	output [1:0] M_AXI_BRESP,
	output M_AXI_BVALID,
	input M_AXI_BREADY,

	input [4:0] M_AXI_ARADDR,
	input [2:0] M_AXI_ARPROT,
	input M_AXI_ARVALID,
	output M_AXI_ARREADY,

	output [31:0] M_AXI_RDATA,
	output [1:0] M_AXI_RRESP,
	output M_AXI_RVALID,
	input M_AXI_RREADY

);

endmodule

