/*
* @File name: rename
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:29:53
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-19 14:59:28
*/


//根据 ROB表中记录的实际寄存器使用情况，重新分配寄存器并记录回ROB
//1
//出现WAW,WAR，写之后写，写之后读
// 写后写： rd与之前rd被占用
// 写后读： rd与之前rs被占用
//都是处理rd

//2
//rs1，rs2对之前的rd的依赖

//建议32-16-16的3级映射


module rename (
	
	//from rob


	//from decode

	input decode_rs1,
	input decode_rs2,
	input decode_rd

	//from dispatch


	output rename_dispatch_vaild,
	input rename_dispatch_ready,
	output dispatch_rs1,
	output dispatch_rs2,
	output dispatch_rd


);




endmodule








