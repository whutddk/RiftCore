/*
* @File name: logCmp_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 16:58:59
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module logCmp_issue (
	
	//from dispatch
	input  logCmp_dispat_vaild,
	output logCmp_dispat_ready,
	input [:] logCmp_issue_info_push,




	//from execute

	// input logCmp_execute_ready,
	output logCmp_execute_vaild,
	output [ :0] logCmp_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);


	//logCmp must be ready
	assign logCmp_execute_ready = 1'b1;



	wire logCmp_issue_push;
	wire logCmp_issue_pop;
	wire [$clog2(LOGCMP_ISSUE_DEPTH)-1:0] logCmp_issue_pop_index;
	wire logCmp_buffer_full;
	wire [LOGCMP_ISSUE_DEPTH-1:0] logCmp_buffer_vaild_qout;
	wire [ : 0] logCmp_issue_info_qout;

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








	//check RAW here
	wire [ DP - 1 : 0 ] logCmp_isRAW;








	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slti;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltiu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_xori;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_ori;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_andi;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_xor;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_or;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_and;

	wire [64*LOGCMP_ISSUE_DEPTH - 1:0] logCmp_pc;
	wire [64*LOGCMP_ISSUE_DEPTH - 1:0] logCmp_imm;

	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rd0_index;
	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rs1_index;
	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rs2_index;

	wire [LOGCMP_ISSUE_DEPTH - 1] rs1_ready;
	wire [LOGCMP_ISSUE_DEPTH - 1] rs2_ready;

	wire [64*LOGCMP_ISSUE_DEPTH-1 : 0] src1;
	wire [64*LOGCMP_ISSUE_DEPTH-1 : 0] src2;

	wire  [64*LOGCMP_ISSUE_DEPTH-1:0] op1,
	wire  [64*LOGCMP_ISSUE_DEPTH-1:0] op2,

	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_xor;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_or;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_and;

	wire [LOGCMP_ISSUE_DEPTH - 1:0] isUsi

generate
	for ( genvar i = 0; i < LOGCMP_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_slti[i], rv64i_sltiu[i], rv64i_slt[i], rv64i_sltu[i],
				rv64i_xori[i], rv64i_ori[i], rv64i_andi[i], rv64i_xor[i], rv64i_or[i], rv64i_and[i],
				logCmp_pc[64*i +: 64], logCmp_imm[64*i +: 64],
				logCmp_rd0_index[(5+RNBIT)*i +: (5+RNBIT)], 
				logCmp_rs1_index[(5+RNBIT)*i +: (5+RNBIT)], 
				logCmp_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]
				} = logCmp_issue_info_qout;

		assign rs1_ready[i] = writeBackBuffer_qout[logCmp_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = writeBackBuffer_qout[logCmp_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

		assign logCmp_isClearRAW[i] = 	( logCmp_buffer_vaild_qout[i] ) & 
										(
											( rv64i_slti[i] & rs1_ready[i] )
											| ( rv64i_sltiu[i] & rs1_ready[i] )
											| ( rv64i_slt[i] & rs1_ready[i] & rs2_ready[i] )
											| ( rv64i_sltu[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_xori[i] & rs1_ready[i] & rs2_ready[i] )
											| ( rv64i_xor[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_ori[i] & rs1_ready[i]  )
											| ( rv64i_or[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_andi[i] & rs1_ready[i] )
											| ( rv64i_and[i] & rs1_ready[i] & rs2_ready[i] )
										);


		
		assign logCmp_fun_slt[i] = rv64i_slti[i] | rv64i_sltiu[i] | rv64i_slt[i] | rv64i_sltu[i];
		assign logCmp_fun_xor[i] = rv64i_xori[i] | rv64i_xor[i];
		assign logCmp_fun_or[i] = rv64i_ori[i] | rv64i_or[i];
		assign logCmp_fun_and[i] = rv64i_andi[i] | rv64i_and[i];

		assign src1[64*i +: 64] = regFileX_read[logCmp_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[logCmp_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]]

		assign op1[64*i +:64] = ( {64{rv64i_slti[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sltiu[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_slt[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sltu[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_xori[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_xor[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_ori[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_or[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_andi[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_and[i]}} & src1[64*i +: 64] );

		assign op2[64*i +:64] = ( {64{rv64i_slti[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_sltiu[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_slt[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_sltu[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_xori[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_xor[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_ori[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_or[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_andi[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_and[i]}} & src2[64*i +: 64] );


		assign isUsi[i] = rv64i_sltiu[i]
							| rv64i_sltu[i];


	end
endgenerate


	wire logCmp_all_RAW;

	//应该为组合逻辑实现
	lzc #(
		.WIDTH(LOGCMP_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(LOGCMP_ISSUE_DEPTH))
	) logCmp_RAWClear(
		.in_i(logCmp_isClearRAW),
		.cnt_o(logCmp_issue_pop_index),
		.empty_o(logCmp_all_RAW)
	);


	assign logCmp_execute_info = { 
									logCmp_fun_slt[ logCmp_issue_pop_index ],
									logCmp_fun_xor[ logCmp_issue_pop_index ],
									logCmp_fun_or[ logCmp_issue_index ],
									logCmp_fun_and[ logCmp_issue_index ],

									logCmp_rd0_index[(5+RNBIT)*logCmp_issue_pop_index +: (5+RNBIT)],
									op1[ 64*logCmp_issue_pop_index +:64 ],
									op2[ 64*logCmp_issue_pop_index +:64 ],

									isUsi[ logCmp_issue_pop_index ],
									};


	assign logCmp_execute_vaild =  ~logCmp_all_RAW;



	assign logCmp_issue_push = ( logCmp_dispat_ready );
	assign logCmp_issue_pop = ( logCmp_execute_ready & logCmp_execute_vaild );

	// 现有vaild，表示信号准备好了，再有ready取信号。
	// ready需要取信号，必须有空间，即nofull或者full，但是同时pop了
	assign logCmp_dispat_ready = logCmp_dispat_vaild &
								( ~logCmp_buffer_full | logCmp_buffer_full & logCmp_issue_pop);
												




































endmodule
