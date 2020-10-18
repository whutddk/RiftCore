/*
* @File name: branch_pre
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-18 15:56:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-18 18:09:30
*/


//在这里把地址计算出来，同时保留两者结果并根据预测算法决策，并和最终结果对比
//如果是JARL必需要跳，但是寄存器需要到发射之后才可以确定，因此需要在BLU中计算，预测没有意义，直接挂起取指即可

module branch_pre (

	input blu_jal,
	input blu_jalr,
	input blu_eq,
	input blu_ne,
	input blu_lt,
	input blu_gt,
	input blu_ltu,
	input blu_gtu,

	input isCall,
	input isReturn,



	input [63:0] pc,
	input is_rvc_instr,
	input [63:0] imm


	input blu_jalr_vaild,
	input [63:0] blu_jalr_pc,


	output [63:0] taken_pc,
	output [63:0] untaken_pc,
	output isPreditTakenBranch,
	output predit_vaild,



);







//分支预测算法
assign isPreditTakenBranch = ( (blu_eq | blu_ne | blu_lt | blu_gt | blu_ltu | blu_gtu) & ( (imm[63] == 1'b0) : 1'b1 : 1'b0) )
							| blu_jal | blu_jalr; 




//RAS 返回地址堆栈


wire [63:0] ras_pop_addr;
wire [63:0] ras_push_addr;


wrie ras_full;
wire ras_empty;



wire ras_push = isCall & ( blu_jal | blu_jalr );
wire ras_pop = isReturn & ( blu_jalr ) & ( !ras_empty );

//计算两种分支结果
wire [63:0] untake_pc = pc + ( is_rvc_instr ? 64'd2 : 64'd4 );
wire [63:0] take_pc = ( {64{blu_jal | blu_eq | blu_ne | blu_lt | blu_gt | blu_ltu | blu_gtu}} & (pc + imm)
					| ( {64{blu_jalr &  ras_pop}} & ras_pop_addr ) 
					| ( {64{blu_jalr & !ras_pop & blu_jalr_vaild}} & blu_jalr_pc  );


assign ras_push_addr = untake_pc;



assign predit_vaild = ( blu_jal | blu_eq | blu_ne | blu_lt | blu_gt | blu_ltu | blu_gtu )
					| ras_pop
					| ( blu_jalr & blu_jalr_vaild );



//使用 ring-buff策略，压栈不会压爆，但是会空
ras #(
	.DEPTH(10)
)
i_ras
(
	.CLK(),
	.RSTn(),
	.flush(),

	.push(ras_push),
	.pop(ras_pop),

	.push_addr(ras_push_addr),
	.pop_addr(ras_pop_addr),

	.empty(ras_empty)
);






endmodule








