/*
* @File name: bru
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 16:41:01
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 14:18:40
*/
`timescale 1 ns / 1 ps
`include "define.vh"

module bru #
	(
		parameter DW = `BRU_EXEPARAM_DW
	)
	(

	//from bru issue
	output bru_exeparam_ready,
	input bru_exeparam_vaild,
	input [DW-1:0] bru_exeparam, 

	// to pc generate
	input bru_pcGen_ready,
	output takenBranch_qout,
	output takenBranch_vaild_qout,


	output bru_writeback_vaild,
	output [63:0] bru_res_qout,
	output [(5+`RB)-1:0] bru_rd0_qout,

	input flush,
	input CLK,
	input RSTn

);


	wire bru_eq;
	wire bru_ne;
	wire bru_lt;
	wire bru_ge;
	wire bru_ltu;
	wire bru_geu;

	wire [63:0] op1;
	wire [63:0] op2;
	wire [(5+`RB)-1:0] bru_rd0_dnxt;



	assign { 
			bru_eq,
			bru_ne,
			bru_lt,
			bru_ge,
			bru_ltu,
			bru_geu,

			bru_rd0_dnxt,
			op1,
			op2
			} = bru_exeparam;



wire take_eq = (bru_eq & (op1 == op2));
wire take_ne = (bru_ne & (op1 != op2));
wire take_lt = (bru_lt) & ($signed(op1) < $signed(op2));
wire take_ge = (bru_ge) & ($signed(op1) >= $signed(op2));
wire take_ltu = (bru_ltu) & ($unsigned(op1) < $unsigned(op2));
wire take_geu = (bru_geu) & ($unsigned(op1) >= $unsigned(op2));

initial $info("没有ready则不更新");
wire takenBranch_dnxt = vaild_dnxt 
							? (take_eq | take_ne | take_lt | take_ge | take_ltu | take_geu)
							: takenBranch_qout;

initial $info("pcGen 没有准备好收或者上级空");
wire vaild_dnxt = bru_pcGen_ready & bru_exeparam_vaild;


gen_dffr # (.DW(1)) takenBranch ( .dnxt(takenBranch_dnxt), .qout(takenBranch_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(vaild_dnxt&(~flush)), .qout(takenBranch_vaild_qout), .CLK(CLK), .RSTn(RSTn));


assign bru_exeparam_ready = bru_pcGen_ready;


gen_dffr # (.DW((5+`RB))) bru_rd0 ( .dnxt(bru_rd0_dnxt), .qout(bru_rd0_qout), .CLK(CLK), .RSTn(RSTn));
assign bru_res_qout = 64'b0;
assign bru_writeback_vaild = takenBranch_vaild_qout;





endmodule






