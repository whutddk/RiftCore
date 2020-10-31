/*
* @File name: gen_fifo
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-30 17:55:22
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-30 21:57:34
*/




module gen_fifo # (
	parameter DW = 64,
	parameter AW = 3
) (

	input fifo_pop, 
	input fifo_push,
	input [DW-1:0] data_push,

	output fifo_empty, 
	output fifo_full, 
	output [DW-1:0] data_pop,

	input CLK,
	input RSTn
);

	localparam DP = 2**AW;


	wire [AW+1-1:0] read_addr_dnxt, read_addr_qout;
	wire [AW+1-1:0] write_addr_dnxt, write_addr_qout;
	WIRE [DP*DW-1:0] fifo_data_dnxt,fifo_data_qout;

	gen_dffr # read_addr  (.DW(AW+1)) (.dnxt(read_addr_dnxt), .qout(read_addr_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # write_addr (.DW(AW+1)) (.dnxt(write_addr_dnxt), .qout(write_addr_qout), .CLK(CLK), .RSTn(RSTn));

	assign fifo_empty = (read_addr_qout == write_addr_qout);
	assign fifo_full = (read_addr_qout[AW-1:0] == write_addr_qout[AW-1:0]) & (read_addr_qout[AW] != write_addr_qout[AW]);


generate
	for ( genvar i = 0; i < DP; i = i + 1 ) begin
		assign fifo_data_dnxt[DW*i+:DW] = (fifo_push & ~fifo_full & (write_addr_qout[AW-1:0] == i) ) ? data_push : fifo_data_qout[DW*i+:DW];


		gen_dffr # fifo_data (.DW(DW)) (.dnxt(fifo_data_dnxt[DW*i+:DW]), .qout(fifo_data_qout[DW*i+:DW]), .CLK(CLK), .RSTn(RSTn));

	end




endgenerate




	assign data_pop = fifo_data_qout[DW*read_addr+:DW];

	assign read_addr_dnxt = (fifo_pop & ~fifo_empty) ? read_addr_qout + 'd1 : read_addr_qout;
	assign write_addr_dnxt = ( fifo_push & ~fifo_full ) ? write_addr_qout + 'd1 :  write_addr_qout;


endmodule 



