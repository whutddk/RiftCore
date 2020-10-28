/*
* @File name: bru_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:50:36
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 17:32:39
*/


module bru_issue (


	input bru_issue_vaild,
	output bru_issue_ready,
	input [:] bru_issue_info_push,



	//from execute

	// input bru_execute_ready,
	output bru_execute_vaild,
	output [ :0] bru_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);

	//bru must be ready
	assign bru_execute_ready = 1'b1;




	wire bru_issue_push;
	wire bru_issue_pop;

	wire bru_fifo_full;
	wire bru_fifo_empty;
	wire [ : 0] bru_issue_info_pop;



//对于有条件分支预测，先解决分支也没用，必须等先序指令commit，因此还不如顺序发射
//对于无条件指令，建议放到加法器中合并
issue_fifo (
	.DW(),
	.DP(BRU_ISSUE_DEPTH),
)


(
	.issue_info_push(bru_issue_info_push),
	.issue_info_pop(bru_issue_info_pop),

	.issue_push(bru_issue_push),
	.issue_pop(bru_issue_pop),
	.fifo_full(bru_fifo_full),
	.fifo_empty(bru_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
	
);

	wire rv64i_jal;
	wire rv64i_jalr;
	wire rv64i_beq;
	wire rv64i_bne;
	wire rv64i_blt;
	wire rv64i_bge;
	wire rv64i_bltu;
	wire rv64i_bgeu;

	wire bru_rs1;
	wire bru_rs2;


	wire [63 : 0] src1;
	wire [63 : 0] src2;

	wire  [63-1:0] op1;
	wire  [63-1:0] op2;


	assign {
				rv64i_beq,
				rv64i_bne,
				rv64i_blt,
				rv64i_bge,
				rv64i_bltu,
				rv64i_bgeu,

				bru_rs1,
				bru_rs2
			} = bru_issue_info_pop;


	assign rs1_ready = wbBuf_qout[bru_rs1];
	assign rs2_ready = wbBuf_qout[bru_rs2];

	assign bru_isClearRAW = ( ~bru_fifo_empty ) & 
											 rs1_ready & rs2_ready ;


	assign src1 = regFileX_read[bru_rs1_index]
	assign src2 = regFileX_read[bru_rs2_index]

	assign op1 = src1;
	assign op2 = src2;




	assign bru_execute_info = { 
								rv64i_beq,
								rv64i_bne,
								rv64i_blt,
								rv64i_bge,
								rv64i_bltu,
								rv64i_bgeu,

								op1,
								op2
								};


	assign bru_execute_vaild = ~bru_isClearRAW;


	assign bru_issue_push = ( bru_dispat_ready );
	assign bru_issue_pop = ( bru_execute_ready & bru_execute_vaild );


	assign bru_dispat_ready = bru_dispat_vaild &
								( ~bru_buffer_full | bru_buffer_full & bru_issue_pop);







endmodule







