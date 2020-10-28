/*
* @File name: csr_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:47
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 10:52:54
*/



module csr_issue (
	


	input csr_issue_vaild,
	output csr_issue_ready,
	input [:] csr_issue_info,







	
);





gen_fifo csr_issue_fifo (
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











