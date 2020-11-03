/*
* @File name: backEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-02 17:24:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-03 17:57:00
*/



module backEnd (

	output  [(64*RNDEPTH*32)-1:0] regFileX_dnxt,
	input [(64*RNDEPTH*32)-1:0] regFileX_qout,

	output [ RNBIT*32 - 1 :0 ] rnAct_X_dnxt,
	input [ RNBIT*32 - 1 :0 ] rnAct_X_qout,

	output [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	output [32*RNDEPTH-1 : 0] rnBufU_commit_rst,
	input [32*RNDEPTH-1 : 0] rnBufU_qout,

	output [32*RNDEPTH-1 : 0] wbLog_writeb_set,
	output [32*RNDEPTH-1 : 0] wbLog_commit_rst,
	input [32*RNDEPTH-1 : 0] wbLog_qout,

	output [ RNBIT*32 - 1 :0 ] archi_X_dnxt,
	input [ RNBIT*32 - 1 :0 ] archi_X_qout,



	input [DECODE_INFO_DW-1:0] decode_microInstr_pop,
	output instrFifo_pop,
	input instrFifo_empty,

	input CLK,
	input RSTn

);







//C3


	wire [`REORDER_INFO_DW-1:0] reOrder_info_data;
	wire reOrder_fifo_push;
	wire reOrder_fifo_ful;


	wire adder_buffer_push;
	wire adder_buffer_full;
	wire [`ADDER_ISSUE_INFO_DW-1:0] adder_dispat_info;

	wire logCmp_buffer_push;
	wire logCmp_buffer_full;
	wire [`LOGCMP_ISSUE_INFO_DW-1:0] logCmp_dispat_info;

	wire shift_buffer_push;
	wire shift_buffer_full;
	wire [`SHIFT_ISSUE_INFO_DW-1:0] shift_dispat_info;

	wire jal_buffer_push;
	wire jal_buffer_full;
	wire [`JAL_ISSUE_INFO_DW-1:0] jal_dispat_info;

	wire bru_dispat_push;
	wire bru_fifo_full;
	wire [`BRU_ISSUE_INFO_DW-1:0] bru_dispat_info;

	wire su_fifo_push;
	wire su_fifo_full;
	wire [`SU_ISSUE_INFO_DW-1:0] su_dispat_info;

	wire lu_buffer_push;
	wire lu_buffer_full;
	wire [`LU_ISSUE_INFO_DW-1:0] lu_dispat_info;

	wire fence_fifo_push;
	wire fence_fifo_full;
	wire [`FENCE_ISSUE_INFO_DW-1:0] fence_dispat_info;

	wire csr_buffer_push;
	wire csr_buffer_full;
	wire [`CSR_ISSUE_INFO_DW-1:0] csr_dispat_info;


dispatch i_dispatch(
	//for rename
	.rnAct_X_dnxt(rnAct_X_dnxt),
	.rnAct_X_qout(rnAct_X_qout),

	.rnBufU_rename_set(rnBufU_rename_set),
	.rnBufU_qout(rnBufU_qout),

	//from instr fifo
	.decode_microInstr_pop(decode_microInstr_pop),
	.instrFifo_pop(instrFifo_pop),
	.instrFifo_empty(instrFifo_empty),

	.reOrder_info_data(reOrder_info_data),
	.reOrder_fifo_push(reOrder_fifo_push),
	.reOrder_fifo_full(reOrder_fifo_full)



	//to issue
	.adder_buffer_push(adder_buffer_push),
	.adder_buffer_full(adder_buffer_full),
	.adder_dispat_info(adder_dispat_info),

	.logCmp_buffer_push(logCmp_buffer_push),
	.logCmp_buffer_full(logCmp_buffer_full),
	.logCmp_dispat_info(logCmp_dispat_info),

	.shift_buffer_push(shift_buffer_push),
	.shift_buffer_full(shift_buffer_full),
	.shift_dispat_info(shift_dispat_info),

	.jal_buffer_push(jal_buffer_push),
	.jal_buffer_full(jal_buffer_full),
	.jal_dispat_info(jal_dispat_info),

	.bru_fifo_push(bru_fifo_push),
	.bru_fifo_full(bru_fifo_full),
	.bru_dispat_info(bru_dispat_info),

	.su_fifo_push(su_fifo_push),
	.su_fifo_full(su_fifo_full),
	.su_dispat_info(su_dispat_info),

	.lu_buffer_push(lu_buffer_push),
	.lu_buffer_full(lu_buffer_full),
	.lu_dispat_info(lu_dispat_info),

	.fence_fifo_push(fence_fifo_push),
	.fence_fifo_full(fence_fifo_full),
	.fence_dispat_info(fence_dispat_info),

	.csr_buffer_push(csr_buffer_push),
	.csr_buffer_full(csr_buffer_full),
	.csr_dispat_info(csr_dispat_info),
);




//T3
issue_buffer #( .DW(`ADDER_ISSUE_INFO_DW), .DP(ADDER_ISSUE_DEPTH))
adder_issue_buffer
(
	.dispat_info(adder_dispat_info)
	.issue_info_qout

	.buffer_push(adder_buffer_push),
	.buffer_pop,	

	.buffer_full(adder_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
	.CLK(CLK),
	.RSTn(RSTn)	
);

issue_buffer #(.DW(`LOGCMP_ISSUE_INFO_DW), .DP(LOGCMP_ISSUE_DEPTH))
logCmp_issue_buffer
(
	.dispat_info(logCmp_dispat_info),
	.issue_info_qout

	.buffer_push(logCmp_buffer_push),
	.buffer_pop,	
	
	.buffer_full(logCmp_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
	.CLK(CLK),
	.RSTn(RSTn)	
	
);

issue_buffer #(	.DW(`SHIFT_ISSUE_INFO_DW), .DP(SHIFT_ISSUE_DEPTH))
shift_issue_buffer
(
	.dispat_info(shift_dispat_info),
	.issue_info_qout

	.buffer_push(shift_buffer_push),
	.buffer_pop,	
	
	.buffer_full(shift_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
	.CLK(CLK),
	.RSTn(RSTn)	
);

issue_buffer #(.DW(`JAL_ISSUE_INFO_DW),.DP(JAL_ISSUE_DEPTH))
jal_issue_buffer
(
	.dispat_info(jal_dispat_info),
	.issue_info_qout

	.buffer_push(jal_buffer_push),
	.buffer_pop,	
	
	.buffer_full(jal_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
	.CLK(CLK),
	.RSTn(RSTn)	
	
);


issue_fifo #( .DW(`BRU_ISSUE_INFO_DW), .DP(BRU_ISSUE_DEPTH))
bru_issue_fifo (
	.issue_info_push(bru_dispat_info)
	.issue_info_pop

	.issue_push(bru_fifo_push)
	.issue_pop
	.fifo_full(bru_fifo_full)
	.fifo_empty

	.CLK(CLK),
	.RSTn(RSTn)
);

issue_fifo #(.DW(`SU_ISSUE_INFO_DW), .DP(SU_ISSUE_DEPTH))
su_issue_fifo
(
	.issue_info_push(su_dispat_info)
	.issue_info_pop

	.issue_push(su_fifo_push)
	.issue_pop
	.fifo_full(su_fifo_full)
	.fifo_empty

	.CLK(CLK),
	.RSTn(RSTn)
	
);

issue_buffer #(.DW(`LU_ISSUE_INFO_DW),.DP(LU_ISSUE_DEPTH))
lu_issue_buffer
(
	.dispat_info(lu_dispat_info),
	.issue_info_qout

	.buffer_push(lu_buffer_push),
	.buffer_pop,	
	
	.buffer_full(lu_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
	.CLK(CLK),
	.RSTn(RSTn)	
	
);

issue_fifo #(.DW(`FENCE_ISSUE_INFO_DW),.DP(1),)
fence_issue_fifo
(
	.issue_info_push(fence_dispat_info)
	.issue_info_pop

	.issue_push(fence_fifo_push)
	.issue_pop
	.fifo_full(fence_fifo_full)
	.fifo_empty

	.CLK(CLK),
	.RSTn(RSTn)
	
);


issue_buffer #(.DW(`CSR_ISSUE_INFO_DW),.DP(CSR_ISSUE_DEPTH))
csr_issue_buffer
(
	.dispat_info(csr_dispat_info),
	.issue_info_qout

	.buffer_push(csr_buffer_push),
	.buffer_pop,	
	
	.buffer_full(csr_buffer_full),
	.buffer_vaild_qout
	.issue_pop_index,
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




















gen_fifo # (
	.DW(REORDER_INFO_DW),
	.AW(4)
)
reOrder_fifo(

	
	.fifo_push(reOrder_fifo_push),
	.data_push(reOrder_info_data),

	output fifo_empty, 
	.fifo_full(reOrder_fifo_full), 

	output [DW-1:0] data_pop,
	input fifo_pop, 

	input CLK,
	input RSTn
);














endmodule









