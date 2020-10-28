/*
* @File name: bru
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-20 16:41:01
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 17:33:48
*/

/*
// 会发生跳转的情况：
1.跳转指令（来自函数调用、返回、分支），均为指令形式由blu处理
2.中断，异常，无法预测
*/

module bru (

	//from bru issue
	output bru_execute_ready,
	input bru_execute_vaild,
	input [ :0] bru_execute_info, 


	// to pc generate
	output blu_takenBranch,


	// to writeback
	output [(5+RNBIT-1):0] rd0,
	output [63:0] bru_result



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


wire blu_takenBranch = take_eq | take_ne | take_lt | take_gt | take_ltu | take_gtu;



assign rd0 = 'b0;
assign bru_result = 'b0;











endmodule






