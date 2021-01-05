/*
* @File name: reset_halt_control
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:35:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:44:33
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

module reset_halt_control #
(
	parameter MAXHART = 1
	
)
(

	//to core

	output [MAXHART-1:0] haltreq_qout,
	output [MAXHART-1:0] resumereq_qout,
	output [MAXHART-1:0] setresethaltreq_qout,
	output [MAXHART-1:0] clrresethaltreq_qout,

	input [MAXHART-1:0] reset_status,	
	input [MAXHART-1:0] halt_status,

	input [MAXHART-1:0] isDebugMode,

	//form dm


	input [31:0] dmcontrol,
	input [MAXHART-1:0] hartArrayMask,

);






	wire hasel = dmcontrol[26];

	wire [9:0] hartsello = dmcontrol[25:16];
	wire [9:0] hartselhi = dmcontrol[15:6];

	wire [19:0] hartsel = {hartselhi, hartsello};

	wire [MAXHART-1:0] hartSelected = hasel ? hartArrayMask : hartsel[MAXHART-1:0];







	
	wire haltreq;
	wire resumereq;




wire [MAXHART-1:0] haltreq_dnxt = haltreq ? hartSelected : haltreq_qout;
gen_dffr # (.DW(MAXHART)) haltreq ( .dnxt(haltreq_dnxt), .qout(haltreq_qout), .CLK(CLK), .RSTn(RSTn));

	wire [MAXHART-1:0] resumereq_dnxt;


	wire [MAXHART-1:0] setresethaltreq_dnxt;


	wire [MAXHART-1:0] clrresethaltreq_dnxt;








endmodule

