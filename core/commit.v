/*
* @File name: commit
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 17:15:16
*/

module commit (

	//from phyRegister


	output [ RNBIT*32 - 1 :0 ] archi_X_dnxt,
	input  [ RNBIT*32 - 1 :0 ] archi_X_qout,

	output [32*RNDEPTH-1 : 0] wbLog_commit_rst,
	input [32*RNDEPTH-1 : 0] wbLog_qout,

	output [32*RNDEPTH-1 : 0] rnBufU_commit_rst,

	//from inOrder FIFO
	input [:] iOrder_info_pop,

	//from branch predit 
	//此处只需要向前握手进行pop，因为一定有数据
	input 


	//from Outsize
	input isAsynExcept,
);


	wire [63:0] commit_pc;
	wire [5+RNBIT-1:0] commit_rd0;
	wire isBranch;

	assign iOrder_info_pop = {commit_pc, commit_rd0, isBranch, isSynExcept};

	wire isMisPredict = 
	wire commit_abort = isBranch & (isMisPredict) 
						| (isSynExcept)
						| (isAsynExcept);


	assign rnBufU_commit_rst = wbLog_commit_rst;

generate
	for ( genvar regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( genvar depth = 0 ; depth < RNDEPTH; depth = depth + 1 ) begin

			localparam SEL = regNum*4+depth;


			assign archi_X_dnxt[regNum] = ((wbLog_qout[SEL] == 1'b1) & (commit_rd0 == SEL) & (~commit_abort))
											?  depth
											: archi_X_qout[regNum];


			assign wbLog_commit_rst[archi_X_qout[regNum]] = (wbLog_qout[SEL] == 1'b1) & (commit_rd0 == SEL) & (~commit_abort)
															? 1'b0
															: 1'b1;
		end
	end
endgenerate







endmodule


