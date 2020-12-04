/*
* @File name: system_crossBar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-02 09:45:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-04 19:55:31
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


module system_crossBar #
	(
		parameter ISASYN_INNER = 1,
		parameter ISASYN_DM = 1,
		parameter ISASYN_CACHE = 1,
		parameter ISASYN_ROM = 1,
		parameter ISASYN_CLINT = 1,
		parameter ISASYN_PLIC = 1,
		parameter ISASYN_SYS = 1,
		parameter ISASYN_MEM = 1,
		parameter ISASYN_PERIP = 1,
	)
	(

// IIIIIIIIII                                                                            
// I::::::::I                                                                            
// I::::::::I                                                                            
// II::::::II                                                                            
//   I::::I  nnnn  nnnnnnnn    nnnn  nnnnnnnn        eeeeeeeeeeee    rrrrr   rrrrrrrrr   
//   I::::I  n:::nn::::::::nn  n:::nn::::::::nn    ee::::::::::::ee  r::::rrr:::::::::r  
//   I::::I  n::::::::::::::nn n::::::::::::::nn  e::::::eeeee:::::eer:::::::::::::::::r 
//   I::::I  nn:::::::::::::::nnn:::::::::::::::ne::::::e     e:::::err::::::rrrrr::::::r
//   I::::I    n:::::nnnn:::::n  n:::::nnnn:::::ne:::::::eeeee::::::e r:::::r     r:::::r
//   I::::I    n::::n    n::::n  n::::n    n::::ne:::::::::::::::::e  r:::::r     rrrrrrr
//   I::::I    n::::n    n::::n  n::::n    n::::ne::::::eeeeeeeeeee   r:::::r            
//   I::::I    n::::n    n::::n  n::::n    n::::ne:::::::e            r:::::r            
// II::::::II  n::::n    n::::n  n::::n    n::::ne::::::::e           r:::::r            
// I::::::::I  n::::n    n::::n  n::::n    n::::n e::::::::eeeeeeee   r:::::r            
// I::::::::I  n::::n    n::::n  n::::n    n::::n  ee:::::::::::::e   r:::::r            
// IIIIIIIIII  nnnnnn    nnnnnn  nnnnnn    nnnnnn    eeeeeeeeeeeeee   rrrrrrr            
	input S_INNER_AXI_ACLK,
	input S_INNER_AXI_ARESETN,

	input [63:0] S_INNER_AXI_AWADDR,
	input S_INNER_AXI_AWVALID,
	output S_INNER_AXI_AWREADY,

	input [63:0] S_INNER_AXI_WDATA,
	input [7:0] S_INNER_AXI_WSTRB,
	input S_INNER_AXI_WVALID,
	output S_INNER_AXI_WREADY,

	output [1:0] S_INNER_AXI_BRESP,
	output S_INNER_AXI_BVALID,
	input S_INNER_AXI_BREADY,

	input [63:0] S_INNER_AXI_ARADDR,
	input S_INNER_AXI_ARVALID,
	output S_INNER_AXI_ARREADY,

	output [63:0] S_INNER_AXI_RDATA,
	output [1:0] S_INNER_AXI_RRESP,
	output S_INNER_AXI_RVALID,
	input S_INNER_AXI_RREADY,

// DDDDDDDDDDDDD        MMMMMMMM               MMMMMMMM
// D::::::::::::DDD     M:::::::M             M:::::::M
// D:::::::::::::::DD   M::::::::M           M::::::::M
// DDD:::::DDDDD:::::D  M:::::::::M         M:::::::::M
//   D:::::D    D:::::D M::::::::::M       M::::::::::M
//   D:::::D     D:::::DM:::::::::::M     M:::::::::::M
//   D:::::D     D:::::DM:::::::M::::M   M::::M:::::::M
//   D:::::D     D:::::DM::::::M M::::M M::::M M::::::M
//   D:::::D     D:::::DM::::::M  M::::M::::M  M::::::M
//   D:::::D     D:::::DM::::::M   M:::::::M   M::::::M
//   D:::::D     D:::::DM::::::M    M:::::M    M::::::M
//   D:::::D    D:::::D M::::::M     MMMMM     M::::::M
// DDD:::::DDDDD:::::D  M::::::M               M::::::M
// D:::::::::::::::DD   M::::::M               M::::::M
// D::::::::::::DDD     M::::::M               M::::::M
// DDDDDDDDDDDDD        MMMMMMMM               MMMMMMMM

	input [63:0] S_DM_AXI_AWADDR,
	input S_DM_AXI_AWVALID,
	output S_DM_AXI_AWREADY,

	input [63:0] S_DM_AXI_WDATA,
	input [7:0] S_DM_AXI_WSTRB,
	input S_DM_AXI_WVALID,
	output S_DM_AXI_WREADY,

	output [1:0] S_DM_AXI_BRESP,
	output S_DM_AXI_BVALID,
	input S_DM_AXI_BREADY,

	input [63:0] S_DM_AXI_ARADDR,
	input S_DM_AXI_ARVALID,
	output S_DM_AXI_ARREADY,

	output [63:0] S_DM_AXI_RDATA,
	output [1:0] S_DM_AXI_RRESP,
	output S_DM_AXI_RVALID,
	input S_DM_AXI_RREADY,


// LLLLLLLLLLL              333333333333333                            CCCCCCCCCCCCC               AAA                       CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHEEEEEEEEEEEEEEEEEEEEEE
// L:::::::::L             3:::::::::::::::33                       CCC::::::::::::C              A:::A                   CCC::::::::::::CH:::::::H     H:::::::HE::::::::::::::::::::E
// L:::::::::L             3::::::33333::::::3                    CC:::::::::::::::C             A:::::A                CC:::::::::::::::CH:::::::H     H:::::::HE::::::::::::::::::::E
// LL:::::::LL             3333333     3:::::3                   C:::::CCCCCCCC::::C            A:::::::A              C:::::CCCCCCCC::::CHH::::::H     H::::::HHEE::::::EEEEEEEEE::::E
//   L:::::L                           3:::::3                  C:::::C       CCCCCC           A:::::::::A            C:::::C       CCCCCC  H:::::H     H:::::H    E:::::E       EEEEEE
//   L:::::L                           3:::::3                 C:::::C                        A:::::A:::::A          C:::::C                H:::::H     H:::::H    E:::::E             
//   L:::::L                   33333333:::::3                  C:::::C                       A:::::A A:::::A         C:::::C                H::::::HHHHH::::::H    E::::::EEEEEEEEEE   
//   L:::::L                   3:::::::::::3   --------------- C:::::C                      A:::::A   A:::::A        C:::::C                H:::::::::::::::::H    E:::::::::::::::E   
//   L:::::L                   33333333:::::3  -:::::::::::::- C:::::C                     A:::::A     A:::::A       C:::::C                H:::::::::::::::::H    E:::::::::::::::E   
//   L:::::L                           3:::::3 --------------- C:::::C                    A:::::AAAAAAAAA:::::A      C:::::C                H::::::HHHHH::::::H    E::::::EEEEEEEEEE   
//   L:::::L                           3:::::3                 C:::::C                   A:::::::::::::::::::::A     C:::::C                H:::::H     H:::::H    E:::::E             
//   L:::::L         LLLLLL            3:::::3                  C:::::C       CCCCCC    A:::::AAAAAAAAAAAAA:::::A     C:::::C       CCCCCC  H:::::H     H:::::H    E:::::E       EEEEEE
// LL:::::::LLLLLLLLL:::::L3333333     3:::::3                   C:::::CCCCCCCC::::C   A:::::A             A:::::A     C:::::CCCCCCCC::::CHH::::::H     H::::::HHEE::::::EEEEEEEE:::::E
// L::::::::::::::::::::::L3::::::33333::::::3                    CC:::::::::::::::C  A:::::A               A:::::A     CC:::::::::::::::CH:::::::H     H:::::::HE::::::::::::::::::::E
// L::::::::::::::::::::::L3:::::::::::::::33                       CCC::::::::::::C A:::::A                 A:::::A      CCC::::::::::::CH:::::::H     H:::::::HE::::::::::::::::::::E
// LLLLLLLLLLLLLLLLLLLLLLLL 333333333333333                            CCCCCCCCCCCCCAAAAAAA                   AAAAAAA        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHEEEEEEEEEEEEEEEEEEEEEE
	
	input S_CACHE_AXI_ACLK,
	input S_CACHE_AXI_ARESETN,

	input [7:0] S_CACHE_AXI_AWID,
	input [63:0] S_CACHE_AXI_AWADDR,
	input [7:0] S_CACHE_AXI_AWLEN,
	input [2:0] S_CACHE_AXI_AWSIZE,
	input [1:0] S_CACHE_AXI_AWBURST,
	input S_CACHE_AXI_AWLOCK,
	input [3:0] S_CACHE_AXI_AWCACHE,
	input [2:0] S_CACHE_AXI_AWPROT,
	input [3:0] S_CACHE_AXI_AWQOS,
	input [3:0] S_CACHE_AXI_AWREGION,
	input [7:0] S_CACHE_AXI_AWUSER,
	input S_CACHE_AXI_AWVALID,
	output S_CACHE_AXI_AWREADY,

	input [63:0] S_CACHE_AXI_WDATA,
	input [7:0] S_CACHE_AXI_WSTRB,
	input S_CACHE_AXI_WLAST,
	input [7:0] S_CACHE_AXI_WUSER,
	input S_CACHE_AXI_WVALID,
	output S_CACHE_AXI_WREADY,

	output [7:0] S_CACHE_AXI_BID,
	output [1:0] S_CACHE_AXI_BRESP,
	output [7:0] S_CACHE_AXI_BUSER,
	output S_CACHE_AXI_BVALID,
	input S_CACHE_AXI_BREADY,

	input [7:0] S_CACHE_AXI_ARID,
	input [63:0] S_CACHE_AXI_ARADDR,
	input [7:0] S_CACHE_AXI_ARLEN,
	input [2:0] S_CACHE_AXI_ARSIZE,
	input [1:0] S_CACHE_AXI_ARBURST,
	input S_CACHE_AXI_ARLOCK,
	input [3:0] S_CACHE_AXI_ARCACHE,
	input [2:0] S_CACHE_AXI_ARPROT,
	input [3:0] S_CACHE_AXI_ARQOS,
	input [3:0] S_CACHE_AXI_ARREGION,
	input [7 0] S_CACHE_AXI_ARUSER,
	input S_CACHE_AXI_ARVALID,
	output S_CACHE_AXI_ARREADY,
	output [7:0] S_CACHE_AXI_RID,

	output [63:0] S_CACHE_AXI_RDATA,
	output [1:0] S_CACHE_AXI_RRESP,
	output S_CACHE_AXI_RLAST,
	output [7:0] S_CACHE_AXI_RUSER,
	output S_CACHE_AXI_RVALID,
	input S_CACHE_AXI_RREADY,


// RRRRRRRRRRRRRRRRR        OOOOOOOOO     MMMMMMMM               MMMMMMMM
// R::::::::::::::::R     OO:::::::::OO   M:::::::M             M:::::::M
// R::::::RRRRRR:::::R  OO:::::::::::::OO M::::::::M           M::::::::M
// RR:::::R     R:::::RO:::::::OOO:::::::OM:::::::::M         M:::::::::M
//   R::::R     R:::::RO::::::O   O::::::OM::::::::::M       M::::::::::M
//   R::::R     R:::::RO:::::O     O:::::OM:::::::::::M     M:::::::::::M
//   R::::RRRRRR:::::R O:::::O     O:::::OM:::::::M::::M   M::::M:::::::M
//   R:::::::::::::RR  O:::::O     O:::::OM::::::M M::::M M::::M M::::::M
//   R::::RRRRRR:::::R O:::::O     O:::::OM::::::M  M::::M::::M  M::::::M
//   R::::R     R:::::RO:::::O     O:::::OM::::::M   M:::::::M   M::::::M
//   R::::R     R:::::RO:::::O     O:::::OM::::::M    M:::::M    M::::::M
//   R::::R     R:::::RO::::::O   O::::::OM::::::M     MMMMM     M::::::M
// RR:::::R     R:::::RO:::::::OOO:::::::OM::::::M               M::::::M
// R::::::R     R:::::R OO:::::::::::::OO M::::::M               M::::::M
// R::::::R     R:::::R   OO:::::::::OO   M::::::M               M::::::M
// RRRRRRRR     RRRRRRR     OOOOOOOOO     MMMMMMMM               MMMMMMMM


	output [63:0] M_ROM_AXI_AWADDR,
	output M_ROM_AXI_AWVALID,
	input M_ROM_AXI_AWREADY,

	output [63:0] M_ROM_AXI_ARADDR,
	output M_ROM_AXI_ARVALID,
	input M_ROM_AXI_ARREADY,

	input [63 0] M_ROM_AXI_RDATA,
	input [1:0] M_ROM_AXI_RRESP,
	input M_ROM_AXI_RVALID,
	output M_ROM_AXI_RREADY

	output [63:0] M_ROM_AXI_WDATA,
	output [7:0] M_ROM_AXI_WSTRB,
	output M_ROM_AXI_WVALID,
	input M_ROM_AXI_WREADY,

	input [1:0] M_ROM_AXI_BRESP,
	input M_ROM_AXI_BVALID,
	output M_ROM_AXI_BREADY,





//         CCCCCCCCCCCCCLLLLLLLLLLL             IIIIIIIIIINNNNNNNN        NNNNNNNNTTTTTTTTTTTTTTTTTTTTTTT
//      CCC::::::::::::CL:::::::::L             I::::::::IN:::::::N       N::::::NT:::::::::::::::::::::T
//    CC:::::::::::::::CL:::::::::L             I::::::::IN::::::::N      N::::::NT:::::::::::::::::::::T
//   C:::::CCCCCCCC::::CLL:::::::LL             II::::::IIN:::::::::N     N::::::NT:::::TT:::::::TT:::::T
//  C:::::C       CCCCCC  L:::::L                 I::::I  N::::::::::N    N::::::NTTTTTT  T:::::T  TTTTTT
// C:::::C                L:::::L                 I::::I  N:::::::::::N   N::::::N        T:::::T        
// C:::::C                L:::::L                 I::::I  N:::::::N::::N  N::::::N        T:::::T        
// C:::::C                L:::::L                 I::::I  N::::::N N::::N N::::::N        T:::::T        
// C:::::C                L:::::L                 I::::I  N::::::N  N::::N:::::::N        T:::::T        
// C:::::C                L:::::L                 I::::I  N::::::N   N:::::::::::N        T:::::T        
// C:::::C                L:::::L                 I::::I  N::::::N    N::::::::::N        T:::::T        
//  C:::::C       CCCCCC  L:::::L         LLLLLL  I::::I  N::::::N     N:::::::::N        T:::::T        
//   C:::::CCCCCCCC::::CLL:::::::LLLLLLLLL:::::LII::::::IIN::::::N      N::::::::N      TT:::::::TT      
//    CC:::::::::::::::CL::::::::::::::::::::::LI::::::::IN::::::N       N:::::::N      T:::::::::T      
//      CCC::::::::::::CL::::::::::::::::::::::LI::::::::IN::::::N        N::::::N      T:::::::::T      
//         CCCCCCCCCCCCCLLLLLLLLLLLLLLLLLLLLLLLLIIIIIIIIIINNNNNNNN         NNNNNNN      TTTTTTTTTTT    

	output [63:0] M_CLINT_AXI_AWADDR,
	output M_CLINT_AXI_AWVALID,
	input M_CLINT_AXI_AWREADY,

	output [63:0] M_CLINT_AXI_WDATA,
	output [7:0] M_CLINT_AXI_WSTRB,
	output M_CLINT_AXI_WVALID,
	input M_CLINT_AXI_WREADY,

	input [1:0] M_CLINT_AXI_BRESP,
	input M_CLINT_AXI_BVALID,
	output M_CLINT_AXI_BREADY,

	output [63:0] M_CLINT_AXI_ARADDR,
	output M_CLINT_AXI_ARVALID,
	input M_CLINT_AXI_ARREADY,

	input [63 0] M_CLINT_AXI_RDATA,
	input [1:0] M_CLINT_AXI_RRESP,
	input M_CLINT_AXI_RVALID,
	output M_CLINT_AXI_RREADY

// PPPPPPPPPPPPPPPPP   LLLLLLLLLLL             IIIIIIIIII        CCCCCCCCCCCCC
// P::::::::::::::::P  L:::::::::L             I::::::::I     CCC::::::::::::C
// P::::::PPPPPP:::::P L:::::::::L             I::::::::I   CC:::::::::::::::C
// PP:::::P     P:::::PLL:::::::LL             II::::::II  C:::::CCCCCCCC::::C
//   P::::P     P:::::P  L:::::L                 I::::I   C:::::C       CCCCCC
//   P::::P     P:::::P  L:::::L                 I::::I  C:::::C              
//   P::::PPPPPP:::::P   L:::::L                 I::::I  C:::::C              
//   P:::::::::::::PP    L:::::L                 I::::I  C:::::C              
//   P::::PPPPPPPPP      L:::::L                 I::::I  C:::::C              
//   P::::P              L:::::L                 I::::I  C:::::C              
//   P::::P              L:::::L                 I::::I  C:::::C              
//   P::::P              L:::::L         LLLLLL  I::::I   C:::::C       CCCCCC
// PP::::::PP          LL:::::::LLLLLLLLL:::::LII::::::II  C:::::CCCCCCCC::::C
// P::::::::P          L::::::::::::::::::::::LI::::::::I   CC:::::::::::::::C
// P::::::::P          L::::::::::::::::::::::LI::::::::I     CCC::::::::::::C
// PPPPPPPPPP          LLLLLLLLLLLLLLLLLLLLLLLLIIIIIIIIII        CCCCCCCCCCCCC

	output [63:0] M_PLIC_AXI_AWADDR,
	output M_PLIC_AXI_AWVALID,
	input M_PLIC_AXI_AWREADY,

	output [63:0] M_PLIC_AXI_WDATA,
	output [7:0] M_PLIC_AXI_WSTRB,
	output M_PLIC_AXI_WVALID,
	input M_PLIC_AXI_WREADY,

	input [1:0] M_PLIC_AXI_BRESP,
	input M_PLIC_AXI_BVALID,
	output M_PLIC_AXI_BREADY,

	output [63:0] M_PLIC_AXI_ARADDR,
	output M_PLIC_AXI_ARVALID,
	input M_PLIC_AXI_ARREADY,

	input [63 0] M_PLIC_AXI_RDATA,
	input [1:0] M_PLIC_AXI_RRESP,
	input M_PLIC_AXI_RVALID,
	output M_PLIC_AXI_RREADY


//    SSSSSSSSSSSSSSS                                                    tttt                                                           BBBBBBBBBBBBBBBBB                                      
//  SS:::::::::::::::S                                                ttt:::t                                                           B::::::::::::::::B                                     
// S:::::SSSSSS::::::S                                                t:::::t                                                           B::::::BBBBBB:::::B                                    
// S:::::S     SSSSSSS                                                t:::::t                                                           BB:::::B     B:::::B                                   
// S:::::S            yyyyyyy           yyyyyyy    ssssssssss   ttttttt:::::ttttttt        eeeeeeeeeeee       mmmmmmm    mmmmmmm          B::::B     B:::::Buuuuuu    uuuuuu      ssssssssss   
// S:::::S             y:::::y         y:::::y   ss::::::::::s  t:::::::::::::::::t      ee::::::::::::ee   mm:::::::m  m:::::::mm        B::::B     B:::::Bu::::u    u::::u    ss::::::::::s  
//  S::::SSSS           y:::::y       y:::::y  ss:::::::::::::s t:::::::::::::::::t     e::::::eeeee:::::eem::::::::::mm::::::::::m       B::::BBBBBB:::::B u::::u    u::::u  ss:::::::::::::s 
//   SS::::::SSSSS       y:::::y     y:::::y   s::::::ssss:::::stttttt:::::::tttttt    e::::::e     e:::::em::::::::::::::::::::::m       B:::::::::::::BB  u::::u    u::::u  s::::::ssss:::::s
//     SSS::::::::SS      y:::::y   y:::::y     s:::::s  ssssss       t:::::t          e:::::::eeeee::::::em:::::mmm::::::mmm:::::m       B::::BBBBBB:::::B u::::u    u::::u   s:::::s  ssssss 
//        SSSSSS::::S      y:::::y y:::::y        s::::::s            t:::::t          e:::::::::::::::::e m::::m   m::::m   m::::m       B::::B     B:::::Bu::::u    u::::u     s::::::s      
//             S:::::S      y:::::y:::::y            s::::::s         t:::::t          e::::::eeeeeeeeeee  m::::m   m::::m   m::::m       B::::B     B:::::Bu::::u    u::::u        s::::::s   
//             S:::::S       y:::::::::y       ssssss   s:::::s       t:::::t    tttttte:::::::e           m::::m   m::::m   m::::m       B::::B     B:::::Bu:::::uuuu:::::u  ssssss   s:::::s 
// SSSSSSS     S:::::S        y:::::::y        s:::::ssss::::::s      t::::::tttt:::::te::::::::e          m::::m   m::::m   m::::m     BB:::::BBBBBB::::::Bu:::::::::::::::uus:::::ssss::::::s
// S::::::SSSSSS:::::S         y:::::y         s::::::::::::::s       tt::::::::::::::t e::::::::eeeeeeee  m::::m   m::::m   m::::m     B:::::::::::::::::B  u:::::::::::::::us::::::::::::::s 
// S:::::::::::::::SS         y:::::y           s:::::::::::ss          tt:::::::::::tt  ee:::::::::::::e  m::::m   m::::m   m::::m     B::::::::::::::::B    uu::::::::uu:::u s:::::::::::ss  
//  SSSSSSSSSSSSSSS          y:::::y             sssssssssss              ttttttttttt      eeeeeeeeeeeeee  mmmmmm   mmmmmm   mmmmmm     BBBBBBBBBBBBBBBBB       uuuuuuuu  uuuu  sssssssssss    
//                          y:::::y                                                                                                                                                            
//                         y:::::y                                                                                                                                                             
//                        y:::::y                                                                                                                                                              
//                       y:::::y                                                                                                                                                               
//                      yyyyyyy                                                                                                                                                             
	
	input M_SYS_AXI_ACLK,
	input M_SYS_AXI_ARESETN,

	output [7:0] M_SYS_AXI_AWID,
	output [63:0] M_SYS_AXI_AWADDR,
	output [7:0] M_SYS_AXI_AWLEN,
	output [2:0] M_SYS_AXI_AWSIZE,
	output [1:0] M_SYS_AXI_AWBURST,
	output M_SYS_AXI_AWLOCK,
	output [3:0] M_SYS_AXI_AWCACHE,
	output [2:0] M_SYS_AXI_AWPROT,
	output [3:0] M_SYS_AXI_AWQOS,
	output [7:0] M_SYS_AXI_AWUSER,
	output M_SYS_AXI_AWVALID,
	input M_SYS_AXI_AWREADY,

	output [63:0] M_SYS_AXI_WDATA,
	output [7:0] M_SYS_AXI_WSTRB,
	output M_SYS_AXI_WLAST,
	output [7:0] M_SYS_AXI_WUSER,
	output M_SYS_AXI_WVALID,
	input M_SYS_AXI_WREADY,

	input [7:0] M_SYS_AXI_BID,
	input [1:0] M_SYS_AXI_BRESP,
	input [7:0] M_SYS_AXI_BUSER,
	input M_SYS_AXI_BVALID,
	output M_SYS_AXI_BREADY,

	output [7:0] M_SYS_AXI_ARID,
	output [63:0] M_SYS_AXI_ARADDR,
	output [7:0] M_SYS_AXI_ARLEN,
	output [2:0] M_SYS_AXI_ARSIZE,
	output [1:0] M_SYS_AXI_ARBURST,
	output M_SYS_AXI_ARLOCK,
	output [3:0] M_SYS_AXI_ARCACHE,
	output [2:0] M_SYS_AXI_ARPROT,
	output [3:0] M_SYS_AXI_ARQOS,
	output [7:0] M_SYS_AXI_ARUSER,
	output M_SYS_AXI_ARVALID,
	input M_SYS_AXI_ARREADY,

	input [7:0] M_SYS_AXI_RID,
	input [63 0] M_SYS_AXI_RDATA,
	input [1:0] M_SYS_AXI_RRESP,
	input M_SYS_AXI_RLAST,
	input [7 0] M_SYS_AXI_RUSER,
	input M_SYS_AXI_RVALID,
	output M_SYS_AXI_RREADY,



// MMMMMMMM               MMMMMMMM                                                                                                               BBBBBBBBBBBBBBBBB                                      
// M:::::::M             M:::::::M                                                                                                               B::::::::::::::::B                                     
// M::::::::M           M::::::::M                                                                                                               B::::::BBBBBB:::::B                                    
// M:::::::::M         M:::::::::M                                                                                                               BB:::::B     B:::::B                                   
// M::::::::::M       M::::::::::M    eeeeeeeeeeee       mmmmmmm    mmmmmmm      ooooooooooo   rrrrr   rrrrrrrrr   yyyyyyy           yyyyyyy       B::::B     B:::::Buuuuuu    uuuuuu      ssssssssss   
// M:::::::::::M     M:::::::::::M  ee::::::::::::ee   mm:::::::m  m:::::::mm  oo:::::::::::oo r::::rrr:::::::::r   y:::::y         y:::::y        B::::B     B:::::Bu::::u    u::::u    ss::::::::::s  
// M:::::::M::::M   M::::M:::::::M e::::::eeeee:::::eem::::::::::mm::::::::::mo:::::::::::::::or:::::::::::::::::r   y:::::y       y:::::y         B::::BBBBBB:::::B u::::u    u::::u  ss:::::::::::::s 
// M::::::M M::::M M::::M M::::::Me::::::e     e:::::em::::::::::::::::::::::mo:::::ooooo:::::orr::::::rrrrr::::::r   y:::::y     y:::::y          B:::::::::::::BB  u::::u    u::::u  s::::::ssss:::::s
// M::::::M  M::::M::::M  M::::::Me:::::::eeeee::::::em:::::mmm::::::mmm:::::mo::::o     o::::o r:::::r     r:::::r    y:::::y   y:::::y           B::::BBBBBB:::::B u::::u    u::::u   s:::::s  ssssss 
// M::::::M   M:::::::M   M::::::Me:::::::::::::::::e m::::m   m::::m   m::::mo::::o     o::::o r:::::r     rrrrrrr     y:::::y y:::::y            B::::B     B:::::Bu::::u    u::::u     s::::::s      
// M::::::M    M:::::M    M::::::Me::::::eeeeeeeeeee  m::::m   m::::m   m::::mo::::o     o::::o r:::::r                  y:::::y:::::y             B::::B     B:::::Bu::::u    u::::u        s::::::s   
// M::::::M     MMMMM     M::::::Me:::::::e           m::::m   m::::m   m::::mo::::o     o::::o r:::::r                   y:::::::::y              B::::B     B:::::Bu:::::uuuu:::::u  ssssss   s:::::s 
// M::::::M               M::::::Me::::::::e          m::::m   m::::m   m::::mo:::::ooooo:::::o r:::::r                    y:::::::y             BB:::::BBBBBB::::::Bu:::::::::::::::uus:::::ssss::::::s
// M::::::M               M::::::M e::::::::eeeeeeee  m::::m   m::::m   m::::mo:::::::::::::::o r:::::r                     y:::::y              B:::::::::::::::::B  u:::::::::::::::us::::::::::::::s 
// M::::::M               M::::::M  ee:::::::::::::e  m::::m   m::::m   m::::m oo:::::::::::oo  r:::::r                    y:::::y               B::::::::::::::::B    uu::::::::uu:::u s:::::::::::ss  
// MMMMMMMM               MMMMMMMM    eeeeeeeeeeeeee  mmmmmm   mmmmmm   mmmmmm   ooooooooooo    rrrrrrr                   y:::::y                BBBBBBBBBBBBBBBBB       uuuuuuuu  uuuu  sssssssssss    
//                                                                                                                       y:::::y                                                                        
//                                                                                                                      y:::::y                                                                         
//                                                                                                                     y:::::y                                                                          
//                                                                                                                    y:::::y                                                                           
//                                                                                                                   yyyyyyy  


	input M_MEM_AXI_ACLK,
	input M_MEM_AXI_ARESETN,

	output [7:0] M_MEM_AXI_AWID,
	output [63:0] M_MEM_AXI_AWADDR,
	output [7:0] M_MEM_AXI_AWLEN,
	output [2:0] M_MEM_AXI_AWSIZE,
	output [1:0] M_MEM_AXI_AWBURST,
	output M_MEM_AXI_AWLOCK,
	output [3:0] M_MEM_AXI_AWCACHE,
	output [2:0] M_MEM_AXI_AWPROT,
	output [3:0] M_MEM_AXI_AWQOS,
	output [7:0] M_MEM_AXI_AWUSER,
	output M_MEM_AXI_AWVALID,
	input M_MEM_AXI_AWREADY,

	output [63:0] M_MEM_AXI_WDATA,
	output [7:0] M_MEM_AXI_WSTRB,
	output M_MEM_AXI_WLAST,
	output [7:0] M_MEM_AXI_WUSER,
	output M_MEM_AXI_WVALID,
	input M_MEM_AXI_WREADY,

	input [7:0] M_MEM_AXI_BID,
	input [1:0] M_MEM_AXI_BRESP,
	input [7:0] M_MEM_AXI_BUSER,
	input M_MEM_AXI_BVALID,
	output M_MEM_AXI_BREADY,

	output [7:0] M_MEM_AXI_ARID,
	output [63:0] M_MEM_AXI_ARADDR,
	output [7:0] M_MEM_AXI_ARLEN,
	output [2:0] M_MEM_AXI_ARSIZE,
	output [1:0] M_MEM_AXI_ARBURST,
	output M_MEM_AXI_ARLOCK,
	output [3:0] M_MEM_AXI_ARCACHE,
	output [2:0] M_MEM_AXI_ARPROT,
	output [3:0] M_MEM_AXI_ARQOS,
	output [7:0] M_MEM_AXI_ARUSER,
	output M_MEM_AXI_ARVALID,
	input M_MEM_AXI_ARREADY,

	input [7:0] M_MEM_AXI_RID,
	input [63 0] M_MEM_AXI_RDATA,
	input [1:0] M_MEM_AXI_RRESP,
	input M_MEM_AXI_RLAST,
	input [7 0] M_MEM_AXI_RUSER,
	input M_MEM_AXI_RVALID,
	output M_MEM_AXI_RREADY,


// PPPPPPPPPPPPPPPPP                                             iiii                      hhhhhhh                                                                       lllllll                       BBBBBBBBBBBBBBBBB                                      
// P::::::::::::::::P                                           i::::i                     h:::::h                                                                       l:::::l                       B::::::::::::::::B                                     
// P::::::PPPPPP:::::P                                           iiii                      h:::::h                                                                       l:::::l                       B::::::BBBBBB:::::B                                    
// PP:::::P     P:::::P                                                                    h:::::h                                                                       l:::::l                       BB:::::B     B:::::B                                   
//   P::::P     P:::::P    eeeeeeeeeeee    rrrrr   rrrrrrrrr   iiiiiii ppppp   ppppppppp    h::::h hhhhh           eeeeeeeeeeee    rrrrr   rrrrrrrrr     aaaaaaaaaaaaa    l::::l     ssssssssss          B::::B     B:::::Buuuuuu    uuuuuu      ssssssssss   
//   P::::P     P:::::P  ee::::::::::::ee  r::::rrr:::::::::r  i:::::i p::::ppp:::::::::p   h::::hh:::::hhh      ee::::::::::::ee  r::::rrr:::::::::r    a::::::::::::a   l::::l   ss::::::::::s         B::::B     B:::::Bu::::u    u::::u    ss::::::::::s  
//   P::::PPPPPP:::::P  e::::::eeeee:::::eer:::::::::::::::::r  i::::i p:::::::::::::::::p  h::::::::::::::hh   e::::::eeeee:::::eer:::::::::::::::::r   aaaaaaaaa:::::a  l::::l ss:::::::::::::s        B::::BBBBBB:::::B u::::u    u::::u  ss:::::::::::::s 
//   P:::::::::::::PP  e::::::e     e:::::err::::::rrrrr::::::r i::::i pp::::::ppppp::::::p h:::::::hhh::::::h e::::::e     e:::::err::::::rrrrr::::::r           a::::a  l::::l s::::::ssss:::::s       B:::::::::::::BB  u::::u    u::::u  s::::::ssss:::::s
//   P::::PPPPPPPPP    e:::::::eeeee::::::e r:::::r     r:::::r i::::i  p:::::p     p:::::p h::::::h   h::::::he:::::::eeeee::::::e r:::::r     r:::::r    aaaaaaa:::::a  l::::l  s:::::s  ssssss        B::::BBBBBB:::::B u::::u    u::::u   s:::::s  ssssss 
//   P::::P            e:::::::::::::::::e  r:::::r     rrrrrrr i::::i  p:::::p     p:::::p h:::::h     h:::::he:::::::::::::::::e  r:::::r     rrrrrrr  aa::::::::::::a  l::::l    s::::::s             B::::B     B:::::Bu::::u    u::::u     s::::::s      
//   P::::P            e::::::eeeeeeeeeee   r:::::r             i::::i  p:::::p     p:::::p h:::::h     h:::::he::::::eeeeeeeeeee   r:::::r             a::::aaaa::::::a  l::::l       s::::::s          B::::B     B:::::Bu::::u    u::::u        s::::::s   
//   P::::P            e:::::::e            r:::::r             i::::i  p:::::p    p::::::p h:::::h     h:::::he:::::::e            r:::::r            a::::a    a:::::a  l::::l ssssss   s:::::s        B::::B     B:::::Bu:::::uuuu:::::u  ssssss   s:::::s 
// PP::::::PP          e::::::::e           r:::::r            i::::::i p:::::ppppp:::::::p h:::::h     h:::::he::::::::e           r:::::r            a::::a    a:::::a l::::::ls:::::ssss::::::s     BB:::::BBBBBB::::::Bu:::::::::::::::uus:::::ssss::::::s
// P::::::::P           e::::::::eeeeeeee   r:::::r            i::::::i p::::::::::::::::p  h:::::h     h:::::h e::::::::eeeeeeee   r:::::r            a:::::aaaa::::::a l::::::ls::::::::::::::s      B:::::::::::::::::B  u:::::::::::::::us::::::::::::::s 
// P::::::::P            ee:::::::::::::e   r:::::r            i::::::i p::::::::::::::pp   h:::::h     h:::::h  ee:::::::::::::e   r:::::r             a::::::::::aa:::al::::::l s:::::::::::ss       B::::::::::::::::B    uu::::::::uu:::u s:::::::::::ss  
// PPPPPPPPPP              eeeeeeeeeeeeee   rrrrrrr            iiiiiiii p::::::pppppppp     hhhhhhh     hhhhhhh    eeeeeeeeeeeeee   rrrrrrr              aaaaaaaaaa  aaaallllllll  sssssssssss         BBBBBBBBBBBBBBBBB       uuuuuuuu  uuuu  sssssssssss    
//                                                                      p:::::p                                                                                                                                                                               
//                                                                      p:::::p                                                                                                                                                                               
//                                                                     p:::::::p                                                                                                                                                                              
//                                                                     p:::::::p                                                                                                                                                                              
//                                                                     p:::::::p                                                                                                                                                                              
//                                                                     ppppppppp 


	output [7:0] M_PERIP_AXI_AWADDR,
	output [2:0] M_PERIP_AXI_AWPROT,
	output M_PERIP_AXI_AWVALID,
	input M_PERIP_AXI_AWREADY,

	output [31:0] M_PERIP_AXI_WDATA,
	output [3:0] M_PERIP_AXI_WSTRB,
	output M_PERIP_AXI_WVALID,
	input M_PERIP_AXI_WREADY,

	input [1:0] M_PERIP_AXI_BRESP,
	input M_PERIP_AXI_BVALID,
	output M_PERIP_AXI_BREADY,

	output [7:0] M_PERIP_AXI_ARADDR,
	output [2:0] M_PERIP_AXI_ARPROT,
	output M_PERIP_AXI_ARVALID,
	input M_PERIP_AXI_ARREADY,

	input [31:0] M_PERIP_AXI_RDATA,
	input [1:0] M_PERIP_AXI_RRESP,
	input M_PERIP_AXI_RVALID,
	output M_PERIP_AXI_RREADY,




	input S_INNER_AXI_ACLK,
	input S_INNER_AXI_ARESETN,
	input S_DM_AXI_ACLK,
	input S_DM_AXI_ARESETN,
	input S_CACHE_AXI_ACLK,
	input S_CACHE_AXI_ARESETN,


	input M_SYS_AXI_ACLK,
	input M_SYS_AXI_ARESETN,
	input M_MEM_AXI_ACLK,
	input M_MEM_AXI_ARESETN,
	input M_PERIP_AXI_ACLK,
	input M_PERIP_AXI_ARESETN,
);






crossBar_syn #
(
	parameter ISASYN = 1
)
(

	// master Demain
	input S_AWVALID,
	input S_WVALID,
	input S_BREADY,
	input S_ARVALID,
	input S_RREADY,
	output S_AWREADY,
	output S_ARREADY,
	output S_RVALID,
	output S_WREADY,
	output S_BVALID,
	input S_CLK,
	input S_RSTn,


	//CrossBar Demain
	output M_AWVALID,
	output M_WVALID,
	output M_BREADY,
	output M_ARVALID,
	output M_RREADY,
	input M_ARREADY,
	input M_RVALID,
	input M_WREADY,
	input M_BVALID,
	input M_AWREADY,
	input M_CLK,
	input M_RSTn

);




























































wire systemBusError = | ;

//dm > cache > inner






































//Read
wire isDM_Read_ROM = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_ROM = 1'b0;
wire isINNER_Read_ROM = (~isDM_Read_ROM) & S_INNER_AXI_ARADDR[] == & S_INNER_AXI_ARVALID;

wire isDM_Read_CLINT = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_CLINT = 1'b0;
wire isINNER_Read_CLINT = (~isDM_Read_CLINT) & S_INNER_AXI_ARADDR[] == & S_INNER_AXI_ARVALID;

wire isDM_Read_PLIC = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_PLIC = 1'b0;
wire isINNER_Read_PLIC = (~isDM_Read_PLIC) & S_INNER_AXI_ARADDR[] == & S_INNER_AXI_ARVALID;

wire isDM_Read_SYS = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_SYS = 1'b0;
wire isINNER_Read_SYS = (~isDM_Read_SYS) & S_INNER_AXI_ARADDR[] == & S_INNER_AXI_ARVALID;

wire isDM_Read_MEM = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_MEM = (~isDM_Read_MEM) & ( S_DM_AXI_RDATA[63:] ==  & S_CACHE_AXI_ARVALID);
wire isINNER_Read_MEM = (~isCache_Read_MEM) & (~isDM_Read_MEM) & ( S_DM_AXI_RDATA[63:] ==  & S_INNER_AXI_ARVALID);;

wire isDM_Read_PERIP = ( S_DM_AXI_RDATA[63:] ==  & S_DM_AXI_ARVALID);
wire isCACHE_Read_PERIP = 1'b0;
wire isINNER_Read_PERIP = (~isDM_Read_PERIP) & S_INNER_AXI_ARADDR[] == & S_INNER_AXI_ARVALID;




assign S_DM_AXI_ARREADY = ( isDM_Read_ROM   & M_ROM_AXI_ARREADY )
						| ( isDM_Read_CLINT & M_PLIC_AXI_ARREADY )
						| ( isDM_Read_PLIC  & M_PLIC_AXI_ARREADY )
						| ( isDM_Read_SYS   & M_SYS_AXI_ARREADY )
						| ( isDM_Read_MEM   & M_MEM_AXI_ARREADY )
						| ( isDM_Read_PERIP & M_PERIP_AXI_ARREADY );

assign S_CACHE_AXI_ARREADY = ( isCACHE_Read_MEM   & M_MEM_AXI_ARREADY );

assign S_INNER_AXI_ARREADY = ( isINNER_Read_ROM   & M_ROM_AXI_ARREADY )
							| ( isINNER_Read_CLINT & M_PLIC_AXI_ARREADY )
							| ( isINNER_Read_PLIC  & M_PLIC_AXI_ARREADY )
							| ( isINNER_Read_SYS   & M_SYS_AXI_ARREADY )
							| ( isINNER_Read_MEM   & M_MEM_AXI_ARREADY )
							| ( isINNER_Read_PERIP & M_PERIP_AXI_ARREADY );





assign S_DM_AXI_RDATA = ( {64{isDM_Read_ROM}}   & M_ROM_AXI_RDATA )
						| ( {64{isDM_Read_CLINT}} & M_PLIC_AXI_RDATA )
						| ( {64{isDM_Read_PLIC}}  & M_PLIC_AXI_RDATA )
						| ( {64{isDM_Read_SYS}}   & M_SYS_AXI_RDATA )
						| ( {64{isDM_Read_MEM}}   & M_MEM_AXI_RDATA )
						| ( {64{isDM_Read_PERIP}} & M_PERIP_AXI_RDATA );

assign S_CACHE_AXI_RDATA = {64{isCACHE_Read_MEM}} & M_MEM_AXI_RDATA;

assign S_INNER_AXI_RDATA = ( {64{isINNER_Read_ROM}}   & M_ROM_AXI_RDATA )
							| ( {64{isINNER_Read_CLINT}} & M_PLIC_AXI_RDATA )
							| ( {64{isINNER_Read_PLIC}}  & M_PLIC_AXI_RDATA )
							| ( {64{isINNER_Read_SYS}}   & M_SYS_AXI_RDATA )
							| ( {64{isINNER_Read_MEM}}   & M_MEM_AXI_RDATA )
							| ( {64{isINNER_Read_PERIP}} & M_PERIP_AXI_RDATA );



assign S_DM_AXI_RRESP = ( {2{isDM_Read_ROM}}   & M_ROM_AXI_RRESP )
						| ( {2{isDM_Read_CLINT}} & M_PLIC_AXI_RRESP )
						| ( {2{isDM_Read_PLIC}}  & M_PLIC_AXI_RRESP )
						| ( {2{isDM_Read_SYS}}   & M_SYS_AXI_RRESP )
						| ( {2{isDM_Read_MEM}}   & M_MEM_AXI_RRESP )
						| ( {2{isDM_Read_PERIP}} & M_PERIP_AXI_RRESP );

assign S_DM_AXI_RVALID = ( isDM_Read_ROM   & M_ROM_AXI_RVALID )
						| ( isDM_Read_CLINT & M_PLIC_AXI_RVALID )
						| ( isDM_Read_PLIC  & M_PLIC_AXI_RVALID )
						| ( isDM_Read_SYS   & M_SYS_AXI_RVALID )
						| ( isDM_Read_MEM   & M_MEM_AXI_RVALID )
						| ( isDM_Read_PERIP & M_PERIP_AXI_RVALID );






gen_fifo # ( .DW(), .AW() ) read_req(

	input fifo_pop, 
	input fifo_push,
	input [DW-1:0] data_push,

	output fifo_empty, 
	output fifo_full, 
	output [DW-1:0] data_pop,

	input flush,
	input CLK,
	input RSTn
);

gen_fifo # ( .DW(), .AW() ) read_req(
	input fifo_pop, 
	input fifo_push,
	input [DW-1:0] data_push,

	output fifo_empty, 
	output fifo_full, 
	output [DW-1:0] data_pop,

	input flush,
	input CLK,
	input RSTn
);





	wire [7:0] AWID;
	wire [63:0] AWADDR;
	wire [7:0] AWLEN;
	wire [2:0] AWSIZE;
	wire [1:0] AWBURST;
	wire AWLOCK;
	wire [3:0] AWCACHE;
	wire [2:0] AWPROT;
	wire [3:0] AWQOS;
	wire [7:0] AWUSER;
	wire AWVALID;
	wire AWREADY;

	wire [63:0] WDATA,
	wire [7:0] WSTRB,
	wire WLAST,
	wire [7:0] WUSER,
	wire WVALID,
	wire WREADY,

	wire [7:0] BID,
	wire [1:0] BRESP,
	wire [7:0] BUSER,
	wire BVALID,
	output BREADY,

	wire [7:0] ARID;
	wire [63:0] ARADDR;
	wire [7:0] ARLEN;
	wire [2:0] ARSIZE;
	wire [1:0] ARBURST;
	wire ARLOCK;
	wire [3:0] ARCACHE;
	wire [2:0] ARPROT;
	wire [3:0] ARQOS;
	wire [7:0] ARUSER;
	wire ARVALID;
	wire ARREADY;

	wire [7:0] RID;
	wire [63 0] RDATA;
	wire [1:0] RRESP;
	wire RLAST;
	wire [7 0] RUSER;
	wire RVALID;
	wire RREADY;


















endmodule







