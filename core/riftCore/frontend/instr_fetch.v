/*
* @File name: instr_fetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-10 16:02:56
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
`include "define.vh"

module instr_fetch (
	input [31:0] instr_readout,
	output [31:0] instr,
	input [63:0] pc_in,
	output [63:0] pc_out,

	input isRVC_in,
	output isRVC_out,
	
	//handshake
	input isInstrReadOut,
	output fetch_decode_vaild,
	input instrFifo_full,

	input flush,
	input CLK,
	input RSTn
);





initial $warning("this stage left for future used");


wire [31:0] instr_fetch_qout;
wire [31:0] instr_fetch_dnxt = flush ? 32'b0 : ((isInstrReadOut & ~instrFifo_full) ? instr_readout : instr_fetch_qout);
wire [63:0] pc_qout;
wire [63:0] pc_dnxt = flush ? 64'b0 : ((isInstrReadOut & ~instrFifo_full) ? pc_in : pc_qout);
wire isVaild = flush ? 1'b0 : (isInstrReadOut );

wire isRVC_qout;
wire isRVC_dnxt = flush ? 64'b0 : ((isInstrReadOut & ~instrFifo_full) ? isRVC_in : isRVC_qout);


assign pc_out = pc_qout;
assign isRVC_out = isRVC_qout;

assign instr = instr_fetch_qout;

wire isVaild_qout;
assign fetch_decode_vaild = isVaild_qout & ~instrFifo_full;

gen_dffr # (.DW(64)) pc ( .dnxt(pc_dnxt), .qout(pc_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(32)) instr_fetch ( .dnxt(instr_fetch_dnxt), .qout(instr_fetch_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) handshake ( .dnxt(isVaild), .qout(isVaild_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) isRVC ( .dnxt(isRVC_dnxt), .qout(isRVC_qout), .CLK(CLK), .RSTn(RSTn));


endmodule


