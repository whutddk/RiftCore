/*
* @File name: crackCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-30 19:00:05
*/



module crackCore (
	



	input CLK,
	input RSTn
	
);




//C0
pc_generate i_pcgenerate();





//T0
instr_preFetch (

	//from pc_generate
	input [63:0] fetch_pc,
	input pcGen_fetch_vaild,

	//to decode
	input fetch_decode_ready,
	output [31:0]fetch_instr,
	output fetch_decode_vaild,
);


//C1
instr_fetch ();

//T1
$info("此拍必打，不做旁路");
gen_fifo # (.DW(64),.AW(2)) 
		fetch_fifo (
			.fifo_pop(), .fifo_push(), .data_push(), .data_pop(), .fifo_empty(), .fifo_full(), .CLK(CLK), .RSTn(RSTn)
					);


//C2
decode i_decode();


//T2
$info("此拍必打，不做旁路");
gen_fifo # (.DW(64),.AW(2)) 
		decode_fifo (
			.fifo_pop(), .fifo_push(), .data_push(), .data_pop(), .fifo_empty(), .fifo_full(), .CLK(CLK), .RSTn(RSTn)
					);

//C3
rename i_rename();
dispatch i_dispatch();

//T3
issue_buffer #( .DW(), .DP(ADDER_ISSUE_DEPTH),)
 adder_issue_buffer
(
	.issue_info_push(adder_issue_info_push),
	.issue_push(adder_issue_push),
	.buffer_full(adder_buffer_full),

	.issue_pop(adder_issue_pop),
	.issue_pop_index(adder_issue_pop_index),
	.issue_info_qout(adder_issue_info_qout),
	.buffer_vaild_qout(adder_buffer_vaild_qout),

	.CLK(CLK),
	.RSTn(RSTn)	
);


issue_fifo #( .DW(), .DP(BRU_ISSUE_DEPTH))
bru_issue_fifo (
	.issue_info_push(bru_issue_info_push),
	.issue_info_pop(bru_issue_info_pop),

	.issue_push(bru_issue_push),
	.issue_pop(bru_issue_pop),
	.fifo_full(bru_fifo_full),
	.fifo_empty(bru_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
);

gen_dffr csr_issue_buffer

issue_buffer 
(
	.DW(),
	.DP(JAL_ISSUE_DEPTH),
)
# jal_issue_buffer
(

	.issue_info_push(jal_issue_info_push),
	.issue_push(jal_issue_push),
	.buffer_full(jal_buffer_full),

	.issue_pop(jal_issue_pop),
	.issue_pop_index(jal_issue_pop_index),
	.issue_info_qout(jal_issue_info_qout),
	.buffer_vaild_qout(jal_buffer_vaild_qout),

	.CLK(CLK),
	.RSTn(RSTn)
	
);

issue_buffer 
(
	.DW(),
	.DP(LOGCMP_ISSUE_DEPTH),
)
# logCmp_issue_buffer
(

	.issue_info_push(logCmp_issue_info_push),
	.issue_push(logCmp_issue_push),
	.buffer_full(logCmp_buffer_full),

	.issue_pop(logCmp_issue_pop),
	.issue_pop_index(logCmp_issue_pop_index),
	.issue_info_qout(logCmp_issue_info_qout),
	.buffer_vaild_qout(logCmp_buffer_vaild_qout),

	.CLK(CLK),
	.RSTn(RSTn)
	
);
	issue_buffer #
	(
		.DW(),
		.DP(LU_ISSUE_DEPTH),
	)
	lu_issue_buffer
	(

		.issue_info_push(lu_issue_info_push),
		.issue_push(lu_issue_push),
		.buffer_full(lu_buffer_full),

		.issue_pop(lu_issue_pop),
		.issue_pop_index(lu_issue_pop_index),
		.issue_info_qout(lu_issue_info_qout),
		.buffer_vaild_qout(lu_buffer_vaild_qout),

		.CLK(CLK),
		.RSTn(RSTn)
		
	);


issue_fifo #(
	.DW(),
	.DP(SU_ISSUE_DEPTH),
)
su_issue_fifo
(
	.issue_info_push(su_issue_info_push),
	.issue_info_pop(su_issue_info_pop),

	.issue_push(su_issue_push),
	.issue_pop(su_issue_pop),
	.fifo_full(su_fifo_full),
	.fifo_empty(su_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
	
);

issue_fifo #(
	.DW(),
	.DP(1),
)
fence_issue_fifo
(
	.issue_info_push(fence_issue_info_push),
	.issue_info_pop(fence_issue_info_pop),

	.issue_push(fence_issue_push),
	.issue_pop(fence_issue_pop),
	.fifo_full(fence_fifo_full),
	.fifo_empty(fence_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
	
);






//C4

adder_issue ();
bru_issue ();
csr_issue ();
jal_issue ();
logCmp_issue ();
lsu_issue ();
shift_issue ();


//T4
gen_dffr exe_param;


//C5 Tadd
adder ();
bru ();
csr_issue ();
jal ();
logCmp ();
lsu ();
shift ();

//T5
gen_dffr exe_res;

//T6
writeBack i_writeBack();


//T7
commit ();








//TN

reOrder_fifo ();
phyRegister ();



endmodule














