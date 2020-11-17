/*
* @File name: csrFiles
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-17 09:46:11
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-17 17:55:57
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



module csrFiles (

	//from csr exe
	input [11:0] csrexe_addr,
	input csrexe_wen,
	input [63:0] csrexe_data_write,
	output [63:0] csrexe_data_read,

	//from privileged
	input isTrap,
	input isXRet,
	input [63:0] mstatus_except_in,
	input [63:0] mtval_except_in,
	input [63:0] mcause_except_in,
	input [63:0] mepc_except_in,

	output [63:0] mstatus_csr_out,
	output [63:0] mip_csr_out,
	output [63:0] mie_csr_out,
	output [63:0] mepc_csr_out,
	output [63:0] mtvec_csr_out,

	//from outside

	input isExternInterrupt,
	input isRTimerInterrupt,
	input isSoftwvInterrupt,

	input CLK,
	input RSTn
);

assign mstatus_csr_out = mstatus_qout;
assign mie_csr_out = mie_qout;
assign mip_csr_out = mip_qout;
assign mepc_csr_out = mepc_qout;
assign mtvec_csr_out = mtvec_qout;







// Machine Information Registers

//0xF11
wire [31:0] mvendorid_qout = 32'd0;


//0xf12
wire [63:0] marchid_qout = 64'd0;


//0xf13
wire [63:0] mimpid_qout = 64'd0;


//0xf14
wire [63:0] mhartid_qout = 64'd0;


//Machine Trap Setup

//0x300
wire [63:0] mstatus_dnxt;
wire [63:0] mstatus_qout;
gen_dffr # (.DW(64)) mstatus ( .dnxt(mstatus_dnxt), .qout(mstatus_qout), .CLK(CLK), .RSTn(RSTn) );

assign mstatus_dnxt = 	({64{isTrap | isXRet}} & mstatus_except_in)
						|
						({64{(addr == 0x300) & wen}} & csrexe_data_write)
						|
						({64{~(isTrap | isXRet) & ~((addr == 0x300) & wen)}} & mstatus_qout)
						;


//0x301
wire [63:0] misa_qout = {2'b10,36'b0,26'b00000000000000000100000000};


//0x302
wire [63:0] medeleg_dnxt = 64'd0;
wire [63:0] medeleg_qout;
gen_dffr # (.DW(64)) medeleg ( .dnxt(medeleg_dnxt), .qout(medeleg_qout), .CLK(CLK), .RSTn(RSTn) );

//0x303
wire mideleg_dnxt = 64'd0;
wire mideleg_qout;
gen_dffr # (.DW(64)) mideleg ( .dnxt(mideleg_dnxt), .qout(mideleg_qout), .CLK(CLK), .RSTn(RSTn) );

//0x304
wire [63:0] mie_dnxt
wire [63:0] mie_qout;
gen_dffr # (.DW(64)) mie ( .dnxt(mie_dnxt), .qout(mie_qout), .CLK(CLK), .RSTn(RSTn) );

assign mie_dnxt = ({64{(addr == 0x304) & wen}} & csrexe_data_write)
					|
					({64{~((addr == 0x304) & wen)}} & mie_qout)

//0x305
wire [63:0] mtvec_dnxt;
wire [63:0] mtvec_qout; 
gen_dffr # (.DW(64)) mtvec ( .dnxt(mtvec_dnxt), .qout(mtvec_qout), .CLK(CLK), .RSTn(RSTn) );

assign mtvec_dnxt = ({64{(addr == 0x305) & wen}} & csrexe_data_write)
					|
					({64{~((addr == 0x305) & wen)}} & mtvec_qout)

//0x306
wire [31:0] mcounteren_dnxt = 32'd0;
wire [31:0] mcounteren_qout;
gen_dffr # (.DW(32)) mcounteren ( .dnxt(mcounteren_dnxt), .qout(mcounteren_qout), .CLK(CLK), .RSTn(RSTn) );

//0x310
wire [31:0] mstatush_dnxt = 32'd0;
wire [31:0] mstatush_qout;
gen_dffr # (.DW(32)) mstatush ( .dnxt(mstatush_dnxt), .qout(mstatush_qout), .CLK(CLK), .RSTn(RSTn) ); //RV32 only

//Machine Trap Handling

//0x340
wire [63:0] mscratch_dnxt = 64'd0;
wire [63:0] mscratch_qout;
gen_dffr # (.DW(64)) mscratch ( .dnxt(mscratch_dnxt), .qout(mscratch_qout), .CLK(CLK), .RSTn(RSTn) );

//0x341
wire [63:0] mepc_dnxt;
wire [63:0] mepc_qout;
gen_dffr # (.DW(64)) mepc ( .dnxt(mepc_dnxt), .qout(mepc_qout), .CLK(CLK), .RSTn(RSTn) );

assign mepc_dnxt = ({64{isTrap}} & mepc_except_in)
					|
					({64{(addr == 0x341) & wen}} & csrexe_data_write)
					|
					({64{~isTrap & ~((addr == 0x305) & wen)}} & mepc_qout);



//0x342
wire [63:0] mcause_dnxt;
wire [63:0] mcause_qout;
gen_dffr # (.DW(64)) mcause ( .dnxt(mcause_dnxt), .qout(mcause_qout), .CLK(CLK), .RSTn(RSTn) );

assign mcause_dnxt = ({64{isTrap}} & mcause_except_in)
					|
					({64{(addr == 0x342) & wen}} & csrexe_data_write)
					|
					({64{~isTrap & ~((addr == 0x342) & wen)}} & mcause_qout);


//0x343
wire [63:0] mtval_dnxt;
wire [63:0] mtval_qout;
gen_dffr # (.DW(64)) mtval ( .dnxt(mtval_dnxt), .qout(mtval_qout), .CLK(CLK), .RSTn(RSTn) );

assign mtval_dnxt = ({64{isTrap}} & mtval_except_in)
					|
					({64{(addr == 0x343) & wen}} & csrexe_data_write)
					|
					({64{~isTrap & ~((addr == 0x343) & wen)}} & mtval_qout);


//0x344
assign mip_qout = isExternInterrupt << 11 | isRTimerInterrupt << 7 | isSoftwvInterrupt << 3;


// gen_dffr # (.DW()) mtinst ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );
// gen_dffr # (.DW()) mtval2 ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );

//Machine Memory Protection

//Machine Counter/Timer

//0xb00
wire [63:0] mcycle_dnxt = 64'd0;;
wire [63:0] mcycle_qout;
gen_dffr # (.DW(64)) mcycle ( .dnxt(mcycle_dnxt), .qout(mcycle_qout), .CLK(CLK), .RSTn(RSTn) );

//0xb02
wire [63:0] minstret_dnxt = 64'd0;;
wire [63:0] minstret_qout;
gen_dffr # (.DW(64)) minstret ( .dnxt(minstret_dnxt), .qout(minstret_qout), .CLK(CLK), .RSTn(RSTn) );

//0xb03
wire [63:0] mhpmcounter3_dnxt = 64'd0;;
wire [63:0] mhpmcounter3_qout;
gen_dffr # (.DW(64)) mhpmcounter3 ( .dnxt(mhpmcounter3_dnxt), .qout(mhpmcounter3_qout), .CLK(CLK), .RSTn(RSTn) );

//Machine Counter Setup

//Debug/Trace Register
// gen_dffr # (.DW()) tselect ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );
// gen_dffr # (.DW()) tdata1 ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );
// gen_dffr # (.DW()) tdata2 ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );
// gen_dffr # (.DW()) tdata3 ( .dnxt(), .qout(), .CLK(CLK), .RSTn(RSTn) );

//Debug Mode Register

//0x7b0
wire [31:0] dcsr_dnxt = 32'd0;
wire [31:0] dcsr_qout;
gen_dffr # (.DW(32)) dcsr ( .dnxt(dcsr_dnxt), .qout(dcsr_qout), .CLK(CLK), .RSTn(RSTn) );

//0x7b1
wire [63:0] dpc_dnxt = 64'd0;
wire [63:0] dpc_qout;
gen_dffr # (.DW(64)) dpc ( .dnxt(dpc_dnxt), .qout(dpc_qout), .CLK(CLK), .RSTn(RSTn) );

//0x7b2
wire [63:0] dscratch0_dnxt = 64'd0;
wire [63:0] dscratch0_qout;
gen_dffr # (.DW(64)) dscratch0 ( .dnxt(dscratch0_dnxt), .qout(dscratch0_qout), .CLK(CLK), .RSTn(RSTn) );

//0x7b3
wire [63:0] dscratch1_dnxt = 64'd0;
wire [63:0] dscratch1_qout;
gen_dffr # (.DW(64)) dscratch1 ( .dnxt(dscratch1_dnxt), .qout(dscratch1_qout), .CLK(CLK), .RSTn(RSTn) );








assign csrexe_access_read = ({64{addr == 12'hF11}} & {32'b0,mvendorid_qout})
							|
							({64{addr == 12'hF12}} & marchid_qout)
							|
							({64{addr == 12'hF13}} & mimpid_qout)
							|
							({64{addr == 12'hF14}} & mhartid_qout)
							|
							({64{addr == 12'h300}} & mstatus_qout)
							|
							({64{addr == 12'h301}} & misa_qout)
							|
							({64{addr == 12'h304}} & mie_qout)
							|
							({64{addr == 12'h305}} & mtvec_qout)
							|
							({64{addr == 12'h341}} & mepc_qout)
							|
							({64{addr == 12'h342}} & mcause_qout)
							|
							({64{addr == 12'h343}} & mtval_qout)
							|
							({64{addr == 12'h344}} & mip_qout)
							;




endmodule











