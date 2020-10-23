/*
* @File name: rename
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:29:53
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-23 16:04:34
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
	
	//from rob


	//from decode

	input rs1_vaild,
	input [4:0] decode_rs1,

	input rs2_vaild,
	input [4:0] decode_rs2,
	
	input rd_vaild,
	input [4:0] decode_rd0




	//from dispatch

	output dispatch_rs1_vaild,
	output [RNBIT-1:0] dispatch_rs1_reName,

	output dispatch_rs2_vaild,	
	output [RNBIT-1:0] dispatch_rs2_reName,

	output dispatch_rd_vaild,
	output [RNBIT-1:0] dispatch_rd0_reName


);







//读操作不会改变重命名活动指针，
//读操作需要通过重命名活动指针寻找正确的寄存器，
//写操作需要改变重命名活动指针到一个新位置，需要是空的，否则挂起流水线

wire [ RNBIT*32 - 1 :0 ] rnActive_X_din;
wire [ RNBIT*32 - 1 :0 ] rnActive_X_qout;

wire rnActive_X_din [RNBIT - 1 :0] = 'b0;
wire rnActive_X_qout [RNBIT - 1 :0] = 'b0;

generate
	for ( i = 1 ; i < 32; i = i + 1 ) begin

		rnActive_X_din[RNBIT*i +: RNBIT] = (decode_rd0 == i) ? inOrder_rd0_reName : rnActive_X_qout[RNBIT*i +: RNBIT];

		gen_dffr #(.DW(RNBIT)) rnActive_X ( .dnxt(rnActive_X_din[RNBIT*i +: RNBIT]), .qout(rnActive_X_qout[RNBIT*i +: RNBIT]), .CLK(CLK), .RSTn(RSTn) );
	end
endgenerate



wire [RNDEPTH-1:0] regX_used = rnBuffUsed_qout[ RNDEPTH*decode_rd0 +: RNDEPTH ];


//指示顺序执行当前应该读哪个寄存器
wire [RNBIT-1:0] inOrder_rs1_reName = rnActive_X[decode_rs1*RNBIT +: RNBIT];
wire [RNBIT-1:0] inOrder_rs2_reName = rnActive_X[decode_rs2*RNBIT +: RNBIT];
wire [RNBIT-1:0] inOrder_rd0_reName;




lzc #(
	.WIDTH(RNDEPTH),
	.CNT_WIDTH(RNBIT)
) (
	.in_i(regX_used),
	.cnt_o(inOrder_rd0_reName),
	.empty_o(regX_runOut)//rnmae buff is running out of reg rd
);

















endmodule








