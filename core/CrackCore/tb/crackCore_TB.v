/*
* @File name: crackCore_TB
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-05 17:03:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 17:09:19
*/

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

	#400
			$display("Time Out !!!");
	 $finish;
end


initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end


initial
begin
	$dumpfile("./build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, crackCore_TB);//tb模块名称
end

endmodule


