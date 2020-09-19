/*
* @File name: element
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-14 10:25:09
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-09-19 15:11:09
*/



module gen_dffr # (
  parameter DW = 32
) (

	input      [DW-1:0] dnxt,
	output     [DW-1:0] qout,

	input               CLK,
	input               RSTn
);

reg [DW-1:0] qout_r;

always @(posedge CLK or negedge RSTn)
begin : DFFR_PROC
	if ( !RSTn )
		qout_r <= {DW{1'b0}};
	else                  
		qout_r <= #1 dnxt;
end

assign qout = qout_r;

endmodule



// module gen_fifo # (
// 	parameter DP   = 8,// FIFO depth
// 	parameter DW   = 32// FIFO width
// ) (

// 	input           vaild_a, 
// 	output          ready_a, 
// 	input  [DW-1:0] data_a,

// 	output          vaild_b, 
// 	input           ready_b, 
// 	output [DW-1:0] data_b,

// 	input           CLK,
// 	input           RSTn
// );

// genvar i;
// generate

// 	// FIFO registers
// 	wire [DW-1:0] fifo_rf_r [DP-1:0];
// 	wire [DP-1:0] fifo_rf_en;

// 	// read/write enable
// 	wire wen = vaild_a & ready_a;
// 	wire ren = vaild_b & ready_b;
	
// 	////////////////
// 	///////// Read-Pointer and Write-Pointer
// 	wire [DP-1:0] rptr_vec_nxt; 
// 	wire [DP-1:0] rptr_vec_r;
// 	wire [DP-1:0] wptr_vec_nxt; 
// 	wire [DP-1:0] wptr_vec_r;



// 	assign rptr_vec_nxt = 
// 		rptr_vec_r[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
// 			(rptr_vec_r << 1);


// 	assign wptr_vec_nxt =
// 		wptr_vec_r[DP-1] ? {{DP-1{1'b0}}, 1'b1} :
// 						(wptr_vec_r << 1);


// 	sirv_gnrl_dfflrs #(1)    rptr_vec_0_dfflrs  (ren, rptr_vec_nxt[0]     , rptr_vec_r[0]     , clk, rst_n);
// 	sirv_gnrl_dfflrs #(1)    wptr_vec_0_dfflrs  (wen, wptr_vec_nxt[0]     , wptr_vec_r[0]     , clk, rst_n);


// 	sirv_gnrl_dfflr  #(DP-1) rptr_vec_31_dfflr  (ren, rptr_vec_nxt[DP-1:1], rptr_vec_r[DP-1:1], clk, rst_n);
// 	sirv_gnrl_dfflr  #(DP-1) wptr_vec_31_dfflr  (wen, wptr_vec_nxt[DP-1:1], wptr_vec_r[DP-1:1], clk, rst_n);


// 	////////////////
// 	///////// Vec register to easy full and empty and the o_vld generation with flop-clean
// 	wire [DP:0] i_vec;
// 	wire [DP:0] o_vec;
// 	wire [DP:0] vec_nxt; 
// 	wire [DP:0] vec_r;

// 	wire vec_en = (ren ^ wen );
// 	assign vec_nxt = wen ? {vec_r[DP-1:0], 1'b1} : (vec_r >> 1);  
	
// 	sirv_gnrl_dfflrs #(1)  vec_0_dfflrs     (vec_en, vec_nxt[0]     , vec_r[0]     ,     clk, rst_n);
// 	sirv_gnrl_dfflr  #(DP) vec_31_dfflr     (vec_en, vec_nxt[DP:1], vec_r[DP:1],     clk, rst_n);
	
// 	assign i_vec = {1'b0,vec_r[DP:1]};
// 	assign o_vec = {1'b0,vec_r[DP:1]};


// 	assign i_rdy = (~i_vec[DP-1]);



// 	///////// write fifo
// 	for (i=0; i<DP; i=i+1) begin:fifo_rf//{
// 	  assign fifo_rf_en[i] = wen & wptr_vec_r[i];
// 	  // Write the FIFO registers
// 	  sirv_gnrl_dffl  #(DW) fifo_rf_dffl (fifo_rf_en[i], i_dat, fifo_rf_r[i], clk);


// 	/////////One-Hot Mux as the read path
// 	integer j;
// 	reg [DW-1:0] mux_rdat;
// 	always @*
// 	begin : rd_port_PROC//{
// 	  mux_rdat = {DW{1'b0}};
// 	  for(j=0; j<DP; j=j+1) begin
// 		mux_rdat = mux_rdat | ({DW{rptr_vec_r[j]}} & fifo_rf_r[j]);
// 	  end
// 	end//}
	

// 	assign o_dat = mux_rdat;

	
// 	// o_vld as flop-clean
// 	assign o_vld = (o_vec[0]);
	
//   end
// endgenerate

// endmodule 




