/*
* @File name: memory_bus
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-04 17:31:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-04 18:04:19
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



module memory_bus (

  input mem_mstReq_valid,
  input [63:0] mem_addr,
  input [63:0] mem_data_w,
  output [63:0] mem_data_r,
  input [7:0] mem_wstrb,
  input mem_wen,
  output mem_slvRsp_valid,
  input mem_mstRsp_ready,


);





gen_sram #
(
  .DW(),
  .AW = 14
)i_sram_odd
(

  input [DW-1:0] data_w,
  output [DW-1:0] data_r,
  input [(DW+7)/8-1:0] data_wstrb,

  input wen,


  input [AW-1:0] addr,



  input CLK,
  input RSTn
  
);

gen_sram #
(
  .DW(),
  .AW = 14
) i_sram_eve
(

  input [DW-1:0] data_w,
  output [DW-1:0] data_r,
  input [(DW+7)/8-1:0] data_wstrb,

  input wen,


  input [AW-1:0] addr,



  input CLK,
  input RSTn
  
);


endmodule










