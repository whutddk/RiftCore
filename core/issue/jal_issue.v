/*
* @File name: jal_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-28 17:35:10
*/


//接收从dispatch来的指令压入各自的fifo
//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理
//直接在这里设计scoreboard


module jal_issue (
	
	//from dispatch
	input  jal_dispat_vaild,
	output jal_dispat_ready,
	input [:] jal_issue_info_push,




	//from execute

	// input jal_execute_ready,
	output jal_execute_vaild,
	output [ :0] jal_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,

);


	//jal must be ready
	assign jal_execute_ready = 1'b1;



	wire jal_issue_push;
	wire jal_issue_pop;
	wire [$clog2(JAR_ISSUE_DEPTH)-1:0] jal_issue_pop_index;
	wire jal_buffer_full;
	wire [JAR_ISSUE_DEPTH-1:0] jal_buffer_vaild_qout;
	wire [ : 0] jal_issue_info_qout;

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








	//check RAW here
	wire [ DP - 1 : 0 ] jal_isRAW;







	wire [JAL_ISSUE_DEPTH - 1:0] rv64i_jal;
	wire [JAL_ISSUE_DEPTH - 1:0] rv64i_jalr;


	wire [64*JAL_ISSUE_DEPTH - 1:0] jal_pc;


	wire [(5+RNBIT)*JAL_ISSUE_DEPTH - 1] jal_rd0_index;
	wire [(5+RNBIT)*JAL_ISSUE_DEPTH - 1] jal_rs1_index;


	wire [JAL_ISSUE_DEPTH - 1] rs1_ready;


	wire [64*JAL_ISSUE_DEPTH-1 : 0] src1;


	wire  [64*JAL_ISSUE_DEPTH-1:0] op1;
	wire  [64*JAL_ISSUE_DEPTH-1:0] op2;

	wire [JAL_ISSUE_DEPTH-1:0] is_rvc;


generate
	for ( genvar i = 0; i < JAL_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_jal[i],
				rv64i_jalr[i],

				jal_pc[64*i +: 64],

				jal_rd0_index[(5+RNBIT)*i +: (5+RNBIT)], 
				jal_rs1_index[(5+RNBIT)*i +: (5+RNBIT)], 

				is_rvc[i]
				} = jal_issue_info_qout;

		assign rs1_ready[i] = writeBackBuffer_qout[jal_rs1[(5+RNBIT)*i +: (5+RNBIT)]];


		assign jal_isClearRAW[i] = 	( jal_buffer_vaild_qout[i] ) & 
										(
										  rv64i_jal[i]
										| ( rv64i_jalr[i] & rs1_ready[i] )
										);


		assign src1[64*i +: 64] = regFileX_read[jal_rs1_index[(5+RNBIT)*i +: (5+RNBIT)]]



	end
endgenerate


	wire jal_all_RAW;

	//应该为组合逻辑实现
	lzc #(
		.WIDTH(JAL_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(JAL_ISSUE_DEPTH))
	) jal_RAWClear(
		.in_i(jal_isClearRAW),
		.cnt_o(jal_issue_pop_index),
		.empty_o(jal_all_RAW)
	);


	assign jal_execute_info = { 
									bru_jal[ jal_issue_pop_index ],
									bru_jalr[ jal_issue_pop_index ],
								
									jal_rd0_index[(5+RNBIT)*jal_issue_pop_index +: (5+RNBIT)],
									src1[ 64*jal_issue_pop_index +:64 ],
									pc[ 64*jal_issue_pop_index +:64 ],

									is_rvc[ jal_issue_pop_index ]
								};



	assign jal_execute_vaild =  ~jal_all_RAW;



	assign jal_issue_push = ( jal_dispat_ready );
	assign jal_issue_pop = ( jal_execute_ready & jal_execute_vaild );

	// 现有vaild，表示信号准备好了，再有ready取信号。
	// ready需要取信号，必须有空间，即nofull或者full，但是同时pop了
	assign jal_dispat_ready = jal_dispat_vaild &
								( ~jal_buffer_full | jal_buffer_full & jal_issue_pop);
												




































endmodule
