/*
* @File name: commit
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-06 14:59:27
*/

`include "define.vh"

module commit (

	//from phyRegister
	output [ `RB*32 - 1 :0 ] archi_X_dnxt,
	input  [ `RB*32 - 1 :0 ] archi_X_qout,

	output [32*`RP-1 : 0] wbLog_commit_rst,
	input [32*`RP-1 : 0] wbLog_qout,

	output [32*`RP-1 : 0] rnBufU_commit_rst,

	//from reOrder FIFO
	input [`REORDER_INFO_DW-1:0] commit_fifo,
	input reOrder_fifo_empty,
	output reOrder_fifo_pop,

	//from pc generate 
	//此处只需要向前握手进行pop，因为一定有数据
	input isMisPredict,
	output commit_abort,

	//from Outsize
	input isAsynExcept,

	output csrILP_ready,
	output suILP_ready
);

initial $warning("暂时无法产生异常");
	wire isSynExcept  = 1'b0;

	wire [63:0] commit_pc;
	wire [5+`RB-1:0] commit_rd0;
	wire isBranch;

	wire isSu;
	wire isCsr;

	assign csrILP_ready = isCsr;
	assign suILP_ready = isSu;

	assign {commit_pc, commit_rd0, isBranch, isSu, isCsr} = commit_fifo;

	assign commit_abort = (isBranch & isMisPredict) 
						| (isSynExcept)
						| (isAsynExcept);



	assign rnBufU_commit_rst = wbLog_commit_rst;

	assign reOrder_fifo_pop = commit_comfirm;

	wire commit_wb = (wbLog_qout[commit_rd0] == 1'b1) & (~reOrder_fifo_empty);
	wire commit_comfirm = ~commit_abort & commit_wb; 

generate
	for ( genvar regNum = 0; regNum < 32; regNum = regNum + 1 ) begin

			assign archi_X_dnxt[regNum*`RB +: `RB] = (( regNum == commit_rd0[`RB +: 5] ) & commit_comfirm)
											? commit_rd0[`RB-1:0]
											: archi_X_qout[regNum*`RB +: `RB];
	end
endgenerate

	assign wbLog_commit_rst = commit_comfirm ? 1'b1 << commit_rd0 : {32*`RP{1'b0}};





endmodule


