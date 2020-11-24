/*
* @File name: DTM_JTAG
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 15:30:02
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-24 17:49:24
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




module DTM_JTAG (

	//from host
	input TCK,
	input TDI,
	output TDO,
	input TMS,
	input TRST,


);



localparam TEST_LOGIC_RESET = 0;
localparam RUN_TEST_IDLE = 1;
localparam SELECT_DR_SCAN = 2;
localparam CAPTURE_DR = 3;
localparam SHIFT_DR = 4;
localparam EXIT_1_DR = 5;
localparam PAUSE_DR = 6;
localparam EXIT_2_DR = 7;
localparam UPDATE_DR = 8;
localparam SELECT_IR_SCAN = 9;
localparam CAPTURE_IR = 10;
localparam SHIFT_IR = 11;
localparam EXIT_1_IR = 12;
localparam PAUSE_IR = 13;
localparam EXIT_2_IR = 14;
localparam UPDATE_IR = 15;


wire [3:0] tap_state_dnxt;
wire [3:0] tap_state_qout;


assign tap_state_dnxt = 
	  ({4{tap_state_qout == TEST_LOGIC_RESET}} & {4{ TMS}} & TEST_LOGIC_RESET)
	| ({4{tap_state_qout == TEST_LOGIC_RESET}} & {4{~TMS}} & RUN_TEST_IDLE)

	| ({4{tap_state_qout == RUN_TEST_IDLE}} & {4{ TMS}} & SELECT_DR_SCAN)
	| ({4{tap_state_qout == RUN_TEST_IDLE}} & {4{~TMS}} & RUN_TEST_IDLE)

	| ({4{tap_state_qout == SELECT_DR_SCAN}} & {4{ TMS}} & SELECT_IR_SCAN)
	| ({4{tap_state_qout == SELECT_DR_SCAN}} & {4{~TMS}} & CAPTURE_DR)

	| ({4{tap_state_qout == CAPTURE_DR}} & {4{ TMS}} & EXIT_1_DR)
	| ({4{tap_state_qout == CAPTURE_DR}} & {4{~TMS}} & SHIFT_DR)

	| ({4{tap_state_qout == SHIFT_DR}} & {4{ TMS}} & EXIT_1_DR)
	| ({4{tap_state_qout == SHIFT_DR}} & {4{~TMS}} & SHIFT_DR)

	| ({4{tap_state_qout == EXIT_1_DR}} & {4{ TMS}} & UPDATE_DR)
	| ({4{tap_state_qout == EXIT_1_DR}} & {4{~TMS}} & PAUSE_DR)

	| ({4{tap_state_qout == PAUSE_DR}} & {4{ TMS}} & EXIT_2_DR)
	| ({4{tap_state_qout == PAUSE_DR}} & {4{~TMS}} & PAUSE_DR)

	| ({4{tap_state_qout == EXIT_2_DR}} & {4{ TMS}} & UPDATE_DR)
	| ({4{tap_state_qout == EXIT_2_DR}} & {4{~TMS}} & SHIFT_DR)

	| ({4{tap_state_qout == UPDATE_DR}} & {4{ TMS}} & SELECT_DR_SCAN)
	| ({4{tap_state_qout == UPDATE_DR}} & {4{~TMS}} & RUN_TEST_IDLE)

	| ({4{tap_state_qout == SELECT_IR_SCAN}} & {4{ TMS}} & TEST_LOGIC_RESET)
	| ({4{tap_state_qout == SELECT_IR_SCAN}} & {4{~TMS}} & CAPTURE_IR)

	| ({4{tap_state_qout == CAPTURE_IR}} & {4{ TMS}} & EXIT_1_IR)
	| ({4{tap_state_qout == CAPTURE_IR}} & {4{~TMS}} & SHIFT_IR)

	| ({4{tap_state_qout == SHIFT_IR}} & {4{ TMS}} & EXIT_1_IR)
	| ({4{tap_state_qout == SHIFT_IR}} & {4{~TMS}} & SHIFT_IR)

	| ({4{tap_state_qout == EXIT_1_IR}} & {4{ TMS}} & UPDATE_IR)
	| ({4{tap_state_qout == EXIT_1_IR}} & {4{~TMS}} & PAUSE_IR)

	| ({4{tap_state_qout == PAUSE_IR}} & {4{ TMS}} & EXIT_2_IR)
	| ({4{tap_state_qout == PAUSE_IR}} & {4{~TMS}} & PAUSE_IR)

	| ({4{tap_state_qout == EXIT_2_IR}} & {4{ TMS}} & UPDATE_IR)
	| ({4{tap_state_qout == EXIT_2_IR}} & {4{~TMS}} & SHIFT_IR)

	| ({4{tap_state_qout == UPDATE_IR}} & {4{ TMS}} & SELECT_DR_SCAN)
	| ({4{tap_state_qout == UPDATE_IR}} & {4{~TMS}} & RUN_TEST_IDLE)

gen_dffr # (.DW(4)) tap_state ( .dnxt(tap_state_dnxt), .qout(tap_state_qout), .CLK(TCK), .RSTn(TRST));




wire [4:0] shift_IR_dnxt;
wire [4:0] shift_IR_qout;
gen_dffr # (.DW(5)) shift_IR ( .dnxt(shift_IR_dnxt), .qout(shift_IR_qout), .CLK(~TCK), .RSTn(TRST));

assign shift_IR_dnxt = 
	  {5{tap_state_qout == SHIFT_IR}} & {TDI, shift_IR_qout[4:1]}
	| {5{tap_state_qout != SHIFT_IR}} & shift_IR_qout[4:0];




wire [4:0] ir_dnxt;
wire [4:0] ir_qout;
gen_dffr # (.DW(5)) IR ( .dnxt(ir_dnxt), .qout(ir_qout), .CLK(TCK), .RSTn(TRST));

assign ir_dnxt = 
	  {5{tap_state_qout == TEST_LOGIC_RESET}} & 5'h1
	| {5{tap_state_qout == UPDATE_IR}} & shift_IR_qout
	| {5{(tap_state_qout != TEST_LOGIC_RESET) & (tap_state_qout != UPDATE_IR)}} & ir_qout[4:0];





wire [38:0] shift_DR_dnxt;
wire [38:0] shift_DR_qout;
gen_dffr # (.DW(39)) shift_DR ( .dnxt(shift_DR_dnxt), .qout(shift_DR_qout), .CLK(~TCK), .RSTn(TRST));


assign shift_DR_dnxt = 
	 ({39{tap_state_qout == CAPTURE_DR}} & (  ({39{shift_DR_qout == 5'h1}} & {IDCODE, 7'b0})
	  	  										| ({39{shift_DR_qout == 5'h10}} & {dtmcs_qout, 7'b0})
	  	  										| ({39{shift_DR_qout == 5'h11}} & dmi_qout) ) )
	| {39{tap_state_qout == SHIFT_DR}} & {TDI, shift_DR_qout[38:1]}
	| {39{(tap_state_qout != CAPTURE_DR) & (tap_state_qout != SHIFT_DR)}} & shift_DR_qout[4:0];



assign TDO = ((tap_state_qout == SHIFT_DR) & shift_DR_qout[0])
			|
			((tap_state_qout == SHIFT_IR) & shift_IR_qout[0]);













wire [31:0] IDCODE = 32'b0;

wire [31:0] dtmcs_dnxt;
wire [31:0] dtmcs_qout;
gen_dffr # (.DW(32)) dtmcs ( .dnxt(dtmcs_dnxt), .qout(dtmcs_qout), .CLK(TCK), .RSTn(TRST));


wire [38:0] dmi_dnxt;
wire [38:0] dmi_qout;
gen_dffr # (.DW(39)) dmi ( .dnxt(dmi_dnxt), .qout(dmi_qout), .CLK(TCK), .RSTn(TRST));

wire BYPASS = 1'b0;





endmodule

