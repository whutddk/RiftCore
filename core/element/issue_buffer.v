/*
* @File name: issue_buffer
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 18:04:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-27 19:41:08
*/

module issue_buffer #
(
	parameter DW = 100,
	parameter DP = 8,
)


(

	input [ DW - 1 : 0] issue_info_push,
	input issue_push,
	output buffer_full,

	input issue_pop,
	input issue_pop_index,
	output [ DW*DP - 1 : 0] issue_info_qout

	input CLK,
	input RSTn
	
);






//这里不用fifo，用并行buff以保证可以乱序发射
	wire [ DW*DP - 1 : 0] issue_info_dnxt;
	wire [ DW*DP - 1 : 0] issue_info_qout;



	generate
		for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin

			assign issue_info_dnxt[DW*dp +: DW] = issue_info_push & ( dp == issue_push_index )
												? issue_info_push
												: issue_info_qout[DW*dp +: DW]

			gen_dffr #(.DW(DW)) issue_info ( .dnxt(issue_info_dnxt[DW*dp +: DW]), .qout(issue_info_qout[DW*dp +: DW]), .CLK(CLK), .RSTn(RSTn) );

		end
	endgenerate



	gen_dffr #(.DW(DP)) buffer_vaild ( .dnxt(buffer_vaild_dnxt), .qout(buffer_vaild_qout), .CLK(CLK), .RSTn(RSTn) );

	assign buffer_full = (& buffer_vaild_qout);


	assign buffer_vaild_dnxt = ( 
										{DP{(issue_pop & issue_push) | (~issue_pop & ~issue_push)}}
										& buffer_vaild_qout
									)
									| 
									( 
										{DP{(issue_push & ~issue_pop) }}
										& (buffer_vaild_qout | (1'b1 << alu_issue_push_index_pre))
									) 
									| 
									( 
										{DP{(~issue_push & issue_pop)}}
										& (buffer_vaild_qout & ~(1'b1 << issue_pop_index))
									)

	wire [$clog2(ALU_ISSUE_DEPTH)-1:0] issue_push_index_pre;
	wire [$clog2(ALU_ISSUE_DEPTH)-1:0] issue_push_index = (issue_pop & issue_push) ? issue_pop_index : issue_push_index_pre


	lzc #(
		.WIDTH(ALU_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(ALU_ISSUE_DEPTH))
	) empty_buffer(
		.in_i(buffer_vaild_qout),
		.cnt_o(issue_push_index_pre),
		.empty_o()
	);




















endmodule








