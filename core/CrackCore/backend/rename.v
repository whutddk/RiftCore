/*
* @File name: rename
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:29:53
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-03 16:18:45
*/


//根据 ROB表中记录的实际寄存器使用情况，重新分配寄存器并记录回ROB
//1
//出现WAW,WAR，写之后写，写之后读
// 写后写： rd与之前rd被占用
// 写后读： rd与之前rs被占用
//都是处理rd

//2
//rs1，rs2对之前的rd的依赖

//建议8组，每组4个寄存器，总共16组，共128个物理寄存器


module rename (

	output [ RNBIT*32 - 1 :0 ] rnAct_X_dnxt,
	input [ RNBIT*32 - 1 :0 ] rnAct_X_qout,	

	output [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	input [32*RNDEPTH-1 : 0] rnBufU_qout,

	input [4:0] rs1_raw,
	output [RNBIT-1:0] rs1_reName,

	input [4:0] rs2_raw,
	output [RNBIT-1:0] rs2_reName,
	
	input rd0_raw_vaild,
	input [4:0] rd0_raw,
	output [RNBIT-1:0] rd0_reName,
	output rd0_runOut

);





assign rnAct_X_dnxt[ 0 +: RNBIT] = {RNBIT{1'b0}};
generate
	for ( genvar i = 1;  i < 32; i = i + 1 )begin
		assign rnAct_X_dnxt[RNBIT*i +: RNBIT] = ( (rd0_raw == i) & rd0_vaild & ~rd0_runOut ) ? rd0_reName : rnAct_X_qout[RNBIT*i +: RNBIT];
	end
endgenerate
	


//指示顺序执行当前应该读哪个寄存器
assign rs1_reName = rnAct_X_qout[rs1_raw*RNBIT +: RNBIT];
assign rs2_reName = rnAct_X_qout[rs2_raw*RNBIT +: RNBIT];



wire [RNDEPTH-1:0] regX_used = rnBufU_qout[ RNDEPTH*rd0_raw +: RNDEPTH ];

lzp #(
	.CW(RNBIT)
) rd0_index(
	.in_i(regX_used),
	.pos_o(rd0_reName),
	.full_o(rd0_runOut),
	.empty_o()
);



assign rnBufU_rename_set = (rd0_vaild & ~rd0_runOut)
								? {32*RNDEPTH{1'b0}} | (1'b1 << rd0_reName)
								: {32*RNDEPTH{1'b0}};













endmodule








