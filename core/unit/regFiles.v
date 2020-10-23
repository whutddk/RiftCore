/*
* @File name: regFiles
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-21 14:34:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-22 11:49:54
*/


module regFiles #
(

	input [4:0] regFileA_Index,	//第几号寄存器
	input [1:0] regFileA_Rename, //重命名指针
	input regFileA_Wen,
	input [63:0] regFileA_Write,
	output [63:0] regFileA_Read,

	input [4:0] regFileB_Index,
	input [RNBIT-1:0] regFileB_Rename,
	input regFileB_Wen,
	input [63:0] regFileB_Write,
	output [63:0] regFileB_Read,

	input [4:0] regFileC_Index,
	input [RNBIT-1:0] regFileC_Rename,
	input regFileC_Wen,
	input [63:0] regFileC_Write,
	output [63:0] regFileC_Read,

	input [4:0] regFileD_Index,
	input [RNBIT-1:0] regFileD_Rename,
	input regFileD_Wen,
	input [63:0] regFileD_Write,
	output [63:0] regFileD_Read,


	input CLK,
	input RSTn
);

	wire [32*RNDEPTH-1:0] regFile_Wen;
	wire [(64*RNDEPTH*32)-1:0] regFileX_write;
	wire [(64*RNDEPTH*32)-1:0] regFileX_read;
	assign regFileX_read[64*RNDEPTH-1:0] = 'b0;

	wire [5+RNBIT-1:0] regA_Sel = { regFileA_Index, regFileA_Rename };
	wire [5+RNBIT-1:0] regB_Sel = { regFileB_Index, regFileB_Rename };
	wire [5+RNBIT-1:0] regC_Sel = { regFileC_Index, regFileC_Rename };
	wire [5+RNBIT-1:0] regD_Sel = { regFileD_Index, regFileD_Rename };



	assign regFileA_Read = 	regFileX_read[regA_Sel*64 +: 64];
	assign regFileB_Read = 	regFileX_read[regB_Sel*64 +: 64];
	assign regFileC_Read = 	regFileX_read[regC_Sel*64 +: 64];
	assign regFileD_Read = 	regFileX_read[regD_Sel*64 +: 64];



genvar regNum;
genvar depth;
generate
	
	for ( regNum = 1; regNum < 32; regNum = regNum + 1 ) begin
		for ( depth = 0 ; depth < RNDEPTH; depth = depth + 1 ) begin

			localparam  SEL = regNum*4+depth;


			assign regFileX_write[64*SEL +: 64] = ({64{regA_Sel == SEL}} & regFileA_Wen) 
										| ({64{regB_Sel == SEL}} & regFileB_Wen)
										| ({64{regC_Sel == SEL}} & regFileC_Wen)
										| ({64{regD_Sel == SEL}} & regFileD_Wen);


			assign regFile_Wen[SEL] = ((regA_Sel == SEL) & regFileA_Write) 
									| ((regB_Sel == SEL) & regFileB_Write)
									| ((regC_Sel == SEL) & regFileC_Write)
									| ((regD_Sel == SEL) & regFileD_Write);


			gen_dffr  #(.DW(64)) int_regX ( .dnxt(regFileX_write[64*SEL +: 64]), .qout(regFileX_read[64*SEL +: 64]), .CLK(CLK), .RSTn(RSTn) );

		end
	end



endgenerate









endmodule







