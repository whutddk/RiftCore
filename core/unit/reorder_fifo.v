/*
* @File name: reorder_buffer
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-23 17:41:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 17:16:46
*/


module reOrder_fifo (

	input  dispat_vaild,
	output iOrder_ready,
	input  [] iOrder_info_push,


	output iOrder_vaild,
	input commit_ready,
	output [] iOrder_info_pop,

	output empty,
	output full,
	
	input CLK,
	input RSTn
	
);









gen_fifo reOrder_fifo (
	.DP(MAXINDIS)
	.DW()
) #
(

	.vaild_a(dispat_vaild), 
	.ready_a(iOrder_ready), 
	.data_a(dispat_instr_info),

	.vaild_b(iOrder_vaild), 
	.ready_b(commit_ready), 
	.data_b(iOrder_instr_info),

	.empty(empty),
	.full(full),

	.CLK(CLK),
	.RSTn(RSTn)
);




























endmodule











