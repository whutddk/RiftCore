/*
* @File name: riftChip_CI
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-05 17:03:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-15 16:00:53
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


module riftChip_CI (

);

	reg CLK;
	reg RSTn;



riftChip s_riftChip(

	.CLK(CLK),
	.RSTn(RSTn)
);


reg [255:0] testName;





initial begin
	if ( $value$plusargs("%s",testName[255:0]) ) begin
		$display("%s",testName);
	end

	CLK = 0;
	RSTn = 0;

	#20

	RSTn <= 1;

	#80000
			$display("Time Out !!!");
	$stop;
end


initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end


`define SRAM_ODD s_riftChip.i_axi_iccm.i_sram_odd
`define SRAM_EVE s_riftChip.i_axi_iccm.i_sram_eve
`define SRAM_ODD2 s_riftChip.i_axi_dccm.i_sram_odd
`define SRAM_EVE2 s_riftChip.i_axi_dccm.i_sram_eve

`define RGF   s_riftChip.i_riftCore.i_backEnd.i_phyRegister.regFileX_qout
`define INDEX s_riftChip.i_riftCore.i_backEnd.i_phyRegister.archi_X_qout[`RB*3 +: `RB]



	localparam  ITCM_DP = 2**11;
	integer i;

		reg [7:0] mem [0:50000];
		initial begin
			$readmemh(testName, mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
				if ( | (mem[i*16+0] | mem[i*16+1] | mem[i*16+2] | mem[i*16+3]
						| mem[i*16+4] | mem[i*16+5] | mem[i*16+6] | mem[i*16+7]
						| mem[i*16+8] | mem[i*16+9] | mem[i*16+10] | mem[i*16+11]
						| mem[i*16+12] | mem[i*16+13] | mem[i*16+14] | mem[i*16+15]) == 1'b1 ) begin
					`SRAM_EVE.ram[i][7:0] = mem[i*16+0];
					`SRAM_EVE.ram[i][15:8] = mem[i*16+1];
					`SRAM_EVE.ram[i][23:16] = mem[i*16+2];
					`SRAM_EVE.ram[i][31:24] = mem[i*16+3];	
					`SRAM_EVE.ram[i][32 +: 8] = mem[i*16+4];
					`SRAM_EVE.ram[i][40 +: 8] = mem[i*16+5];
					`SRAM_EVE.ram[i][48 +: 8] = mem[i*16+6];
					`SRAM_EVE.ram[i][56 +: 8] = mem[i*16+7];

					`SRAM_ODD.ram[i][7:0] = mem[i*16+8];
					`SRAM_ODD.ram[i][15:8] = mem[i*16+9];
					`SRAM_ODD.ram[i][23:16] = mem[i*16+10];
					`SRAM_ODD.ram[i][31:24] = mem[i*16+11];
					`SRAM_ODD.ram[i][32 +: 8] = mem[i*16+12];
					`SRAM_ODD.ram[i][40 +: 8] = mem[i*16+13];
					`SRAM_ODD.ram[i][48 +: 8] = mem[i*16+14];
					`SRAM_ODD.ram[i][56 +: 8] = mem[i*16+15];	


					`SRAM_EVE2.ram[i][7:0] = mem[i*16+0];
					`SRAM_EVE2.ram[i][15:8] = mem[i*16+1];
					`SRAM_EVE2.ram[i][23:16] = mem[i*16+2];
					`SRAM_EVE2.ram[i][31:24] = mem[i*16+3];	
					`SRAM_EVE2.ram[i][32 +: 8] = mem[i*16+4];
					`SRAM_EVE2.ram[i][40 +: 8] = mem[i*16+5];
					`SRAM_EVE2.ram[i][48 +: 8] = mem[i*16+6];
					`SRAM_EVE2.ram[i][56 +: 8] = mem[i*16+7];

					`SRAM_ODD2.ram[i][7:0] = mem[i*16+8];
					`SRAM_ODD2.ram[i][15:8] = mem[i*16+9];
					`SRAM_ODD2.ram[i][23:16] = mem[i*16+10];
					`SRAM_ODD2.ram[i][31:24] = mem[i*16+11];
					`SRAM_ODD2.ram[i][32 +: 8] = mem[i*16+12];
					`SRAM_ODD2.ram[i][40 +: 8] = mem[i*16+13];
					`SRAM_ODD2.ram[i][48 +: 8] = mem[i*16+14];
					`SRAM_ODD2.ram[i][56 +: 8] = mem[i*16+15];	

				end
				else begin
					`SRAM_EVE.ram[i][7:0] = 8'h0;
					`SRAM_EVE.ram[i][15:8] = 8'h0;
					`SRAM_EVE.ram[i][23:16] = 8'h0;
					`SRAM_EVE.ram[i][31:24] = 8'h0;
					`SRAM_EVE.ram[i][32 +: 8] = 8'h0;
					`SRAM_EVE.ram[i][40 +: 8] = 8'h0;
					`SRAM_EVE.ram[i][48 +: 8] = 8'h0;
					`SRAM_EVE.ram[i][56 +: 8] = 8'h0;

					`SRAM_ODD.ram[i][7:0] = 8'h0;
					`SRAM_ODD.ram[i][15:8] = 8'h0;
					`SRAM_ODD.ram[i][23:16] = 8'h0;
					`SRAM_ODD.ram[i][31:24] = 8'h0;
					`SRAM_ODD.ram[i][32 +: 8] = 8'h0;
					`SRAM_ODD.ram[i][40 +: 8] = 8'h0;
					`SRAM_ODD.ram[i][48 +: 8] = 8'h0;
					`SRAM_ODD.ram[i][56 +: 8] = 8'h0;		

					`SRAM_EVE2.ram[i][7:0] = 8'h0;
					`SRAM_EVE2.ram[i][15:8] = 8'h0;
					`SRAM_EVE2.ram[i][23:16] = 8'h0;
					`SRAM_EVE2.ram[i][31:24] = 8'h0;
					`SRAM_EVE2.ram[i][32 +: 8] = 8'h0;
					`SRAM_EVE2.ram[i][40 +: 8] = 8'h0;
					`SRAM_EVE2.ram[i][48 +: 8] = 8'h0;
					`SRAM_EVE2.ram[i][56 +: 8] = 8'h0;

					`SRAM_ODD2.ram[i][7:0] = 8'h0;
					`SRAM_ODD2.ram[i][15:8] = 8'h0;
					`SRAM_ODD2.ram[i][23:16] = 8'h0;
					`SRAM_ODD2.ram[i][31:24] = 8'h0;
					`SRAM_ODD2.ram[i][32 +: 8] = 8'h0;
					`SRAM_ODD2.ram[i][40 +: 8] = 8'h0;
					`SRAM_ODD2.ram[i][48 +: 8] = 8'h0;
					`SRAM_ODD2.ram[i][56 +: 8] = 8'h0;	

				end


				// $display("ITCM %h: %h,%h", i*4,`SRAM_ODD.ram[i],`SRAM_EVE.ram[i]);
			end

		end 


	wire [63:0] x3 = `RGF[(3*`RP+`INDEX)*64 +: 64];
	wire isEcall = s_riftChip.i_riftCore.i_backEnd.i_commit.isEcall;

always @(negedge CLK)begin 
	if (isEcall) begin
		if ( x3 == 64'd1 ) begin
			$display("PASS");
			$finish;
		end
		else begin
			$display("Fail");
			$stop;
		end



	end

end





endmodule


