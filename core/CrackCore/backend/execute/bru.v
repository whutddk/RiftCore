/*
* @File name: bru
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 16:41:01
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 15:20:52
*/

module bru (

	//from bru issue
	output bru_exeparam_ready,
	input bru_exeparam_vaild,
	input [`BRU_EXEPARAM_DW-1:0] bru_exeparam, 


	// to pc generate
	input pcGen_ready,
	output takenBranch_qout,
	output takenBranch_vaild_qout,


	input CLK,
	input RSTn

);


	wire bru_eq;
	wire bru_ne;
	wire bru_lt;
	wire bru_gt;
	wire bru_ltu;
	wire bru_gtu;

	wire [63:0] op1;
	wire [63:0] op2;


	assign { 
			bru_eq,
			bru_ne,
			bru_lt,
			bru_gt,
			bru_ltu,
			bru_gtu,

			op1,
			op2
			} = bru_execute_info;



wire take_eq = (bru_eq & (op1 == op2));
wire take_ne = (bru_ne & (op1 != op2));
wire take_lt = (bru_lt) & ($signed(op1) < $signed(op2));
wire take_gt = (bru_gt) & ($signed(op1) > $signed(op2));
wire take_ltu = (bru_ltu) & ($unsigned(op1) < $unsigned(op2));
wire take_gtu = (bru_gtu) & ($unsigned(op1) > $unsigned(op2));

initial $info("没有ready则不更新");
wire takenBranch_dnxt = vaild_dnxt 
							? (take_eq | take_ne | take_lt | take_gt | take_ltu | take_gtu)
							: takenBranch_qout;

initial $info("pcGen 没有准备好收或者上级空");
wire vaild_dnxt = pcGen_ready & bru_exeparam_vaild;


gen_dffr # (.DW(1)) takenBranch ( .dnxt(takenBranch_dnxt), .qout(takenBranch_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) vaild ( .dnxt(vaild_dnxt), .qout(takenBranch_vaild_qout), .CLK(CLK), .RSTn(RSTn));


assign bru_exeparam_ready = pcGen_ready;

endmodule






