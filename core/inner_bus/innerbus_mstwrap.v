/*
* @File name: innerbus_mstwrap
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-31 16:57:37
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:04:40
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


module innerbus_mstwrap 
(
	input [137:0] slv_i,
	output [65:0] mst_o,


	output mstReq_valid,
	input slvReq_ready,
	output [63:0] addr,
	output [63:0] data_w,
	input [63:0] data_r,
	output [7:0] wstrb,

	input slvRsp_valid,
	output mstRsp_ready

);

	assign mst_o = { slvReq_ready, slvRsp_valid, data_r }
	assign { mstReq_valid, mstRsp_ready, addr, data_w, wstrb } = slv_i;

endmodule











