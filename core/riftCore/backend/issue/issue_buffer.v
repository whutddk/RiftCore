/*
* @File name: issue_buffer
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 18:04:15
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-09 09:42:49
*/

`timescale 1 ns / 1 ps

module issue_buffer #
(
	parameter DW = 100,
	parameter DP = 8
)


(

	input [ DW - 1 : 0] dispat_info,
	input buffer_push,
	output buffer_full,


	input buffer_pop,
	input [$clog2(DP)-1:0] pop_index,
	output [ DW*DP - 1 : 0] issue_info_qout,
	output [DP - 1 : 0] buffer_malloc_qout,
	
	input CLK,
	input RSTn
	
);






//这里不用fifo，用并行buff以保证可以乱序发射
	wire [ DW*DP - 1 : 0] issue_info_dnxt;
	wire [$clog2(DP)-1:0] issue_push_index_pre;
	wire [$clog2(DP)-1:0] issue_push_index = (buffer_pop & buffer_push) ? pop_index : issue_push_index_pre;
	wire [DP-1:0] buffer_vaild_dnxt;
	wire [DP-1:0] buffer_vaild_qout;
	assign buffer_malloc_qout = buffer_vaild_qout;

	generate
		for ( genvar dp = 0; dp < DP; dp = dp + 1 ) begin

			assign issue_info_dnxt[DW*dp +: DW] = buffer_push & ( dp == issue_push_index )
												? dispat_info
												: issue_info_qout[DW*dp +: DW];

			gen_dffr #(.DW(DW)) issue_info ( .dnxt(issue_info_dnxt[DW*dp +: DW]), .qout(issue_info_qout[DW*dp +: DW]), .CLK(CLK), .RSTn(RSTn) );

		end
	endgenerate




	gen_dffr #(.DW(DP)) buffer_vaild ( .dnxt(buffer_vaild_dnxt), .qout(buffer_vaild_qout), .CLK(CLK), .RSTn(RSTn) );

	assign buffer_vaild_dnxt = ( 
										{DP{(buffer_pop & buffer_push) | (~buffer_pop & ~buffer_push)}}
										& buffer_vaild_qout
									)
									| 
									( 
										{DP{(buffer_push & ~buffer_pop) }}
										& (buffer_vaild_qout | (1'b1 << issue_push_index_pre))
									) 
									| 
									( 
										{DP{(~buffer_push & buffer_pop)}}
										& (buffer_vaild_qout & ~(1'b1 << pop_index))
									);

	

	lzp #(
		.CW($clog2(DP))
	) empty_buffer(
		.in_i(buffer_vaild_qout),
		.pos_o(issue_push_index_pre),
		.all0(),
		.all1(buffer_full)
	);














endmodule








