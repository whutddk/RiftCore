/*
* @File name: dtcm
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:32:59
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-29 19:09:50
*/


module dtcm #
(
	parameter DW = 128,
	parameter AW = 14,
)
(

	input [AW-1:0] addr,
	input [DW-1:0] data_dxnt,
	input wen,
	input [(DW/8)-1:0] wmask
	output [DW-1:0] data_qout,

	input CLK,
	input RSTn

);

	reg [DW-1:0] ram[0:AW-1];

	wire [DW-1:0] write_mask;
	wire [DW-1:0] clear_mask = ~write_mask;



	generate
		for ( genvar i = 0; i < DW/8 ; i = i + 1 ) begin
			write_mask{i*8 +: 8} = {8{wmask[i]}};
		end
	endgenerate



	always @(posedge CLK) begin
		if(wen_a) begin
			ram[addr] <= (ram[0:AW-1] & clear_mask) | (data_dxnt & write_mask);
		end else begin
			data_qout <= ram[addr];
		end
	end

















endmodule

























