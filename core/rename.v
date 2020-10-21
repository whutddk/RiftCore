/*
* @File name: rename
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:29:53
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-21 14:34:45
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
	input [4:0] decode_rd

	//from dispatch

	output dispatch_rs1_vaild,
	output [63:0] dispatch_rs1,

	output dispatch_rs2_vaild,	
	output [63:0] dispatch_rs2,

	output dispatch_rd_vaild,
	output [127:0] dispatch_rdIndex


);



wire hazard_waw;
wire hazard_war;


//指向当前前端可以用的寄存器位置（只会读寄存器），读完不管
//同时更新对应rd寄存器为新指针
wire  [ 5*31 - 1 :0 ] inOrder_x_rs1read;
wire  [ 5*31 - 1 :0 ] inOrder_x_rs2read;
wire  [ 5*31 - 1 :0 ] inOrder_x_rdupdate;

wire [4:0] inOrder_rs1read = inOrder_x_rs1read[decode_rs1]
wire [4:0] inOrder_rs2read

assign dispatch_rs1 =  ({64{decode_rs1 == 4'd0}} & 64'b0) 
						| 
						( {64{decode_rs1[4:2] == 3'b000}} & regFile_x00_x03_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b001}} & regFile_x04_x07_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b010}} & regFile_x08_x11_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b011}} & regFile_x12_x15_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b100}} & regFile_x16_x19_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b101}} & regFile_x20_x23_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b110}} & regFile_x24_x27_read[  ] )
						| 
						( {64{decode_rs1[4:2] == 3'b111}} & regFile_x28_x31_read[  ] )
						




assign dispatch_rs2 = 




endgenerate









endmodule








