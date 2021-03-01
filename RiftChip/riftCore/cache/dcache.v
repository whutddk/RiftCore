/*
* @File name: dcache
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-18 19:03:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-18 19:06:57
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

`include "define.vh"


module dcache (

	output [31:0] L1D_AWADDR,
	output [2:0] L1D_AWPROT,
	output L1D_AWVALID,
	input L1D_AWREADY,

	output [255:0] L1D_WDATA,
	output [7:0] L1D_WSTRB,
	output L1D_WVALID,
	input L1D_WREADY,

	input [1:0] L1D_BRESP,
	input L1D_BVALID,
	output L1D_BREADY,

	output [31:0] L1D_ARADDR,
	output [2:0] L1D_ARPROT,
	output L1D_ARVALID,
	input L1D_ARREADY,

	input [255:0] L1D_RDATA,
	input [1:0] L1D_RRESP,
	input L1D_RVALID,
	output L1D_RREADY,


);












endmodule


