/*
* @File name: branch_predict
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-18 15:56:30
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-19 11:51:13
*/


//在这里把地址计算出来，同时保留两者结果并根据预测算法决策，并和最终结果对比
//如果是JARL必需要跳，但是寄存器需要到发射之后才可以确定，因此需要在BLU中计算，预测没有意义，直接挂起取指即可


    assign rvi_return_o = rvi_jalr_o & ((instr_i[19:15] == 5'd1) | instr_i[19:15] == 5'd5)
                                     & (instr_i[19:15] != instr_i[11:7]);
    // Opocde is JAL[R] and destination register is either x1 or x5
    assign rvi_call_o   = (rvi_jalr_o | rvi_jump_o) & ((instr_i[11:7] == 5'd1) | instr_i[11:7] == 5'd5);
    // differentiates between JAL and BRANCH opcode, JALR comes from BHT
    assign rvi_imm_o    = (instr_i[3]) ? ariane_pkg::uj_imm(instr_i) : ariane_pkg::sb_imm(instr_i);
    assign rvi_branch_o = (instr_i[6:0] == riscv::OpcodeBranch);
    assign rvi_jalr_o   = (instr_i[6:0] == riscv::OpcodeJalr);
    assign rvi_jump_o   = (instr_i[6:0] == riscv::OpcodeJal);


module branch_pre (

	input isJal,
	input isJalr,
	input isBranch,


	input isCall,
	input isReturn,

	input [63:0] pc,
	input is_rvc_instr,
	input [63:0] imm


	input blu_jalr_vaild,
	input [63:0] blu_jalr_pc,


	output [63:0] taken_pc,
	output [63:0] next__pc,
	output isPreditTakenBranch,
	output isPredit,
	output predit_vaild,



);




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








