/*
* @File name: lsu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:21
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 10:52:48
*/



module lsu_issue (



	input lsu_issue_vaild,
	output lsu_issue_ready,
	input [:] lsu_issue_info,





	
);





gen_fifo lsu_issue_fifo (
	.DP(8)
	.DW()
) #
(

	.vaild_a, 
	.ready_a, 
	.data_a(),

	.vaild_b(), 
	.ready_b(), 
	.data_b(),

	.CLK,
	.RSTn
);











endmodule
