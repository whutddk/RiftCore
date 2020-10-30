/*
* @File name: adder_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-30 18:03:00
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module adder_issue (
	
	//from dispatch
	input  adder_dispat_vaild,
	output adder_dispat_ready,
	input [:] adder_issue_info_push,




	//from execute

	// input adder_execute_ready,
	output adder_execute_vaild,
	output [ :0] adder_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);


	//adder must be ready
	assign adder_execute_ready = 1'b1;



	wire adder_issue_push;
	wire adder_issue_pop;
	wire [$clog2(ADDER_ISSUE_DEPTH)-1:0] adder_issue_pop_index;
	wire adder_buffer_full;
	wire [ADDER_ISSUE_DEPTH-1:0] adder_buffer_vaild_qout;
	wire [ : 0] adder_issue_info_qout;










	//check RAW here
	wire [ DP - 1 : 0 ] adder_isRAW;







	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_lui;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_auipc;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addi;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addiw;

	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_add;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addw;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_sub;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_subw;


	wire [64*ADDER_ISSUE_DEPTH - 1:0] adder_pc;
	wire [64*ADDER_ISSUE_DEPTH - 1:0] adder_imm;

	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rd0_index;
	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rs1_index;
	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rs2_index;

	wire [ADDER_ISSUE_DEPTH - 1:0] rs1_ready;
	wire [ADDER_ISSUE_DEPTH - 1:0] rs2_ready;

	wire [ADDER_ISSUE_DEPTH - 1:0] adder_fun_add;
	wire [ADDER_ISSUE_DEPTH - 1:0] adder_fun_sub;

	wire [64*ADDER_ISSUE_DEPTH-1 : 0] src1;
	wire [64*ADDER_ISSUE_DEPTH-1 : 0] src2;

	wire  [64*ADDER_ISSUE_DEPTH-1:0] op1;
	wire  [64*ADDER_ISSUE_DEPTH-1:0] op2;

	wire [ADDER_ISSUE_DEPTH-1:0] is32;


generate
	for ( genvar i = 0; i < ADDER_ISSUE_DEPTH; i = i + 1 ) begin

		assign { rv64i_lui[i], rv64i_auipc[i], 
				rv64i_addi[i], rv64i_addiw[i], rv64i_add[i], rv64i_addw[i], rv64i_sub[i], rv64i_subw[i],
				
				adder_pc[64*i +: 64], adder_imm[64*i +: 64],
				adder_rd0_index[(5+RNBIT)*i +: (5+RNBIT)], 
				adder_rs1_index[(5+RNBIT)*i +: (5+RNBIT)], 
				adder_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]
				} = adder_issue_info_qout;

		assign rs1_ready[i] = wbBuf_qout[adder_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = wbBuf_qout[adder_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

		assign adder_isClearRAW[i] = 	( adder_buffer_vaild_qout[i] ) & 
										(
										  rv64i_lui[i]
										| rv64i_auipc[i]
										| ( rv64i_addi[i] & rs1_ready[i] )
										| ( rv64i_addiw[i] & rs1_ready[i] )
										| ( rv64i_add[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_addw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_sub[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_subw[i] & rs1_ready[i] & rs2_ready[i] )
									);


		assign adder_fun_add[i] = rv64i_lui[i] | rv64i_auipc[i] | rv64i_addi[i] | rv64i_addiw[i] | rv64i_add[i] | rv64i_addw[i];
		assign adder_fun_sub[i] = rv64i_sub[i] | rv64i_subw[i];

		assign src1[64*i +: 64] = regFileX_read[adder_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[adder_rs2_index[(5+RNBIT)*i +: (5+RNBIT)]]

		assign op1[64*i +:64] = ( {64{rv64i_lui[i]}} & 64'h0)
								| ( {64{rv64i_auipc[i]}} & adder_pc[64*i +: 64] )
								| ( {64{rv64i_addi[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_addiw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_add[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_addw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_sub[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_subw[i]}} & src1[64*i +: 64] )

								;

		assign op2[64*i +:64] = ( {64{rv64i_lui[i]}} & adder_imm[64*i +: 64])
								| ( {64{rv64i_auipc[i]}} & adder_imm[64*i +: 64])
								| ( {64{rv64i_addi[i]}} & adder_imm[64*i +: 64] )
								| ( {64{rv64i_addiw[i]}} & adder_imm[64*i +: 64] )
								| ( {64{rv64i_add[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_addw[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_sub[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_subw[i]}} & src2[64*i +: 64] )

								;


		assign is32[i] = 	rv64i_addiw[i]
								| rv64i_addw[i]
								| rv64i_subw[i]
								;


	end
endgenerate


	wire adder_all_RAW;

	//应该为组合逻辑实现
	lzc #(
		.WIDTH(ADDER_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(ADDER_ISSUE_DEPTH))
	) adder_RAWClear(
		.in_i(adder_isClearRAW),
		.cnt_o(adder_issue_pop_index),
		.empty_o(adder_all_RAW)
	);


	assign adder_execute_info = { 
								adder_fun_add[ adder_issue_pop_index ],
								adder_fun_sub[ adder_issue_pop_index ],

								adder_rd0_index[(5+RNBIT)*adder_issue_pop_index +: (5+RNBIT)],
								op1[ 64*adder_issue_pop_index +:64 ],
								op2[ 64*adder_issue_pop_index +:64 ],

								is32[ adder_issue_pop_index ]

								};


	assign adder_execute_vaild =  ~adder_all_RAW;



	assign adder_issue_push = ( adder_dispat_ready );
	assign adder_issue_pop = ( adder_execute_ready & adder_execute_vaild );

	// 现有vaild，表示信号准备好了，再有ready取信号。
	// ready需要取信号，必须有空间，即nofull或者full，但是同时pop了
	assign adder_dispat_ready = adder_dispat_vaild &
								( ~adder_buffer_full | adder_buffer_full & adder_issue_pop);
												




































endmodule
