/*
* @File name: branch_predict
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-18 15:56:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-29 11:31:10
*/


//在这里把地址计算出来，同时保留两者结果并根据预测算法决策，并和最终结果对比
//如果是JARL必需要跳，但是寄存器需要到发射之后才可以确定，因此需要在BLU中计算，预测没有意义，直接挂起取指即可


module branch_predict (

	//to decode
	input fetch_decode_ready,
	input [31:0] instr,
	input fetch_decode_vaild


	input [63:0] pc,



	input blu_jalr_vaild,
	input [63:0] blu_jalr_pc,


	output [63:0] taken_pc,
	output [63:0] next_pc,
	output isPreditTakenBranch,
	output isPredit,
	output predit_vaild,



);

	wire isJal = (instr[6:0] == 7'b1101111);
	wire isJalr = (instr[6:0] == 7'b1100111);
	wire isBranch = (instr[6:0] == 7'b1100011);

	wire isCall = (isJalr | isJal) & ((instr[11:7] == 5'd1) | instr[11:7] == 5'd5);;
	wire isReturn = isJalr & ((instr[19:15] == 5'd1) | instr[19:15] == 5'd5)
                                     & (instr[19:15] != instr[11:7]);;


    $warning("在没有压缩指令的情况下");
	wire is_rvc_instr = 1'b0;
	wire [63:0] imm = ({64{isJal}} & {{44{instr_i[31]}},instr_i[19:12],instr_i[20],instr_i[30:21],1'b0})
	|
	({64{isJalr}} & {{52{instr_i[31]}},instr_i[31:20]})
	|
	({64{isBranch}} & {{52{instr_i[31]}},instr_i[7],instr_i[30:25],instr_i[11:8],1'b0});












//分支预测算法,分支指令才预测，直接跳转指令和其他指令不预测
assign isPredit = isBranch

//分支指令只预测向后跳则采用taken结果，无条件跳转直接采用taken结果，分支前跳和其他指令采用pc自增组
assign isTakenBranch = ( (isBranch) & ( (imm[63] == 1'b0) : 1'b1 : 1'b0) )
						| (isJal | isJalr); 




//RAS 返回地址堆栈


wire [63:0] ras_pop_addr;
wire [63:0] ras_push_addr;


wrie ras_full;
wire ras_empty;

wire ras_push = isCall & ( isJal | isJalr );
wire ras_pop = isReturn & ( isJalr ) & ( !ras_empty );

//计算两种分支结果
wire [63:0] next_pc = pc + ( is_rvc_instr ? 64'd2 : 64'd4 );
wire [63:0] take_pc = ( {64{isJal | isBranchu}} & (pc + imm)
					| ( {64{isJalr &  ras_pop}} & ras_pop_addr ) 
					| ( {64{isJalr & !ras_pop & blu_jalr_vaild}} & blu_jalr_pc  );


assign ras_push_addr = next_pc;


//只有在jalr才有可能卡流水线
assign predit_vaild =  ( isJalr & isReturn & !ras_empty ) //ras_pop
						| ( isJalr & (~isReturn | ras_empty) & blu_jalr_vaild )
						| (~isJalr );



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








