/*
* @File name: issue_fifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-28 15:34:24
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 10:49:23
*/

`timescale 1 ns / 1 ps

module issue_fifo #(
	parameter DW = 100,
	parameter DP = 8
)
(

	input [ DW - 1 : 0] issue_info_push,
	output [ DW - 1 : 0] issue_info_pop,

	input issue_push,
	input issue_pop,
	output fifo_full,
	output fifo_empty,

	input flush,
	input CLK,
	input RSTn
	
);



gen_fifo # ( .DW(DW), .AW($clog2(DP)))
i_fifo(
	.fifo_pop(issue_pop), 
	.fifo_push(issue_push),
	.data_push(issue_info_push),

	.fifo_empty(fifo_empty), 
	.fifo_full(fifo_full), 
	.data_pop(issue_info_pop),

	.flush(flush),
	.CLK(CLK),
	.RSTn(RSTn)
);




endmodule







