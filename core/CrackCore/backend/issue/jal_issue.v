/*
* @File name: jal_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-03 20:01:59
*/


module jal_issue (
	
	//from buffer
	output jal_buffer_pop,
	output [$clog2(`JAL_ISSUE_DEPTH)-1:0] jal_buffer_pop_index,
	input [`JAL_ISSUE_DEPTH-1:0] jal_buffer_malloc,
	input [`JAL_ISSUE_INFO_DW*`JAL_ISSUE_DEPTH-1 : 0] jal_issue_info
	//from execute

	// input jal_execute_ready,
	output jal_execute_vaild,
	output [ :0] jal_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout
);


	//jal must be ready
	assign jal_execute_ready = 1'b1;

	wire [JAL_ISSUE_DEPTH - 1:0] rv64i_jal;
	wire [JAL_ISSUE_DEPTH - 1:0] rv64i_jalr;

	wire [64*JAL_ISSUE_DEPTH - 1:0] jal_pc;

	wire [(5+RNBIT)*JAL_ISSUE_DEPTH - 1] jal_rd0;
	wire [(5+RNBIT)*JAL_ISSUE_DEPTH - 1] jal_rs1;


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

				jal_rd0[(5+RNBIT)*i +: (5+RNBIT)], 
				jal_rs1[(5+RNBIT)*i +: (5+RNBIT)], 

				is_rvc[i]
				} = jal_issue_info[`JAL_ISSUE_INFO_DW*i +: `JAL_ISSUE_INFO_DW];

		assign rs1_ready[i] = wbBuf_qout[jal_rs1[(5+RNBIT)*i +: (5+RNBIT)]];


		assign jal_isClearRAW[i] = 	( jal_buffer_malloc[i] ) & 
										(
										  rv64i_jal[i]
										| ( rv64i_jalr[i] & rs1_ready[i] )
										);


		assign src1[64*i +: 64] = regFileX_read[jal_rs1[(5+RNBIT)*i +: (5+RNBIT)]]

	end
endgenerate


	wire jal_all_RAW;


	lzp #(
		.CW($clog2(JAL_ISSUE_DEPTH))
	) jal_RAWClear(
		.in_i(~jal_isClearRAW),
		.cnt_o(jal_buffer_pop_index),
		.empty_o(jal_all_RAW),
		.full_o(),
	);


	assign jal_execute_info = { 
									bru_jal[ jal_buffer_pop_index ],
									bru_jalr[ jal_buffer_pop_index ],
								
									jal_rd0[(5+RNBIT)*jal_buffer_pop_index +: (5+RNBIT)],
									src1[ 64*jal_buffer_pop_index +:64 ],
									pc[ 64*jal_buffer_pop_index +:64 ],

									is_rvc[ jal_buffer_pop_index ]
								};



	assign jal_execute_vaild =  ~jal_all_RAW;


	assign jal_buffer_pop = ( jal_execute_ready & jal_execute_vaild );



































endmodule
