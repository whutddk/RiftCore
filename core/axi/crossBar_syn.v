/*
* @File name: crossBar_syn
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-04 19:42:02
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-04 19:54:56
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


module crossBar_syn #
(
	parameter ISASYN = 1
)
(

	// master Demain
	input S_AWVALID,
	input S_WVALID,
	input S_BREADY,
	input S_ARVALID,
	input S_RREADY,
	output S_AWREADY,
	output S_ARREADY,
	output S_RVALID,
	output S_WREADY,
	output S_BVALID,
	input S_CLK,
	input S_RSTn,


	//CrossBar Demain
	output M_AWVALID,
	output M_WVALID,
	output M_BREADY,
	output M_ARVALID,
	output M_RREADY,
	input M_ARREADY,
	input M_RVALID,
	input M_WREADY,
	input M_BVALID,
	input M_AWREADY,
	input M_CLK,
	input M_RSTn

);





generate
	
	if ( 0 == ISASYN ) begin
		assign M_AWVALID = S_AWVALID;
		assign M_WVALID = S_WVALID;
		assign M_BREADY = S_BREADY;
		assign M_ARVALID = S_ARVALID;
		assign M_RREADY = S_RREADY;

		assign S_AWREADY = M_AWREADY;
		assign S_ARREADY = M_ARREADY;
		assign S_RVALID = M_RVALID;
		assign S_WREADY = M_WREADY;
		assign S_BVALID = M_BVALID;

	end
	else begin
		gen_syn AWVALID ( .data_asyn(S_AWVALID), .data_syn(M_AWVALID), .CLK(M_CLK), .RSTn(M_RSTn) );
		gen_syn WVALID ( .data_asyn(S_WVALID), .data_syn(M_WVALID), .CLK(M_CLK), .RSTn(M_RSTn) );
		gen_syn BREADY ( .data_asyn(S_BREADY), .data_syn(M_BREADY), .CLK(M_CLK), .RSTn(M_RSTn) );
		gen_syn ARVALID ( .data_asyn(S_ARVALID), .data_syn(M_ARVALID), .CLK(M_CLK), .RSTn(M_RSTn) );
		gen_syn RREADY ( .data_asyn(S_RREADY), .data_syn(M_RREADY), .CLK(M_CLK), .RSTn(M_RSTn) );


		gen_syn AWREADY ( .data_asyn(M_AWREADY), .data_syn(S_AWREADY), .CLK(S_CLK), .RSTn(S_RSTn) );
		gen_syn ARREADY ( .data_asyn(M_ARREADY), .data_syn(S_ARREADY), .CLK(S_CLK), .RSTn(S_RSTn) );
		gen_syn RVALID ( .data_asyn(M_RVALID), .data_syn(S_RVALID), .CLK(S_CLK), .RSTn(S_RSTn) );
		gen_syn WREADY ( .data_asyn(M_WREADY), .data_syn(S_WREADY), .CLK(S_CLK), .RSTn(S_RSTn) );
		gen_syn BVALID ( .data_asyn(M_BVALID), .data_syn(S_BVALID), .CLK(S_CLK), .RSTn(S_RSTn) );

	end


endgenerate













endmodule










