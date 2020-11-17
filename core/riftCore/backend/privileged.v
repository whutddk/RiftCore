/*
* @File name: privileged
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-17 11:26:42
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-17 15:08:56
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


module privileged (


	input isException,
	input [5:0] cause,
	input [63:0] exception_pc,

	output isTrap,

	output [63:0] mepc_except_in
	output [63:0] mcause_except_in,
	output [63:0] mtval_except_in,
	output [63:0] mstatus_except_in,

	input [63:0] mstatus_csr_out,
	input [63:0] mip_csr_out,
	input [63:0] mie_csr_out,


);

initial $info("for tiny, extern interrupt will observer directly from csrfiles in this version");
wire isExInterrupt = mip_csr_out[11] & mie_csr_out[11] & mstatus_csr_out[3];
wire isTimeInterrupt = mip_csr_out[7] & mie_csr_out[7] & mstatus_csr_out[3];
wire isSoftInterrupt = mip_csr_out[3] & mie_csr_out[3] & mstatus_csr_out[3];

wire isInterrupt = isExInterrupt | isTimeInterrupt | isSoftInterrupt;

assign isTrap = isInterrupt | isException;





assign mcause_except_in[63] = isInterrupt;
assign mcause_except_in[62:0] = cause;

assign mepc_except_in = exception_pc;

initial $warning("will not show what happen in this version");
assign mtval_except_in = 64'b0




endmodule


