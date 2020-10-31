/*
* @File name: instr_fetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:40:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-31 15:24:25
*/

module instr_fetch (
	input [31:0] instr_readout,
	output [31:0] instr_fetch，
	
	//handshake
	input isInstrReadOut,
	output fetch_decode_vaild,
	input instrFifo_full,

	input flush,
	input CLK,
	input RSTn
);





$warning("预留一拍做后处理");
assign instr_fetch = instr_readout;


wire [31:0] instr_fetch_dnxt = (isInstrReadOut & ~instrFifo_full) ? instr_readout : instr_fetch_qout;
wire [31:0] instr_fetch_qout;
assign instr_fetch = instr_fetch_qout;


gen_dffr # (.DW(32)) instr_fetch ( .dnxt(instr_fetch_dnxt), .qout(instr_fetch_qout), .CLK(CLK), .RSTn());
gen_dffr # (.DW(1)) handshake ( .dnxt(isInstrReadOut), .qout(fetch_decode_vaild), .CLK(CLK), .RSTn());

endmodule


