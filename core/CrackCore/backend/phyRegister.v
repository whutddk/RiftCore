/*
* @File name: phyRegister
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-23 15:42:33
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 18:05:34
*/



module phyRegister (

	input  [(64*RNDEPTH*32)-1:0] regFileX_dnxt,
	output [(64*RNDEPTH*32)-1:0] regFileX_qout,


	input [ RNBIT*32 - 1 :0 ] rnAct_X_dnxt,
	output [ RNBIT*32 - 1 :0 ] rnAct_X_qout,

	input [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	input [32*RNDEPTH-1 : 0] rnBufU_commit_rst,
	output [32*RNDEPTH-1 : 0] rnBufU_qout,

	input [32*RNDEPTH-1 : 0] wbLog_writeb_set,
	input [32*RNDEPTH-1 : 0] wbLog_commit_rst,
	output [32*RNDEPTH-1 : 0] wbLog_qout,

	input [ RNBIT*32 - 1 :0 ] archi_X_dnxt,
	output [ RNBIT*32 - 1 :0 ] archi_X_qout,


	input CLK,
	input RSTn
	
);
















//代表架构寄存器，指向128个寄存器中的地址，完成commit
//指向当前前端可以用的寄存器位置（只会读寄存器），读完不管,32个寄存器，每个可能深度为4
//架构寄存器在commit阶段更新，同时释放rename位置
wire  [ RNBIT*32 - 1 :0 ] archi_X_dnxt;
wire  [ RNBIT*32 - 1 :0 ] archi_X_qout;
//格式一致，排除X0

assign archi_X_qout[RNBIT-1:0] = 'd0;

generate
	for ( genvar i = 1 ; i < 32; i = i + 1 ) begin
		gen_dffr #(.DW(RNBIT)) archi_X ( .dnxt(archi_X_dnxt[RNBIT*i +: RNBIT]), .qout(archi_X_qout[RNBIT*i +: RNBIT]), .CLK(CLK), .RSTn(RSTn) );
	end
endgenerate












//读操作不会改变重命名活动指针，
//读操作需要通过重命名活动指针寻找正确的寄存器，
//写操作需要改变重命名活动指针到一个新位置，需要是空的，否则挂起流水线


generate
	for ( genvar i = 1 ; i < 32; i = i + 1 ) begin

		

		gen_dffr #(.DW(RNBIT)) rnActive_X ( .dnxt(rnAct_X_dnxt[RNBIT*i +: RNBIT]), .qout(rnAct_X_qout[RNBIT*i +: RNBIT]), .CLK(CLK), .RSTn(RSTn) );
	end
endgenerate


//指示128-32个寄存器组中哪些被用了
wire [32*RNDEPTH-1 : 0] rnBufU_dnxt;
wire [32*RNDEPTH-1 : 0] rnBufU_qout;

assign rnBufU_dnxt[RNDEPTH-1 : 0] = 'b0;
assign rnBufU_qout[RNDEPTH-1 : 0] = 'b0;

generate
	for ( genvar i = 1; i < 32; i = i + 1 ) begin

	input [32*RNDEPTH-1 : 0] rnBufU_rename_set,
	input [32*RNDEPTH-1 : 0] rnBufU_commit_rst,


	//commit的复位，重命名的置位
	assign rnBufU_dnxt[RNDEPTH*i +: RNDEPTH] = rnBufU_qout[RNDEPTH*i +: RNDEPTH] 
												| rnBufU_rename_set[RNDEPTH*i +: RNDEPTH]
												& rnBufU_commit_rst[RNDEPTH*i +: RNDEPTH];

	gen_dffr #(.DW(RNDEPTH)) rnBufU ( .dnxt(rnBufU_dnxt[RNDEPTH*i +: RNDEPTH]), .qout(rnBufU_qout[RNDEPTH*i +: RNDEPTH]), .CLK(CLK), .RSTn(RSTn) );


	end

endgenerate



//指示乱序写回是否完成,影响真数据冒险
wire [32*RNDEPTH-1 : 0] wbLog_dnxt;
wire [32*RNDEPTH-1 : 0] wbLog_qout;

assign wbLog_dnxt[RNDEPTH-1 : 0] = {RNDEPTH{1'b1}};
assign wbLog_qout[RNDEPTH-1 : 0] = {RNDEPTH{1'b1}};


	input [32*RNDEPTH-1 : 0] wbLog_writeb_set,
	input [32*RNDEPTH-1 : 0] wbLog_commit_rst,

generate
	for ( genvar i = 1; i < 32; i = i + 1 ) begin

		//写回时置1，commit时复位
		wbLog_dnxt[RNDEPTH*i +: RNDEPTH] = wbLog_qout[RNDEPTH*i +: RNDEPTH] 
											| wbLog_writeb_set[RNDEPTH*i +: RNDEPTH]
											& wbLog_commit_rst[RNDEPTH*i +: RNDEPTH];

		gen_dffr #(.DW(RNDEPTH)) wbLog ( .dnxt(wbLog_dnxt[RNDEPTH*i +: RNDEPTH]), .qout(wbLog_qout[RNDEPTH*i +: RNDEPTH]), .CLK(CLK), .RSTn(RSTn) );

	end
endgenerate










regFiles i_regFiles
(
	.regFileX_dnxt(regFileX_dnxt),
	.regFileX_qout(regFileX_qout),

	.CLK(CLK),
	.RSTn(RSTn)
);








endmodule












