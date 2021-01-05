/*
* @File name: preDecode
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-05 16:23:28
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:44:41
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




module preDecode (
	output isJal,
	output isJalr,
	output isBranch,
	output isCall,
	output isReturn,
	output [63:0] imm,

	input [31:0] instr_readout,
	input is_rvc_instr
);




	wire isIJal = ~is_rvc_instr & (instr_readout[6:0] == 7'b1101111);			
	wire isCJal =	 instr_readout[1:0] == 2'b01 & instr_readout[15:13] == 3'b101;

	wire isIJalr = ~is_rvc_instr & (instr_readout[6:0] == 7'b1100111);
	wire isCJalr = (instr_readout[1:0] == 2'b10 & instr_readout[15:13] == 3'b100)
					&
					(
						(~instr_readout[12] & (instr_readout[6:2] == 0)) 
						| 
						( instr_readout[12] & (|instr_readout[11:7]) & (&(~instr_readout[6:2])))
					);

	wire isIBranch = ~is_rvc_instr & (instr_readout[6:0] == 7'b1100011);
	wire isCBranch =  instr_readout[1:0] == 2'b01 & instr_readout[15:14] == 2'b11;

	wire isICall = (isIJalr | isIJal) & ((instr_readout[11:7] == 5'd1) | instr_readout[11:7] == 5'd5);
	wire isCCall = isCJalr & instr_readout[12];

	wire isIReturn =  isIJalr & ((instr_readout[19:15] == 5'd1) | instr_readout[19:15] == 5'd5)
									& (instr_readout[19:15] != instr_readout[11:7]);

	wire isCReturn =  isCJalr & ~instr_readout[12]
							& ((instr_readout[11:7] == 5'd1) | (instr_readout[11:7] == 5'd5));




	wire [63:0] Iimm = 
		({64{isIJal}} & {{44{instr_readout[31]}},instr_readout[19:12],instr_readout[20],instr_readout[30:21],1'b0})
		|
		({64{isIJalr}} & {{52{instr_readout[31]}},instr_readout[31:20]})
		|
		({64{isIBranch}} & {{52{instr_readout[31]}},instr_readout[7],instr_readout[30:25],instr_readout[11:8],1'b0});

	wire [63:0] Cimm = 
		({64{isCJal}} & {{52{instr_readout[12]}}, instr_readout[12], instr_readout[8], instr_readout[10:9], instr_readout[6], instr_readout[7], instr_readout[2], instr_readout[11], instr_readout[5:3], 1'b0})
		|
		({64{isCJalr}} & 64'b0)
		|
		({64{isCBranch}} & {{55{instr_readout[12]}}, instr_readout[12], instr_readout[6:5], instr_readout[2], instr_readout[11:10], instr_readout[4:3], 1'b0});

	assign isJal = isIJal | isCJal; 
	assign isJalr = isIJalr | isCJalr;
	assign isBranch = isIBranch | isCBranch;
	assign isCall = isICall | isCCall;
	assign isReturn = isIReturn | isCReturn;

	wire [63:0] imm = is_rvc_instr ? Cimm : Iimm;




















endmodule









