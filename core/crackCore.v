/*
* @File name: crackCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-31 15:44:17
*/



module crackCore (
	



	input CLK,
	input RSTn
	
);


















// FFFFFFFFFFFFFFFFFFFFFF                                                                tttt          EEEEEEEEEEEEEEEEEEEEEE                              d::::::d
// F::::::::::::::::::::F                                                             ttt:::t          E::::::::::::::::::::E                              d::::::d
// F::::::::::::::::::::F                                                             t:::::t          E::::::::::::::::::::E                              d::::::d
// FF::::::FFFFFFFFF::::F                                                             t:::::t          EE::::::EEEEEEEEE::::E                              d:::::d 
//   F:::::F       FFFFFFrrrrr   rrrrrrrrr      ooooooooooo   nnnn  nnnnnnnn    ttttttt:::::ttttttt      E:::::E       EEEEEEnnnn  nnnnnnnn        ddddddddd:::::d 
//   F:::::F             r::::rrr:::::::::r   oo:::::::::::oo n:::nn::::::::nn  t:::::::::::::::::t      E:::::E             n:::nn::::::::nn    dd::::::::::::::d 
//   F::::::FFFFFFFFFF   r:::::::::::::::::r o:::::::::::::::on::::::::::::::nn t:::::::::::::::::t      E::::::EEEEEEEEEE   n::::::::::::::nn  d::::::::::::::::d 
//   F:::::::::::::::F   rr::::::rrrrr::::::ro:::::ooooo:::::onn:::::::::::::::ntttttt:::::::tttttt      E:::::::::::::::E   nn:::::::::::::::nd:::::::ddddd:::::d 
//   F:::::::::::::::F    r:::::r     r:::::ro::::o     o::::o  n:::::nnnn:::::n      t:::::t            E:::::::::::::::E     n:::::nnnn:::::nd::::::d    d:::::d 
//   F::::::FFFFFFFFFF    r:::::r     rrrrrrro::::o     o::::o  n::::n    n::::n      t:::::t            E::::::EEEEEEEEEE     n::::n    n::::nd:::::d     d:::::d 
//   F:::::F              r:::::r            o::::o     o::::o  n::::n    n::::n      t:::::t            E:::::E               n::::n    n::::nd:::::d     d:::::d 
//   F:::::F              r:::::r            o::::o     o::::o  n::::n    n::::n      t:::::t    tttttt  E:::::E       EEEEEE  n::::n    n::::nd:::::d     d:::::d 
// FF:::::::FF            r:::::r            o:::::ooooo:::::o  n::::n    n::::n      t::::::tttt:::::tEE::::::EEEEEEEE:::::E  n::::n    n::::nd::::::ddddd::::::dd
// F::::::::FF            r:::::r            o:::::::::::::::o  n::::n    n::::n      tt::::::::::::::tE::::::::::::::::::::E  n::::n    n::::n d:::::::::::::::::d
// F::::::::FF            r:::::r             oo:::::::::::oo   n::::n    n::::n        tt:::::::::::ttE::::::::::::::::::::E  n::::n    n::::n  d:::::::::ddd::::d
// FFFFFFFFFFF            rrrrrrr               ooooooooooo     nnnnnn    nnnnnn          ttttttttttt  EEEEEEEEEEEEEEEEEEEEEE  nnnnnn    nnnnnn   ddddddddd   ddddd








//                                                                                                                                 dddddddd
// BBBBBBBBBBBBBBBBB                                        kkkkkkkk           EEEEEEEEEEEEEEEEEEEEEE                              d::::::d
// B::::::::::::::::B                                       k::::::k           E::::::::::::::::::::E                              d::::::d
// B::::::BBBBBB:::::B                                      k::::::k           E::::::::::::::::::::E                              d::::::d
// BB:::::B     B:::::B                                     k::::::k           EE::::::EEEEEEEEE::::E                              d:::::d 
//   B::::B     B:::::B  aaaaaaaaaaaaa      cccccccccccccccc k:::::k    kkkkkkk  E:::::E       EEEEEEnnnn  nnnnnnnn        ddddddddd:::::d 
//   B::::B     B:::::B  a::::::::::::a   cc:::::::::::::::c k:::::k   k:::::k   E:::::E             n:::nn::::::::nn    dd::::::::::::::d 
//   B::::BBBBBB:::::B   aaaaaaaaa:::::a c:::::::::::::::::c k:::::k  k:::::k    E::::::EEEEEEEEEE   n::::::::::::::nn  d::::::::::::::::d 
//   B:::::::::::::BB             a::::ac:::::::cccccc:::::c k:::::k k:::::k     E:::::::::::::::E   nn:::::::::::::::nd:::::::ddddd:::::d 
//   B::::BBBBBB:::::B     aaaaaaa:::::ac::::::c     ccccccc k::::::k:::::k      E:::::::::::::::E     n:::::nnnn:::::nd::::::d    d:::::d 
//   B::::B     B:::::B  aa::::::::::::ac:::::c              k:::::::::::k       E::::::EEEEEEEEEE     n::::n    n::::nd:::::d     d:::::d 
//   B::::B     B:::::B a::::aaaa::::::ac:::::c              k:::::::::::k       E:::::E               n::::n    n::::nd:::::d     d:::::d 
//   B::::B     B:::::Ba::::a    a:::::ac::::::c     ccccccc k::::::k:::::k      E:::::E       EEEEEE  n::::n    n::::nd:::::d     d:::::d 
// BB:::::BBBBBB::::::Ba::::a    a:::::ac:::::::cccccc:::::ck::::::k k:::::k   EE::::::EEEEEEEE:::::E  n::::n    n::::nd::::::ddddd::::::dd
// B:::::::::::::::::B a:::::aaaa::::::a c:::::::::::::::::ck::::::k  k:::::k  E::::::::::::::::::::E  n::::n    n::::n d:::::::::::::::::d
// B::::::::::::::::B   a::::::::::aa:::a cc:::::::::::::::ck::::::k   k:::::k E::::::::::::::::::::E  n::::n    n::::n  d:::::::::ddd::::d
// BBBBBBBBBBBBBBBBB     aaaaaaaaaa  aaaa   cccccccccccccccckkkkkkkk    kkkkkkkEEEEEEEEEEEEEEEEEEEEEE  nnnnnn    nnnnnn   ddddddddd   ddddd


//T2

gen_fifo # (.DW(DECODE_INFO_DW),.AW(4)) 
	instr_fifo (
		.fifo_pop(1'b0),
		.fifo_push(instrFifo_push),

		.data_push(decode_microInstr),
		.data_pop(),

		.fifo_empty(),
		.fifo_full(instrFifo_full),

		.CLK(CLK),
		.RSTn(RSTn)
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






//handshark

wire pcGenerate_ready
wire preFetch_ready;
wire fetch_ready;

wire instrFifo_full;



wire adderIssue_ready;
wire jalrIssue_ready;
wire bruIssue_ready;
wire logCmpIssue_ready;
wire lsuIssue_ready;
wire csrIssue_ready;

wire adderExe_ready;
wire jalrExe_ready;
wire bruExe_ready;
wire logCmpExe_ready;
wire lsuExe_ready;
wire csrExe_ready;



endmodule














