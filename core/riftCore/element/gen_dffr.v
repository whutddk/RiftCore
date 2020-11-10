/*
* @File name: gen_dffr
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-14 10:25:09
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-09 16:53:28
*/

`timescale 1 ns / 1 ps

module gen_dffr # (
	parameter DW = 32,
	parameter rstValue = {DW{1'b0}}
)
(

	input [DW-1:0] dnxt,
	output [DW-1:0] qout,

	input CLK,
	input RSTn
);

reg [DW-1:0] qout_r;

always @(posedge CLK or negedge RSTn) begin
	if ( !RSTn )
		qout_r <= rstValue;
	else                  
		qout_r <= #1 dnxt;
end

assign qout = qout_r;

endmodule












