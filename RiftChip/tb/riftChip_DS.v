/*
* @File name: riftChip_DS
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-05 17:03:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-02 15:29:07
*/

/*
  Copyright (c) 2020 - 2021 Ruige Lee <wut.ruigeli@gmail.com>

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

	reg isExternInterrupt;
	reg isRTimerInterrupt;
	reg isSoftwvInterrupt;

	reg CLK;
	reg RSTn;



riftCore s_RC(
	
	.isExternInterrupt(isExternInterrupt),
	.isRTimerInterrupt(isRTimerInterrupt),
	.isSoftwvInterrupt(isSoftwvInterrupt),

	.CLK(CLK),
	.RSTn(RSTn)
	
);



initial begin


	CLK = 0;
	RSTn = 0;

	isExternInterrupt = 0;
	isRTimerInterrupt = 0;
	isSoftwvInterrupt = 0;

	#20

	RSTn <= 1;

	#8000000
			$display("Time Out !!!");
	 $finish;
end


initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end


`define ITCM s_RC.i_frontEnd.i_inner_itcm
`define DTCMA s_RC.i_backEnd.i_lsu.i_dtcm_A
`define DTCMB s_RC.i_backEnd.i_lsu.i_dtcm_B
`define RGF   s_RC.i_backEnd.i_phyRegister.regFileX_qout
`define INDEX s_RC.i_backEnd.i_phyRegister.archi_X_qout[`RB*3 +: `RB]




	localparam DP = 2**16;
	localparam  ITCM_DP = 2**12;
	integer i;

		reg [7:0] mem [0:50000];
		initial begin
			$readmemh("./dhrystone/dhrystone.riscv.verilog", mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
				if ( | (mem[i*8+0] | mem[i*8+1] | mem[i*8+2] | mem[i*8+3]
						| mem[i*8+4] | mem[i*8+5] | mem[i*8+6] | mem[i*8+7]) == 1'b1 ) begin
					`ITCM.ramEve[i][7:0] = mem[i*8+0];
					`ITCM.ramEve[i][15:8] = mem[i*8+1];
					`ITCM.ramEve[i][23:16] = mem[i*8+2];
					`ITCM.ramEve[i][31:24] = mem[i*8+3];	

					`ITCM.ramOdd[i][7:0] = mem[i*8+4];
					`ITCM.ramOdd[i][15:8] = mem[i*8+5];
					`ITCM.ramOdd[i][23:16] = mem[i*8+6];
					`ITCM.ramOdd[i][31:24] = mem[i*8+7];			
				end
				else begin
					`ITCM.ramOdd[i][7:0] = 8'h0;
					`ITCM.ramOdd[i][15:8] = 8'h0;
					`ITCM.ramOdd[i][23:16] = 8'h0;
					`ITCM.ramOdd[i][31:24] = 8'h0;		

					`ITCM.ramEve[i][7:0] = 8'b0;
					`ITCM.ramEve[i][15:8] = 8'b0;
					`ITCM.ramEve[i][23:16] = 8'b0;
					`ITCM.ramEve[i][31:24] = 8'b0;					
				end


				// $display("ITCM %h: %h,%h", i*4,`ITCM.ramOdd[i],`ITCM.ramEve[i]);
			end

			for ( i = 0; i < 1000000; i = i + 1 ) begin
				// `DTCMA.ram[i] = 64'b0;
				// `DTCMB.ram[i] = 64'b0;
				if ( |{ mem[i*16+15], mem[i*16+14], mem[i*16+13], mem[i*16+12],
						mem[i*16+11], mem[i*16+10], mem[i*16+9],  mem[i*16+8],
						mem[i*16+7],  mem[i*16+6],  mem[i*16+5],  mem[i*16+4],
						mem[i*16+3],  mem[i*16+2],  mem[i*16+1],  mem[i*16+0]} == 1'b1 ) begin
					`DTCMA.ram[i][7:0] = mem[i*16+0];
					`DTCMA.ram[i][15:8] = mem[i*16+1];
					`DTCMA.ram[i][23:16] = mem[i*16+2];
					`DTCMA.ram[i][31:24] = mem[i*16+3];
					`DTCMA.ram[i][39:32] = mem[i*16+4];
					`DTCMA.ram[i][47:40] = mem[i*16+5];
					`DTCMA.ram[i][55:48] = mem[i*16+6];
					`DTCMA.ram[i][63:56] = mem[i*16+7];

					`DTCMB.ram[i][7:0] = mem[i*16+8];
					`DTCMB.ram[i][15:8] = mem[i*16+9];
					`DTCMB.ram[i][23:16] = mem[i*16+10];
					`DTCMB.ram[i][31:24] = mem[i*16+11];
					`DTCMB.ram[i][39:32] = mem[i*16+12];
					`DTCMB.ram[i][47:40] = mem[i*16+13];
					`DTCMB.ram[i][55:48] = mem[i*16+14];
					`DTCMB.ram[i][63:56] = mem[i*16+15];
 
				end
				else begin
					`DTCMA.ram[i][7:0] =   8'h0;
					`DTCMA.ram[i][15:8] =  8'h0;
					`DTCMA.ram[i][23:16] = 8'h0;
					`DTCMA.ram[i][31:24] = 8'h0;
					`DTCMA.ram[i][39:32] = 8'h0;
					`DTCMA.ram[i][47:40] = 8'h0;
					`DTCMA.ram[i][55:48] = 8'h0;
					`DTCMA.ram[i][63:56] = 8'h0;
					`DTCMB.ram[i][7:0] =   8'h0;
					`DTCMB.ram[i][15:8] =  8'h0;
					`DTCMB.ram[i][23:16] = 8'h0;
					`DTCMB.ram[i][31:24] = 8'h0;
					`DTCMB.ram[i][39:32] = 8'h0;
					`DTCMB.ram[i][47:40] = 8'h0;
					`DTCMB.ram[i][55:48] = 8'h0;
					`DTCMB.ram[i][63:56] = 8'h0;
				end

				// $display("DTCMA %h: %h", i,`DTCMA.ram[i]);
				// $display("DTCMB %h: %h", i,`DTCMB.ram[i]);

			end
		end 


`define UART_TX `DTCMA.ram[1280][7:0]
`define TIMER   `DTCMA.ram[1536][7:0]
`define COTRL   `DTCMA.ram[1792][7:0]

reg [63:0] cycle_cnt;
always @(negedge CLK or negedge RSTn) begin
	if (~RSTn) begin
		cycle_cnt <= 0;
	end
	else begin
		if (`TIMER == 8'h1 ) begin
			cycle_cnt <= cycle_cnt + 1;
		end
		else begin
			cycle_cnt <= cycle_cnt;
		end
	end


end







always @(negedge CLK) begin
	if (`UART_TX != 8'b0) begin
		$write("%c",`UART_TX);
		`UART_TX = 8'h0;
	end
end


always @(negedge CLK ) begin
	if (`COTRL == 8'd1) begin

		$display("cycle_cnt = %d", cycle_cnt);
		$display( "The DMIPS/MHz is %f", 1000000.0/(cycle_cnt/5.0)/1757.0 );
		$finish;

	end
end









initial
begin
	$dumpfile("./build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, riftCore_TB);//tb模块名称
end

endmodule


