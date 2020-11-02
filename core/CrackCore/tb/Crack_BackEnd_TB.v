/*
* @File name: Crack_BackEnd_TB
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-02 17:47:18
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 18:06:04
*/

module Crack_BackEnd_TB (

	
);



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




backEnd (

	.regFileX_dnxt,
	.regFileX_qout,

	.rnAct_X_dnxt,
	.rnAct_X_qout,

	.rnBufU_rename_set,
	.rnBufU_commit_rst,
	.rnBufU_qout,

	.wbLog_writeb_set,
	.wbLog_commit_rst,
	.wbLog_qout,

	.archi_X_dnxt,
	.archi_X_qout,


	input [DECODE_INFO_DW-1:0] decode_microInstr_pop,
	output instrFifo_pop,
	input instrFifo_empty,

	input CLK,
	input RSTn

);







phyRegister (

	input  [(64*RNDEPTH*32)-1:0] regFileX_dnxt,
	output [(64*RNDEPTH*32)-1:0] regFileX_qout,

	input [ RNBIT*32 - 1 :0 ] rnAct_X_dnxt,
	output [ RNBIT*32 - 1 :0 ] rnAct_X_qout,

	input [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	input [32*RNDEPTH-1 : 0] rnBufU_commit_rst,
	output [32*RNDEPTH-1 : 0] rnBufU_qout,

	input [32*RNDEPTH-1 : 0] wbLog_writeb_set,
	input [32*RNDEPTH-1 : 0] wbLog_commit_rst,
	output [32*RNDEPTH-1 : 0] wbLog_qout,

	input [ RNBIT*32 - 1 :0 ] archi_X_dnxt,
	output [ RNBIT*32 - 1 :0 ] archi_X_qout,


	input CLK,
	input RSTn
	
);










endmodule






