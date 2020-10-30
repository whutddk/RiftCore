/*
* @File name: issue_fifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 15:34:24
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 15:36:27
*/


module issue_fifo (
	parameter DW = 100,
	parameter DP = 8,
)


(

	input [ DW - 1 : 0] issue_info_push,
	output [ DW - 1 : 0] issue_info_pop,

	input issue_push,
	input issue_pop,
	output fifo_full,
	output fifo_empty,


	input CLK,
	input RSTn
	
);



genfifo ();







endmodule







