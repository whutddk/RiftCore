/*
* @File name: define
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-22 11:47:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 16:43:31
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


`define RP   4 //rename depth
`define RB $clog2(`RP) 



`define DECODE_INFO_DW (53+13+1+6+13+2+1+64+64+6+5+5+5) 
`define REORDER_INFO_DW (64+(5+`RB)+10)

`define ALU_ISSUE_INFO_DW (30+64+6+64+(5+`RB)+(5+`RB)+(5+`RB))
`define ALU_ISSUE_INFO_DP 2
`define ALU_EXEPARAM_DW (10+4+(5+`RB)+(5+`RB)+(5+`RB)+64+64)

`define BRU_ISSUE_INFO_DW (8+1+64+64+(5+`RB)+(5+`RB)+(5+`RB))
`define BRU_ISSUE_INFO_DP 2
`define BRU_EXEPARAM_DW (8+1+(5+`RB)+(5+`RB)+(5+`RB)+64+64)

`define LSU_ISSUE_INFO_DW (13+64+(5+`RB)+(5+`RB)+(5+`RB))
`define LSU_ISSUE_INFO_DP 2
`define LSU_EXEPARAM_DW (13+(5+`RB)+64+64)


`define CSR_ISSUE_INFO_DW (6+64+12+(5+`RB)+(5+`RB))
`define CSR_ISSUE_INFO_DP 2
`define CSR_EXEPARAM_DW (3+(5+`RB)+(5+`RB)+1+12)

`define MUL_ISSUE_INFO_DW (13+(5+`RB)+(5+`RB)+(5+`RB))
`define MUL_ISSUE_INFO_DP 2
`define MUL_EXEPARAM_DW `MUL_ISSUE_INFO_DW



