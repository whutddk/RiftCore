/*
* @File name: shift_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-03 17:42:54
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module shift_issue (
	
	//from dispatch
	input  shift_dispat_vaild,
	output shift_dispat_ready,
	input [:] shift__issue_info_push,




	//from execute

	// input shift__execute_ready,
	output shift_execute_vaild,
	output [ :0] shift_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);


	//shift must be ready
	assign shift_execute_ready = 1'b1;



	wire shift_issue_push;
	wire shift_issue_pop;
	wire [$clog2(SHIFT_ISSUE_DEPTH)-1:0] shift_issue_pop_index;
	wire shift_buffer_full;
	wire [SHIFT_ISSUE_DEPTH-1:0] shift_buffer_vaild_qout;
	wire [ : 0] shift_issue_info_qout;









	//check RAW here
	wire [ DP - 1 : 0 ] shift_isRAW;









	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_slli;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_slliw;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_srli;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_srliw;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_srai;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_sraiw;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_sll;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_sllw;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_srl;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_srlw;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_sra;
	wire [SHIFT_ISSUE_DEPTH - 1:0] rv64i_sraw;


	wire [64*SHIFT_ISSUE_DEPTH - 1:0] shift_pc;
	wire [64*SHIFT_ISSUE_DEPTH - 1:0] shift_imm;
	wire [5*SHIFT_ISSUE_DEPTH - 1:0] shift_shamt;
	wire [(5+RNBIT)*SHIFT_ISSUE_DEPTH - 1] shift_rd0_index;
	wire [(5+RNBIT)*SHIFT_ISSUE_DEPTH - 1] shift_rs1_index;
	wire [(5+RNBIT)*SHIFT_ISSUE_DEPTH - 1] shift_rs2_index;

	wire [SHIFT_ISSUE_DEPTH - 1] rs1_ready;
	wire [SHIFT_ISSUE_DEPTH - 1] rs2_ready;



	wire [SHIFT_ISSUE_DEPTH - 1] shift_fun_sll;
	wire [SHIFT_ISSUE_DEPTH - 1] shift_fun_srl;
	wire [SHIFT_ISSUE_DEPTH - 1] shift_fun_sra;


	wire [64*SHIFT_ISSUE_DEPTH-1 : 0] src1;
	wire [64*SHIFT_ISSUE_DEPTH-1 : 0] src2;



	wire  [64*SHIFT_ISSUE_DEPTH-1:0] op1,
	wire  [64*SHIFT_ISSUE_DEPTH-1:0] op2,

	wire [SHIFT_ISSUE_DEPTH-1:0] is32;

generate
	for ( genvar i = 0; i < SHIFT_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_slli[i], rv64i_slliw[i], rv64i_sll[i], rv64i_sllw[i],
				rv64i_srli[i], rv64i_srliw[i], rv64i_srl[i], rv64i_srlw[i],
				rv64i_srai[i], rv64i_sraiw[i], rv64i_sra[i], rv64i_sraw[i], 
				
				shift_pc[64*i +: 64], shift_imm[64*i +: 64], shift_shamt[5*i +: 5], 
				shift_rd0_index[(5+RNBIT)*i +: (5+RNBIT)], 
				shift_rs1_index[(5+RNBIT)*i +: (5+RNBIT)], 
				shift_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]
				} = shift_issue_info_qout;

		assign rs1_ready[i] = writeBackBuffer_qout[shift_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = writeBackBuffer_qout[shift_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

		assign shift_isClearRAW[i] = 	( shift_buffer_vaild_qout[i] ) & 
										(
										  ( rv64i_slli[i] & rs1_ready[i] )
										| ( rv64i_slliw[i] & rs1_ready[i] )
										| ( rv64i_sll[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_sllw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_srli[i] & rs1_ready[i] )
										| ( rv64i_srliw[i] & rs1_ready[i] )
										| ( rv64i_srl[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_srlw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_srai[i] & rs1_ready[i] )
										| ( rv64i_sraiw[i] & rs1_ready[i] )
										| ( rv64i_sra[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_sraw[i] & rs1_ready[i] & rs2_ready[i] )

										
									);

		assign shift_fun_sll[i] = rv64i_slli[i] | rv64i_slliw[i] | rv64i_sll[i] | rv64i_sllw[i];
		assign shift_fun_srl[i] = rv64i_srli[i] | rv64i_srliw[i] | rv64i_srl[i] | rv64i_srlw[i];
		assign shift_fun_sra[i] = rv64i_srai[i] | rv64i_sraiw[i] | rv64i_sra[i] | rv64i_sraw[i];


		assign src1[64*i +: 64] = regFileX_read[shift_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[shift_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]]

		assign op1[64*i +:64] = ( {64{rv64i_slli[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_slliw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sll[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sllw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_srli[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srliw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srl[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_srlw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_srai[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sraiw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sra[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sraw[i]}} & src1[64*i +: 64] );

		assign op2[64*i +:64] = ( {64{rv64i_slli[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_slliw[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_sll[i]}} & { 59'b0, shift_shamt[5*i +: 5]} )
								| ( {64{rv64i_sllw[i]}} & { 59'b0, shift_shamt[5*i +: 5]} )

								| ( {64{rv64i_srli[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_srliw[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_srl[i]}} & { 59'b0, shift_shamt[5*i +: 5]} )
								| ( {64{rv64i_srlw[i]}} & { 59'b0, shift_shamt[5*i +: 5]} )

								| ( {64{rv64i_srai[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_sraiw[i]}} & shift_imm[64*i +: 64] )
								| ( {64{rv64i_sra[i]}} & { 59'b0, shift_shamt[5*i +: 5]} )
								| ( {64{rv64i_sraw[i]}} & { 59'b0, shift_shamt[5*i +: 5]} );


		assign is32[i] = rv64i_slliw[i]
								| rv64i_sllw[i]
								| rv64i_srliw[i]
								| rv64i_srlw[i]
								| rv64i_sraiw[i]
								| rv64i_sraw[i];



	end
endgenerate


	wire shift_all_RAW;

	//应该为组合逻辑实现
	lzc #(
		.WIDTH(shift_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(shift_ISSUE_DEPTH))
	) shift_RAWClear(
		.in_i(shift_isClearRAW),
		.cnt_o(shift_issue_pop_index),
		.empty_o(shift_all_RAW)
	);


	assign shift_execute_info = { 
								shift_fun_sll[ shift_issue_pop_index ],
								shift_fun_srl[ shift_issue_pop_index ],
								shift_fun_sra[ shift_issue_pop_index ],

								shift_rd0_index[(5+RNBIT)*shift_issue_pop_index +: (5+RNBIT)],
								op1[ 64*shift_issue_pop_index +:64 ],
								op2[ 64*shift_issue_pop_index +:64 ],
								is32[ shift_issue_pop_index ]

								};


	assign shift_execute_vaild =  ~shift_all_RAW;



	assign shift_issue_push = ( shift_dispat_ready );
	assign shift_issue_pop = ( shift_execute_ready & shift_execute_vaild );

	// 现有vaild，表示信号准备好了，再有ready取信号。
	// ready需要取信号，必须有空间，即nofull或者full，但是同时pop了
	assign shift_dispat_ready = shift_dispat_vaild &
								( ~shift_buffer_full | shift_buffer_full & shift_issue_pop);
												




































endmodule
