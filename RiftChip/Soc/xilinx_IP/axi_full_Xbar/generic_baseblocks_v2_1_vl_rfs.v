// -- (c) Copyright 2010 - 2011 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and 
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Description: 
//  Optimized AND with generic_baseblocks_v2_1_0_carry logic.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps


module generic_baseblocks_v2_1_0_carry_and #
  (
   parameter         C_FAMILY                         = "virtex6"
                       // FPGA Family. Current version: virtex6 or spartan6.
   )
  (
   input  wire        CIN,
   input  wire        S,
   output wire        COUT
   );
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Variables for generating parameter controlled instances.
  /////////////////////////////////////////////////////////////////////////////
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Local params
  /////////////////////////////////////////////////////////////////////////////
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Internal signals
  /////////////////////////////////////////////////////////////////////////////

  
  /////////////////////////////////////////////////////////////////////////////
  // Instantiate or use RTL code
  /////////////////////////////////////////////////////////////////////////////
  
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL
      assign COUT = CIN & S;
      
    end 
  endgenerate
  
  
endmodule








// -- (c) Copyright 2010 - 2011 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and 
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Description: 
//  Optimized COMPARATOR (against constant) with generic_baseblocks_v2_1_0_carry logic.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps


module generic_baseblocks_v2_1_0_comparator_static #
  (
   parameter         C_FAMILY                         = "virtex6", 
                       // FPGA Family. Current version: virtex6 or spartan6.
   parameter         C_VALUE                          = 4'b0,
                       // Static value to compare against.
   parameter integer C_DATA_WIDTH                     = 4
                       // Data width for comparator.
   )
  (
   input  wire                    CIN,
   input  wire [C_DATA_WIDTH-1:0] A,
   output wire                    COUT
   );
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Variables for generating parameter controlled instances.
  /////////////////////////////////////////////////////////////////////////////
  
  // Generate variable for bit vector.
  genvar bit_cnt;
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Local params
  /////////////////////////////////////////////////////////////////////////////
  
  // Bits per LUT for this architecture.
  localparam integer C_BITS_PER_LUT   = 6;
  
  // Constants for packing levels.
  localparam integer C_NUM_LUT        = ( C_DATA_WIDTH + C_BITS_PER_LUT - 1 ) / C_BITS_PER_LUT;
  
  // 
  localparam integer C_FIX_DATA_WIDTH = ( C_NUM_LUT * C_BITS_PER_LUT > C_DATA_WIDTH ) ? C_NUM_LUT * C_BITS_PER_LUT :
                                        C_DATA_WIDTH;
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Internal signals
  /////////////////////////////////////////////////////////////////////////////
  
  wire [C_FIX_DATA_WIDTH-1:0] a_local;
  wire [C_FIX_DATA_WIDTH-1:0] b_local;
  wire [C_NUM_LUT-1:0]        sel;
  wire [C_NUM_LUT:0]          carry_local;
  
  
  /////////////////////////////////////////////////////////////////////////////
  // 
  /////////////////////////////////////////////////////////////////////////////
  
  generate
    // Assign input to local vectors.
    assign carry_local[0] = CIN;
    
    // Extend input data to fit.
    if ( C_NUM_LUT * C_BITS_PER_LUT > C_DATA_WIDTH ) begin : USE_EXTENDED_DATA
      assign a_local        = {A,       {C_NUM_LUT * C_BITS_PER_LUT - C_DATA_WIDTH{1'b0}}};
      assign b_local        = {C_VALUE, {C_NUM_LUT * C_BITS_PER_LUT - C_DATA_WIDTH{1'b0}}};
    end else begin : NO_EXTENDED_DATA
      assign a_local        = A;
      assign b_local        = C_VALUE;
    end
    
    // Instantiate one generic_baseblocks_v2_1_0_carry and per level.
    for (bit_cnt = 0; bit_cnt < C_NUM_LUT ; bit_cnt = bit_cnt + 1) begin : LUT_LEVEL
      // Create the local select signal
      assign sel[bit_cnt] = ( a_local[bit_cnt*C_BITS_PER_LUT +: C_BITS_PER_LUT] == 
                              b_local[bit_cnt*C_BITS_PER_LUT +: C_BITS_PER_LUT] );
    
      // Instantiate each LUT level.
      generic_baseblocks_v2_1_0_carry_and # 
      (
       .C_FAMILY(C_FAMILY)
      ) compare_inst 
      (
       .COUT  (carry_local[bit_cnt+1]),
       .CIN   (carry_local[bit_cnt]),
       .S     (sel[bit_cnt])
      ); 
      
    end // end for bit_cnt
    
    // Assign output from local vector.
    assign COUT = carry_local[C_NUM_LUT];
    
  endgenerate
  
  
endmodule



// -- (c) Copyright 2010 - 2011 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and 
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Description: 
//  Optimized Mux using MUXF7/8.
//  Any generic_baseblocks_v2_1_0_mux ratio.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   mux_enc
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps


module generic_baseblocks_v2_1_0_mux_enc #
  (
   parameter         C_FAMILY                       = "rtl",
                       // FPGA Family. Current version: virtex6 or spartan6.
   parameter integer C_RATIO                        = 4,
                       // Mux select ratio. Can be any binary value (>= 1)
   parameter integer C_SEL_WIDTH                    = 2,
                       // Log2-ceiling of C_RATIO (>= 1)
   parameter integer C_DATA_WIDTH                   = 1
                       // Data width for generic_baseblocks_v2_1_0_comparator (>= 1)
   )
  (
   input  wire [C_SEL_WIDTH-1:0]                    S,
   input  wire [C_RATIO*C_DATA_WIDTH-1:0]           A,
   output wire [C_DATA_WIDTH-1:0]                   O,
   input  wire                                      OE
   );
  
  wire [C_DATA_WIDTH-1:0] o_i;
  genvar bit_cnt;
  
  function [C_DATA_WIDTH-1:0] f_mux
    (
     input [C_SEL_WIDTH-1:0] s,
     input [C_RATIO*C_DATA_WIDTH-1:0] a
     );
    integer i;
    reg [C_RATIO*C_DATA_WIDTH-1:0] carry;
    begin
      carry[C_DATA_WIDTH-1:0] = {C_DATA_WIDTH{(s==0)?1'b1:1'b0}} & a[C_DATA_WIDTH-1:0];
      for (i=1;i<C_RATIO;i=i+1) begin : gen_carrychain_enc
        carry[i*C_DATA_WIDTH +: C_DATA_WIDTH] = 
          carry[(i-1)*C_DATA_WIDTH +: C_DATA_WIDTH] |
          ({C_DATA_WIDTH{(s==i)?1'b1:1'b0}} & a[i*C_DATA_WIDTH +: C_DATA_WIDTH]);
      end
      f_mux = carry[C_DATA_WIDTH*C_RATIO-1:C_DATA_WIDTH*(C_RATIO-1)];
    end
  endfunction
  
  function [C_DATA_WIDTH-1:0] f_mux4
    (
     input [1:0] s,
     input [4*C_DATA_WIDTH-1:0] a
     );
    integer i;
    reg [4*C_DATA_WIDTH-1:0] carry;
    begin
      carry[C_DATA_WIDTH-1:0] = {C_DATA_WIDTH{(s==0)?1'b1:1'b0}} & a[C_DATA_WIDTH-1:0];
      for (i=1;i<4;i=i+1) begin : gen_carrychain_enc
        carry[i*C_DATA_WIDTH +: C_DATA_WIDTH] = 
          carry[(i-1)*C_DATA_WIDTH +: C_DATA_WIDTH] |
          ({C_DATA_WIDTH{(s==i)?1'b1:1'b0}} & a[i*C_DATA_WIDTH +: C_DATA_WIDTH]);
      end
      f_mux4 = carry[C_DATA_WIDTH*4-1:C_DATA_WIDTH*3];
    end
  endfunction
  
  assign O = o_i & {C_DATA_WIDTH{OE}};  // OE is gated AFTER any MUXF7/8 (can only optimize forward into downstream logic)
  
  generate
    if ( C_RATIO < 2 ) begin : gen_bypass
      assign o_i = A;
    end else if ( C_FAMILY == "rtl" || C_RATIO < 5 ) begin : gen_rtl
      assign o_i = f_mux(S, A);
      
    end 
  endgenerate
endmodule


