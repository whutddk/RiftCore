/*
* @File name: issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-19 15:26:48
*/


//接收从dispatch来的指令压入各自的fifo
//根据单元空闲情况及RAW相关性处理

module issue (
	
	//from dispatch

	output alu_issue_ready,
	output lsu_issue_ready,
	output csr_issue_ready,
	output blu_issue_ready,



	//from execute







	// from scoreboard 





);




gen_fifo alu_issue_fifo (
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



gen_fifo blu_issue_fifo (
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
