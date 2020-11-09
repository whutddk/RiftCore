/*
* @File name: crackCore_TB
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-05 17:03:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-09 19:12:49
*/
`timescale 1 ns / 1 ps
`include "iverilog.vh"
`include "define.vh"


module crackCore_TB (

);

	reg CLK;
	reg RSTn;


crackCore s_CC(
	
	.CLK(CLK),
	.RSTn(RSTn)
	
);



initial begin
	CLK = 0;
	RSTn = 0;

	#20

	RSTn <= 1;

	#4000
			$display("Time Out !!!");
	 $finish;
end


initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end


`define ITCM s_CC.i_frontEnd.i_pcGenerate.i_itcm
	localparam  ITCM_DP = 2**10;
	integer i;

		reg [7:0] itcm_mem [0:(ITCM_DP-1)*4];
		initial begin
			$readmemh("./tb/rv64ui-p-addi.test", itcm_mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
					`ITCM.ram[i][7:0] = itcm_mem[i*4+0];
					`ITCM.ram[i][15:8] = itcm_mem[i*4+1];
					`ITCM.ram[i][23:16] = itcm_mem[i*4+2];
					`ITCM.ram[i][31:24] = itcm_mem[i*4+3];

					$display("ITCM %h: %h", i*4,`ITCM.ram[i]);
			end




		end 















initial
begin
	$dumpfile("./build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, crackCore_TB);//tb模块名称
end

endmodule


