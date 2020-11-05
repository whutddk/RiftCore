/*
* @File name: dtcm
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:32:59
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 16:00:06
*/

`include "define.vh"

module dtcm #
(
	parameter DW = 128,
	parameter AW = 14
)
(

	input [AW-1:0] addr,
	input [DW-1:0] data_dxnt,
	input wen,
	input [(DW/8)-1:0] wmask,
	output reg [DW-1:0] data_qout,

	input CLK,
	input RSTn

);

	reg [DW-1:0] ram[0:AW-1];

	wire [DW-1:0] write_mask;
	wire [DW-1:0] clear_mask = ~write_mask;

initial $info("奇偶存储器的实现应该放在dtcm里面");

	generate
		for ( genvar i = 0; i < DW/8 ; i = i + 1 ) begin
			assign write_mask[i*8 +: 8] = {8{wmask[i]}};
		end
	endgenerate



	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			data_qout <= {DW{1'b0}};
		end
		else begin
			if(wen) begin
				ram[addr] <= (ram[addr] & clear_mask) | (data_dxnt & write_mask);
			end else begin
				data_qout <= ram[addr];
			end
		end
	end

















endmodule

























