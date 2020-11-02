/*
* @File name: crackCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 17:42:34
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

		.data_push(decode_microInstr_push),
		.data_pop(decode_microInstr_pop),

		.fifo_empty(instrFifo_empty),
		.fifo_full(instrFifo_full),

		.CLK(CLK),
		.RSTn(RSTn)
);























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














