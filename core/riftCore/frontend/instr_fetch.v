/*
* @File name: instr_fetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-08 14:51:26
*/

`timescale 1 ns / 1 ps
`include "define.vh"

module instr_fetch (
	input [31:0] instr_readout,
	output [31:0] instr,
	input [63:0] pc_in,
	output [63:0] pc_out,
	//handshake
	input isInstrReadOut,
	output fetch_decode_vaild,
	input instrFifo_full,

	input CLK,
	input RSTn
);





initial $warning("预留一拍做后处理");


wire [31:0] instr_fetch_qout;
wire [31:0] instr_fetch_dnxt = (isInstrReadOut & ~instrFifo_full) ? instr_readout : instr_fetch_qout;
wire [63:0] pc_qout;
wire [63:0] pc_dnxt = (isInstrReadOut & ~instrFifo_full) ? pc_in : pc_qout;

assign pc_out = pc_qout;

assign instr = instr_fetch_qout;



gen_dffr # (.DW(64)) pc ( .dnxt(pc_dnxt), .qout(pc_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(32)) instr_fetch ( .dnxt(instr_fetch_dnxt), .qout(instr_fetch_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) handshake ( .dnxt(isInstrReadOut), .qout(fetch_decode_vaild), .CLK(CLK), .RSTn(RSTn));

endmodule


