/*
* @File name: phyRigister
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-23 15:42:33
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-23 16:08:59
*/



module phyRigister (












	input CLK,
	input RSTn
	
);







//指示128-32个寄存器组中哪些被用了
wire [32*RNDEPTH-1 : 0] rnBuffUsed_dnxt;
wire [32*RNDEPTH-1 : 0] rnBuffUsed_qout;

assign rnBuffUsed_dnxt[RNDEPTH-1 : 0] = 'b0;
assign rnBuffUsed_qout[RNDEPTH-1 : 0] = 'b0;

generate
	for ( genvar i = 1; i < 32; i = i + 1 ) begin

		//commit的复位，重命名的置位
		assign rnBuffUsed_dnxt[RNDEPTH*i +: RNDEPTH] = () ? 
														rnBuffUsed_qout[RNDEPTH*i +: RNDEPTH] | (1'b1 << dispatch_rd0Index) & (1'b0 << ) 
														: rnBuffUsed_qout  

		gen_dffr #(.DW(RNDEPTH)) rename_buff ( .dnxt(rnBuffUsed_dnxt[RNDEPTH*i +: RNDEPTH]), .qout(rnBuffUsed_qout[RNDEPTH*i +: RNDEPTH]), .CLK(CLK), .RSTn(RSTn) );


	end


endgenerate





//指示乱序写回是否完成,影响真数据冒险
wire [32*RNDEPTH-1 : 0] writeBack_dnxt;
wire [32*RNDEPTH-1 : 0] writeBack_qout;

assign writeBack_dnxt[RNDEPTH-1 : 0] = {RNDEPTH{1'b1}};
assign writeBack_qout[RNDEPTH-1 : 0] = {RNDEPTH{1'b1}};

generate
	for ( genvar i = 1; i < 32; i = i + 1 ) begin

		//写回时置1，commit时复位
		writeBack_dnxt[RNDEPTH*i +: RNDEPTH] = (  ) 
												? writeBack_qout[RNDEPTH*i +: RNDEPTH] | & 
												: writeBack_qout[RNDEPTH*i +: RNDEPTH];

		gen_dffr #(.DW(RNDEPTH)) writeBack ( .dnxt(writeBack_dnxt[RNDEPTH*i +: RNDEPTH]), .qout(writeBack_qout[RNDEPTH*i +: RNDEPTH]), .CLK(CLK), .RSTn(RSTn) );

	end
endgenerate










regFiles #(
	.RNDEPTH(4),
	.RNREGWIDTH(64*4),
	.RNBIT(1)
) i_regFiles
(

	.regFileA_Index,
	.regFileA_Rename,
	.regFileA_Wen,
	.regFileA_Write,
	.regFileA_Read,

	.regFileB_Index,
	.regFileB_Rename,
	.regFileB_Wen,
	.regFileB_Write,
	.regFileB_Read,

	.regFileC_Index,
	.regFileC_Rename,
	.regFileC_Wen,
	.regFileC_Write,
	.regFileC_Read,

	.regFileD_Index,
	.regFileD_Rename,
	.regFileD_Wen,
	.regFileD_Write,
	.regFileD_Read,


	.CLK,
	.RSTn
);








endmodule












