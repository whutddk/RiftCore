/*
* @File name: riftCore_TB
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-05 17:03:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 19:56:05
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


`timescale 1 ns / 1 ps
`include "iverilog.vh"
`include "define.vh"


module riftCore_TB (

);

	reg CLK;
	reg RSTn;


riftCore s_RC(
	
	.CLK(CLK),
	.RSTn(RSTn)
	
);



initial begin
	CLK = 0;
	RSTn = 0;

	#20

	RSTn <= 1;

	#80000
			$display("Time Out !!!");
	 $finish;
end


initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end


`define ITCM s_RC.i_frontEnd.i_pcGenerate.i_itcm
	localparam  ITCM_DP = 2**10;
	integer i;

		reg [7:0] itcm_mem [0:(ITCM_DP-1)*4];
		initial begin
			$readmemh("./rv64ui-p-subw.verilog", itcm_mem);

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
	$dumpfile("../build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, riftCore_TB);//tb模块名称
end

endmodule


