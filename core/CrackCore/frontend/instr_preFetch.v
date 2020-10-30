/*
* @File name: instr_preFetch
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 09:27:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-30 18:01:10
*/




module instr_preFetch (

	//from pc_generate
	input [63:0] fetch_pc,
	input pcGen_fetch_vaild,

	//to decode
	input fetch_decode_ready,
	output [31:0]fetch_instr,
	output fetch_decode_vaild
);



wire isITCM = (fetch_pc & 64'h8000_0000);
$warning("在没有cache的情况下");
wire isCache = 1'b0;





wire [31:0] load_instr;











$warning("在没有调试器访问写入的情况下");
itcm #
	(
		.DW(32),
		.AW(14),
	)i_itcm
	(

	.addr(fetch_pc[2 +: 14]),
	.instr_out(load_instr),

	.instr_in('b0),
	.wen('b0),

	.CLK(CLK)
	
);


$warning("在没有压缩指令的情况下");
wire is_rvc = 1'b0;

$warning("在不考虑压缩指令并强制32bit对齐的情况下");
assign fetch_instr = load_instr;

$warning("在使用ITCM强制一拍必出指令的情况下")
assign fetch_decode_vaild = 1'b1;





endmodule






