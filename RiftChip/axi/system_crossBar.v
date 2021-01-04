/*
* @File name: system_crossBar
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-02 09:45:29
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-04 09:24:29
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


module system_crossBar #
(
	parameter S_NUM = 3,
	parameter M_NUM = 7
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
	input [1:0] S_CACHE_AXI_AWBURST,
	input S_CACHE_AXI_AWVALID,
	output S_CACHE_AXI_AWREADY,

	input [63:0] S_CACHE_AXI_WDATA,
	input [7:0] S_CACHE_AXI_WSTRB,
	input S_CACHE_AXI_WLAST,
	input S_CACHE_AXI_WVALID,
	output S_CACHE_AXI_WREADY,

	output [7:0] S_CACHE_AXI_BID,
	output [1:0] S_CACHE_AXI_BRESP,
	output S_CACHE_AXI_BVALID,
	input S_CACHE_AXI_BREADY,

	input [7:0] S_CACHE_AXI_ARID,
	input [63:0] S_CACHE_AXI_ARADDR,
	input [7:0] S_CACHE_AXI_ARLEN,
	input [1:0] S_CACHE_AXI_ARBURST,
	input S_CACHE_AXI_ARVALID,
	output S_CACHE_AXI_ARREADY,

	output [7:0] S_CACHE_AXI_RID,
	output [63:0] S_CACHE_AXI_RDATA,
	output [1:0] S_CACHE_AXI_RRESP,
	output S_CACHE_AXI_RLAST,
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

//  PPPPPPPPPPPPPPPPP  BBBBBBBBBBBBBBBBB   
//  P::::::::::::::::P B::::::::::::::::B  
//  P::::::PPPPPP:::::PB::::::BBBBBB:::::B 
//  PP:::::P     P:::::BB:::::B     B:::::B
//    P::::P     P:::::P B::::B     B:::::B
//    P::::P     P:::::P B::::B     B:::::B
//    P::::PPPPPP:::::P  B::::BBBBBB:::::B 
//    P:::::::::::::PP   B:::::::::::::BB  
//    P::::PPPPPPPPP     B::::BBBBBB:::::B 
//    P::::P             B::::B     B:::::B
//    P::::P             B::::B     B:::::B
//    P::::P             B::::B     B:::::B
//  PP::::::PP         BB:::::BBBBBB::::::B
//  P::::::::P         B:::::::::::::::::B 
//  P::::::::P         B::::::::::::::::B  
//  PPPPPPPPPP         BBBBBBBBBBBBBBBBB   


	output [63:0] M_PB_AXI_AWADDR,
	output M_PB_AXI_AWVALID,
	input M_PB_AXI_AWREADY,

	output [63:0] M_PB_AXI_ARADDR,
	output M_PB_AXI_ARVALID,
	input M_PB_AXI_ARREADY,

	input [63 0] M_PB_AXI_RDATA,
	input [1:0] M_PB_AXI_RRESP,
	input M_PB_AXI_RVALID,
	output M_PB_AXI_RREADY

	output [63:0] M_PB_AXI_WDATA,
	output [7:0] M_PB_AXI_WSTRB,
	output M_PB_AXI_WVALID,
	input M_PB_AXI_WREADY,

	input [1:0] M_PB_AXI_BRESP,
	input M_PB_AXI_BVALID,
	output M_PB_AXI_BREADY,



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
	output [1:0] M_SYS_AXI_AWBURST,
	output M_SYS_AXI_AWVALID,
	input M_SYS_AXI_AWREADY,

	output [63:0] M_SYS_AXI_WDATA,
	output [7:0] M_SYS_AXI_WSTRB,
	output M_SYS_AXI_WLAST,
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
	output [1:0] M_SYS_AXI_ARBURST,
	output M_SYS_AXI_ARVALID,
	input M_SYS_AXI_ARREADY,

	input [7:0] M_SYS_AXI_RID,
	input [63 0] M_SYS_AXI_RDATA,
	input [1:0] M_SYS_AXI_RRESP,
	input M_SYS_AXI_RLAST,
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
	output [1:0] M_MEM_AXI_AWBURST,
	output M_MEM_AXI_AWVALID,
	input M_MEM_AXI_AWREADY,

	output [63:0] M_MEM_AXI_WDATA,
	output [7:0] M_MEM_AXI_WSTRB,
	output M_MEM_AXI_WLAST,
	output M_MEM_AXI_WVALID,
	input M_MEM_AXI_WREADY,

	input [7:0] M_MEM_AXI_BID,
	input [1:0] M_MEM_AXI_BRESP,
	input M_MEM_AXI_BVALID,
	output M_MEM_AXI_BREADY,

	output [7:0] M_MEM_AXI_ARID,
	output [63:0] M_MEM_AXI_ARADDR,
	output [7:0] M_MEM_AXI_ARLEN,
	output [1:0] M_MEM_AXI_ARBURST,
	output M_MEM_AXI_ARVALID,
	input M_MEM_AXI_ARREADY,

	input [7:0] M_MEM_AXI_RID,
	input [63 0] M_MEM_AXI_RDATA,
	input [1:0] M_MEM_AXI_RRESP,
	input M_MEM_AXI_RLAST,
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
	output M_PERIP_AXI_ARVALID,
	input M_PERIP_AXI_ARREADY,

	input [31:0] M_PERIP_AXI_RDATA,
	input [1:0] M_PERIP_AXI_RRESP,
	input M_PERIP_AXI_RVALID,
	output M_PERIP_AXI_RREADY,



	ouptut systemBusError,
	input CLK,
	input RSTn
);


initial $warning("All master and slave must use syn clock with bus");




// MMMMMMMM               MMMMMMMMUUUUUUUU     UUUUUUUUXXXXXXX       XXXXXXX
// M:::::::M             M:::::::MU::::::U     U::::::UX:::::X       X:::::X
// M::::::::M           M::::::::MU::::::U     U::::::UX:::::X       X:::::X
// M:::::::::M         M:::::::::MUU:::::U     U:::::UUX::::::X     X::::::X
// M::::::::::M       M::::::::::M U:::::U     U:::::U XXX:::::X   X:::::XXX
// M:::::::::::M     M:::::::::::M U:::::D     D:::::U    X:::::X X:::::X   
// M:::::::M::::M   M::::M:::::::M U:::::D     D:::::U     X:::::X:::::X    
// M::::::M M::::M M::::M M::::::M U:::::D     D:::::U      X:::::::::X     
// M::::::M  M::::M::::M  M::::::M U:::::D     D:::::U      X:::::::::X     
// M::::::M   M:::::::M   M::::::M U:::::D     D:::::U     X:::::X:::::X    
// M::::::M    M:::::M    M::::::M U:::::D     D:::::U    X:::::X X:::::X   
// M::::::M     MMMMM     M::::::M U::::::U   U::::::U XXX:::::X   X:::::XXX
// M::::::M               M::::::M U:::::::UUU:::::::U X::::::X     X::::::X
// M::::::M               M::::::M  UU:::::::::::::UU  X:::::X       X:::::X
// M::::::M               M::::::M    UU:::::::::UU    X:::::X       X:::::X
// MMMMMMMM               MMMMMMMM      UUUUUUUUU      XXXXXXX       XXXXXXX



//dm > cache > inner


// ,-.----.      ,---,.  ,---,          ,---,     
// \    /  \   ,'  .' | '  .' \       .'  .' `\   
// ;   :    \,---.'   |/  ;    '.   ,---.'     \  
// |   | .\ :|   |   .:  :       \  |   |  .`\  | 
// .   : |: |:   :  |-:  |   /\   \ :   : |  '  | 
// |   |  \ ::   |  ;/|  :  ' ;.   :|   ' '  ;  : 
// |   : .  /|   :   .|  |  ;/  \   '   | ;  .  | 
// ;   | |  \|   |  |-'  :  | \  \ ,|   | :  |  ' 
// |   | ;\  '   :  ;/|  |  '  '--' '   : | /  ;  
// :   ' | \.|   |    |  :  :       |   | '` ,/   
// :   : :-' |   :   .|  | ,'       ;   :  .'     
// |   |.'   |   | ,' `--''         |   ,.'       
// `---'     `----'                 '---'

	wire read_fifo_full;
	wire write_fifo_full;

	wire [7:0] ARID;
	wire [63:0] ARADDR;
	wire [7:0] ARLEN;
	wire [1:0] ARBURST;
	wire ARVALID;
	wire ARREADY;

	wire [7:0] RID;
	wire [63 0] RDATA;
	wire [1:0] RRESP;
	wire RLAST;
	wire RVALID;
	wire RREADY;

	wire isDM_AR_ROM, isDM_R_ROM;
	wire isCACHE_AR_ROM, isCACHE_R_ROM;
	wire isINNER_AR_ROM, isINNER_R_ROM;
	wire isDM_AR_PB, isDM_R_PB;
	wire isCACHE_AR_PB, isCACHE_R_PB;
	wire isINNER_AR_PB, isINNER_R_PB;
	wire isDM_AR_CLINT, isDM_R_CLINT;
	wire isCACHE_AR_CLINT, isCACHE_R_CLINT;
	wire isINNER_AR_CLINT, isINNER_R_CLINT;
	wire isDM_AR_PLIC, isDM_R_PLIC;
	wire isCACHE_AR_PLIC, isCACHE_R_PLIC;
	wire isINNER_AR_PLIC, isINNER_R_PLIC;
	wire isDM_AR_PERIP, isDM_R_PERIP;
	wire isCACHE_AR_PERIP, isCACHE_R_PERIP;
	wire isINNER_AR_PERIP, isINNER_R_PERIP;
	wire isDM_AR_SYS, isDM_R_SYS;
	wire isCACHE_AR_SYS, isCACHE_R_SYS;
	wire isINNER_AR_SYS, isINNER_R_SYS;
	wire isDM_AR_MEM, isDM_R_MEM;
	wire isCACHE_AR_MEM, isCACHE_R_MEM;
	wire isINNER_AR_MEM, isINNER_R_MEM;

	wire [S_NUM*M_NUM-1:0] readMuxList_push
	wire [S_NUM*M_NUM-1:0] readMuxList_pop;

	assign = readMuxList_push = 
							{ isDM_AR_ROM, isCACHE_AR_ROM, isINNER_AR_ROM,
							isDM_AR_PB, isCACHE_AR_PB, isINNER_AR_PB,
							isDM_AR_CLINT, isCACHE_AR_CLINT, isINNER_AR_CLINT,
							isDM_AR_PLIC, isCACHE_AR_PLIC, isINNER_AR_PLIC,
							isDM_AR_PERIP, isCACHE_AR_PERIP, isINNER_AR_PERIP,
							isDM_AR_SYS, isCACHE_AR_SYS, isINNER_AR_SYS,
							isDM_AR_MEM, isCACHE_AR_MEM, isINNER_AR_MEM };


	assign 	{ isDM_R_ROM, isCACHE_R_ROM, isINNER_R_ROM,
			isDM_R_PB, isCACHE_R_PB, isINNER_R_PB,
			isDM_R_CLINT, isCACHE_R_CLINT, isINNER_R_CLINT,
			isDM_R_PLIC, isCACHE_R_PLIC, isINNER_R_PLIC,
			isDM_R_PERIP, isCACHE_R_PERIP, isINNER_R_PERIP,
			isDM_R_SYS, isCACHE_R_SYS, isINNER_R_SYS,
			isDM_R_MEM, isCACHE_R_MEM, isINNER_R_MEM } = readMuxList_pop;


	wire isDM_AR_ROM =  (S_DM_AXI_ARADDR[63:16] == 48'h0) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_ROM = 1'b0;
	wire isINNER_AR_ROM = (S_INNER_AXI_ARADDR[63:16] == 48'h0) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PB =  (S_DM_AXI_ARADDR[63:16] == 48'h1) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PB = 1'b0;
	wire isINNER_AR_PB = (S_INNER_AXI_ARADDR[63:16] == 48'h1) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_CLINT = ( S_DM_AXI_ARADDR[63:24] == 40'h2 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_CLINT = 1'b0;
	wire isINNER_AR_CLINT = S_INNER_AXI_ARADDR[63:24] == 40'h2 & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PLIC = (S_DM_AXI_ARADDR[63:24] == 40'h3) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PLIC = 1'b0;
	wire isINNER_AR_PLIC = (S_INNER_AXI_ARADDR[63:24] == 40'h3) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PERIP = ( S_DM_AXI_ARADDR[63:28] == 36'h2 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PERIP = 1'b0;
	wire isINNER_AR_PERIP = (S_INNER_AXI_ARADDR[63:28] == 36'h2 ) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_SYS = (S_DM_AXI_ARADDR[63:28] == 36'h4) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_SYS = 1'b0;
	wire isINNER_AR_SYS = (S_INNER_AXI_ARADDR[63:28] == 36'h4) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & ~S_DM_AXI_ARVALID & S_CACHE_AXI_ARVALID;
	wire isINNER_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;


	assign ARID = S_DM_AXI_ARVALID ? 8'b0 : ( S_CACHE_AXI_ARVALID ? S_CACHE_AXI_ARID : (S_INNER_AXI_ARVALID ? 8'b0 : 8'b0) );
	assign ARADDR = S_DM_AXI_ARVALID ? S_DW_AXI_ARADDR : ( S_CACHE_AXI_ARVALID ? S_CACHE_AXI_ARADDR : (S_INNER_AXI_ARVALID ? S_INNER_AXI_ARADDR : 64'h0) );
	assign ARLEN = S_DM_AXI_ARVALID ? 8'b0 : ( S_CACHE_AXI_ARVALID ? S_CACHE_AXI_ARLEN : (S_INNER_AXI_ARVALID ? 8'b0 : 8'b0) );
	
	assign ARBURST = S_DM_AXI_ARVALID ? 2'b0 : ( S_CACHE_AXI_ARVALID ? S_CACHE_AXI_ARBURST : (S_INNER_AXI_ARVALID ? 2'b0 : 2'b0) );;

	assign ARVALID = (~read_fifo_full) & (S_DM_AXI_ARVALID | S_CACHE_AXI_ARVALID | S_INNER_AXI_ARVALID);


	assign ARREADY = ((isDM_AR_ROM | isINNER_AR_ROM) & M_ROM_AXI_ARREADY)
					|
					( (isDM_AR_PB | isINNER_AR_PB) & M_PB_AXI_ARREADY )
					|
					( (isDM_AR_CLINT | isINNER_AR_CLINT) & M_CLINT_AXI_ARREADY )
					|
					( (isDM_AR_PLIC | isINNER_AR_PLIC) & M_PLIC_AXI_ARREADY )
					|
					( (isDM_AR_PERIP | isINNER_AR_PERIP) & M_PERIP_AXI_ARREADY )
					|
					( (isDM_AR_SYS | isINNER_AR_SYS) & M_SYS_AXI_ARREADY )
					|
					( (isDM_AR_MEM | isCACHE_AR_MEM | isINNER_AR_MEM) & M_MEM_AXI_ARREADY );



	assign RID = 
		({8{isDM_R_ROM | isCACHE_R_ROM | isINNER_R_ROM}} & 8'b0)
		|
		({8{isDM_R_PB | isCACHE_R_PB | isINNER_R_PB}} & 8'b0)
		|
		({8{isDM_R_CLINT | isCACHE_R_CLINT | isINNER_R_CLINT}} & 8'b0)
		|
		({8{isDM_R_PLIC | isCACHE_R_PLIC | isINNER_R_PLIC}} & 8'b0)
		|
		({8{isDM_R_PERIP | isCACHE_R_PERIP | isINNER_R_PERIP}} & 8'b0)
		|
		({8{isDM_R_SYS | isCACHE_R_SYS | isINNER_R_SYS}} & M_SYS_AXI_RID)
		|
		({8{isDM_R_MEM | isCACHE_R_MEM | isINNER_R_MEM}} & M_MEM_AXI_RID);

	assign RDATA = 
		({64{isDM_R_ROM | isCACHE_R_ROM | isINNER_R_ROM}} & M_ROM_AXI_RDATA)
		|
		({64{isDM_R_PB | isCACHE_R_PB | isINNER_R_PB}} & M_PB_AXI_RDATA)
		|
		({64{isDM_R_CLINT | isCACHE_R_CLINT | isINNER_R_CLINT}} & M_CLINT_AXI_RDATA)
		|
		({64{isDM_R_PLIC | isCACHE_R_PLIC | isINNER_R_PLIC}} & M_PLIC_AXI_RDATA)
		|
		({64{isDM_R_PERIP | isCACHE_R_PERIP | isINNER_R_PERIP}} & M_PERIP_AXI_RDATA)
		|
		({64{isDM_R_SYS | isCACHE_R_SYS | isINNER_R_SYS}} & M_SYS_AXI_RDATA)
		|
		({64{isDM_R_MEM | isCACHE_R_MEM | isINNER_R_MEM}} & M_MEM_AXI_RDATA);



	assign RRESP = 
		({2{isDM_R_ROM | isCACHE_R_ROM | isINNER_R_ROM}} & M_ROM_AXI_RRESP)
		|
		({2{isDM_R_PB | isCACHE_R_PB | isINNER_R_PB}} & M_PB_AXI_RRESP)
		|
		({2{isDM_R_CLINT | isCACHE_R_CLINT | isINNER_R_CLINT}} & M_CLINT_AXI_RRESP)
		|
		({2{isDM_R_PLIC | isCACHE_R_PLIC | isINNER_R_PLIC}} & M_PLIC_AXI_RRESP)
		|
		({2{isDM_R_PERIP | isCACHE_R_PERIP | isINNER_R_PERIP}} & M_PERIP_AXI_RRESP)
		|
		({2{isDM_R_SYS | isCACHE_R_SYS | isINNER_R_SYS}} & M_SYS_AXI_RRESP)
		|
		({2{isDM_R_MEM | isCACHE_R_MEM | isINNER_R_MEM}} & M_MEM_AXI_RRESP);



	assign RLAST =
		({1{isDM_R_ROM | isCACHE_R_ROM | isINNER_R_ROM}} & 1'b1)
		|
		({1{isDM_R_PB | isCACHE_R_PB | isINNER_R_PB}} & 1'b1)
		|
		({1{isDM_R_CLINT | isCACHE_R_CLINT | isINNER_R_CLINT}} & 1'b1)
		|
		({1{isDM_R_PLIC | isCACHE_R_PLIC | isINNER_R_PLIC}} & 1'b1)
		|
		({1{isDM_R_PERIP | isCACHE_R_PERIP | isINNER_R_PERIP}} & 1'b1)
		|
		({1{isDM_R_SYS | isCACHE_R_SYS | isINNER_R_SYS}} & M_SYS_AXI_RLAST)
		|
		({1{isDM_R_MEM | isCACHE_R_MEM | isINNER_R_MEM}} & M_MEM_AXI_RLAST);


	assign RVALID = 
		M_ROM_AXI_RVALID
		| M_PB_AXI_RVALID
		| M_CLINT_AXI_RVALID
		| M_PLIC_AXI_RVALID
		| M_PERIP_AXI_RVALID
		| M_SYS_AXI_RVALID
		| M_MEM_AXI_RVALID;

	assign RREADY =
		((isDM_R_ROM | isDM_R_PB | isDM_R_CLINT | isDM_R_PLIC | isDM_R_PERIP | isDM_R_SYS | isDM_R_MEM) & S_DM_AXI_RREADY)
		|
		((isCACHE_R_ROM | isCACHE_R_PB | isCACHE_R_CLINT | isCACHE_R_PLIC | isCACHE_R_PERIP | isCACHE_R_SYS | isCACHE_R_MEM) & S_CACHE_AXI_RREADY)
		|
		((isINNER_R_ROM | isINNER_R_PB | isINNER_R_CLINT | isINNER_R_PLIC | isINNER_R_PERIP | isINNER_R_SYS | isINNER_R_MEM) & S_INNER_AXI_RREADY);






	assign S_INNER_AXI_ARREADY =
		(isINNER_AR_ROM | isINNER_AR_PB | isINNER_AR_CLINT | isINNER_AR_PLIC | isINNER_AR_PERIP | isINNER_AR_SYS | isINNER_AR_MEM)
		& ARREADY;
	assign S_INNER_AXI_RDATA = RDATA;
	assign S_INNER_AXI_RRESP = RRESP;
	assign S_INNER_AXI_RVALID = 
		(isINNER_R_ROM | isINNER_R_PB | isINNER_R_CLINT | isINNER_R_PLIC | isINNER_R_PERIP | isINNER_R_SYS | isINNER_R_MEM)
		& RVALID;


	assign S_DM_AXI_ARREADY = 
		(isDM_AR_ROM | isDM_AR_PB | isDM_AR_CLINT | isDM_AR_PLIC | isDM_AR_PERIP | isDM_AR_SYS | isDM_AR_MEM)
		 & ARREADY;
	assign S_DM_AXI_RDATA = RDATA;
	assign S_DM_AXI_RRESP = RRESP;
	assign S_DM_AXI_RVALID = 
		(isDM_R_ROM | isDM_R_PB | isDM_R_CLINT | isDM_R_PLIC | isDM_R_PERIP | isDM_R_SYS | isDM_R_MEM)
		& RVALID;


	assign S_CACHE_AXI_ARREADY = 
		(isCACHE_AR_ROM | isCACHE_AR_PB | isCACHE_AR_CLINT | isCACHE_AR_PLIC | isCACHE_AR_PERIP | isCACHE_AR_SYS | isCACHE_AR_MEM)
		 & ARREADY;
	assign S_CACHE_AXI_RID = RID;
	assign S_CACHE_AXI_RDATA = RDATA;
	assign S_CACHE_AXI_RRESP = RRESP;
	assign S_CACHE_AXI_RLAST = RLAST;
	assign S_CACHE_AXI_RVALID = 
		(isCACHE_R_ROM | isCACHE_R_PB | isCACHE_R_CLINT | isCACHE_R_PLIC | isCACHE_R_PERIP | isCACHE_R_SYS | isCACHE_R_MEM)
		 & RREADY;


	assign M_ROM_AXI_ARADDR = ARADDR;
	assign M_ROM_AXI_ARVALID =
		(isINNER_AR_ROM | isDM_AR_ROM | isCACHE_AR_ROM)
		& ARVALID;
	assign M_ROM_AXI_RREADY = 
		(isINNER_R_ROM | isDM_R_ROM | isCACHE_R_ROM)
		& RVALID;	


	assign M_PB_AXI_ARADDR = ARADDR;
	assign M_PB_AXI_ARVALID =
		(isINNER_AR_PB | isDM_AR_PB | isCACHE_AR_PB)
		& ARVALID;
	assign M_PB_AXI_RREADY = 
		(isINNER_R_PB | isDM_R_PB | isCACHE_R_PB)
		& RVALID;


	assign M_CLINT_AXI_ARADDR = ARADDR;
	assign M_CLINT_AXI_ARVALID =
		(isINNER_AR_CLINT | isDM_AR_CLINT | isCACHE_AR_CLINT)
		& ARVALID;
	assign M_CLINT_AXI_RREADY = 
		(isINNER_R_CLINT | isDM_R_CLINT | isCACHE_R_CLINT)
		& RVALID;

	assign M_PLIC_AXI_ARADDR = ARADDR;
	assign M_PLIC_AXI_ARVALID =
		(isINNER_AR_PLIC | isDM_AR_PLIC | isCACHE_AR_PLIC)
		& ARVALID;
	assign M_PLIC_AXI_RREADY = 
		(isINNER_R_PLIC | isDM_R_PLIC | isCACHE_R_PLIC)
		& RVALID;

	assign M_SYS_AXI_ARID = ARID;
	assign M_SYS_AXI_ARADDR = ARADDR;
	assign M_SYS_AXI_ARLEN = ARLEN;
	assign M_SYS_AXI_ARBURST = ARBURST;
	assign M_SYS_AXI_ARVALID =
		( isINNER_AR_SYS | isDM_AR_SYS | isCACHE_AR_SYS )
		& ARVALID;
	assign M_SYS_AXI_RREADY = 
		( isINNER_R_SYS | isDM_R_SYS | isCACHE_R_SYS )
		& RVALID;

	assign M_MEM_AXI_ARID = ARID;
	assign M_MEM_AXI_ARADDR = ARADDR;
	assign M_MEM_AXI_ARLEN = ARLEN;
	assign M_MEM_AXI_ARBURST = ARBURST;
	assign M_MEM_AXI_ARVALID =
		( isINNER_AR_MEM | isDM_AR_MEM | isCACHE_AR_MEM )
		& ARVALID;
	assign M_MEM_AXI_RREADY = 
		( isINNER_R_MEM | isDM_R_MEM | isCACHE_R_MEM )
		& RVALID;


	assign M_PERIP_AXI_ARADDR = ARADDR;
	assign M_PERIP_AXI_ARVALID =
		( isINNER_AR_PERIP | isDM_AR_PERIP | isCACHE_AR_PERIP )
		& ARVALID;
	assign M_PERIP_AXI_RREADY = 
		( isINNER_R_PERIP | isDM_R_PERIP | isCACHE_R_PERIP )
		& RVALID;

















//  ___       __   ________  ___  _________  _______      
// |\  \     |\  \|\   __  \|\  \|\___   ___\\  ___ \     
// \ \  \    \ \  \ \  \|\  \ \  \|___ \  \_\ \   __/|    
//  \ \  \  __\ \  \ \   _  _\ \  \   \ \  \ \ \  \_|/__  
//   \ \  \|\__\_\  \ \  \\  \\ \  \   \ \  \ \ \  \_|\ \ 
//    \ \____________\ \__\\ _\\ \__\   \ \__\ \ \_______\
//     \|____________|\|__|\|__|\|__|    \|__|  \|_______|







	wire [7:0] AWID;
	wire [63:0] AWADDR;
	wire [7:0] AWLEN;
	wire [1:0] AWBURST;
	wire AWVALID;
	wire AWREADY;

	wire [63:0] WDATA;
	wire [7:0] WSTRB;
	wire WLAST;
	wire WVALID;
	wire WREADY;

	wire [7:0] BID;
	wire [1:0] BRESP;
	wire BVALID;
	wire BREADY;


	wire isDM_AW_ROM, isDM_W_ROM;
	wire isCACHE_AW_ROM, isCACHE_W_ROM;
	wire isINNER_AW_ROM, isINNER_W_ROM;
	wire isDM_AW_PB, isDM_W_PB;
	wire isCACHE_AW_PB, isCACHE_W_PB;
	wire isINNER_AW_PB, isINNER_W_PB;
	wire isDM_AW_CLINT, isDM_W_CLINT;
	wire isCACHE_AW_CLINT, isCACHE_W_CLINT;
	wire isINNER_AW_CLINT, isINNER_W_CLINT;
	wire isDM_AW_PLIC, isDM_W_PLIC;
	wire isCACHE_AW_PLIC, isCACHE_W_PLIC;
	wire isINNER_AW_PLIC, isINNER_W_PLIC;
	wire isDM_AW_PERIP, isDM_W_PERIP;
	wire isCACHE_AW_PERIP, isCACHE_W_PERIP;
	wire isINNER_AW_PERIP, isINNER_W_PERIP;
	wire isDM_AW_SYS, isDM_W_SYS;
	wire isCACHE_AW_SYS, isCACHE_W_SYS;
	wire isINNER_AW_SYS, isINNER_W_SYS;
	wire isDM_AW_MEM, isDM_W_MEM;
	wire isCACHE_AW_MEM, isCACHE_W_MEM;
	wire isINNER_AW_MEM, isINNER_W_MEM;



	wire [S_NUM*M_NUM-1:0] writeMuxList_push
	wire [S_NUM*M_NUM-1:0] writeMuxList_pop;

	assign writeMuxList_push = 
							{ isDM_AW_ROM, isCACHE_AW_ROM, isINNER_AW_ROM,
							isDM_AW_PB, isCACHE_AW_PB, isINNER_AW_PB,
							isDM_AW_CLINT, isCACHE_AW_CLINT, isINNER_AW_CLINT,
							isDM_AW_PLIC, isCACHE_AW_PLIC, isINNER_AW_PLIC,
							isDM_AW_PERIP, isCACHE_AW_PERIP, isINNER_AW_PERIP,
							isDM_AW_SYS, isCACHE_AW_SYS, isINNER_AW_SYS,
							isDM_AW_MEM, isCACHE_AW_MEM, isINNER_AW_MEM };


	assign 	{ isDM_W_ROM, isCACHE_W_ROM, isINNER_W_ROM,
			isDM_W_PB, isCACHE_W_PB, isINNER_W_PB,
			isDM_W_CLINT, isCACHE_W_CLINT, isINNER_W_CLINT,
			isDM_W_PLIC, isCACHE_W_PLIC, isINNER_W_PLIC,
			isDM_W_PERIP, isCACHE_W_PERIP, isINNER_W_PERIP,
			isDM_W_SYS, isCACHE_W_SYS, isINNER_W_SYS,
			isDM_W_MEM, isCACHE_W_MEM, isINNER_W_MEM } = writeMuxList_pop;


	wire isDM_AW_ROM =  (S_DM_AXI_AWADDR[63:16] == 48'h0) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_ROM = 1'b0;
	wire isINNER_AW_ROM = (S_INNER_AXI_AWADDR[63:16] == 48'h0) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_PB =  (S_DM_AXI_AWADDR[63:16] == 48'h1) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_PB = 1'b0;
	wire isINNER_AW_PB = (S_INNER_AXI_AWADDR[63:16] == 48'h1) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_CLINT = ( S_DM_AXI_AWADDR[63:24] == 40'h2 ) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_CLINT = 1'b0;
	wire isINNER_AW_CLINT = S_INNER_AXI_AWADDR[63:24] == 40'h2 & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_PLIC = (S_DM_AXI_AWADDR[63:24] == 40'h3) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_PLIC = 1'b0;
	wire isINNER_AW_PLIC = (S_INNER_AXI_AWADDR[63:24] == 40'h3) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_PERIP = ( S_DM_AXI_AWADDR[63:28] == 36'h2 ) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_PERIP = 1'b0;
	wire isINNER_AW_PERIP = (S_INNER_AXI_AWADDR[63:28] == 36'h2 ) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_SYS = (S_DM_AXI_AWADDR[63:28] == 36'h4) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_SYS = 1'b0;
	wire isINNER_AW_SYS = (S_INNER_AXI_AWADDR[63:28] == 36'h4) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;

	wire isDM_AW_MEM = ( S_DM_AXI_AWADDR[63:31] == 33'h1 ) & S_DM_AXI_AWVALID;
	wire isCACHE_AW_MEM = ( S_DM_AXI_AWADDR[63:31] == 33'h1 ) & ~S_DM_AXI_AWVALID & S_CACHE_AXI_AWVALID;
	wire isINNER_AW_MEM = ( S_DM_AXI_AWADDR[63:31] == 33'h1 ) & ~S_DM_AXI_AWVALID & ~S_CACHE_AXI_AWVALID & S_INNER_AXI_AWVALID;



	assign AWID = S_DM_AXI_AWVALID ? 8'b0 : ( S_CACHE_AXI_AWVALID ? S_CACHE_AXI_AWID : (S_INNER_AXI_AWVALID ? 8'b0 : 8'b0) );
	assign AWADDR = S_DM_AXI_AWVALID ? S_DW_AXI_AWADDR : ( S_CACHE_AXI_AWVALID ? S_CACHE_AXI_AWADDR : (S_INNER_AXI_AWVALID ? S_INNER_AXI_AWADDR : 64'h0) );
	assign AWLEN = S_DM_AXI_AWVALID ? 8'b0 : ( S_CACHE_AXI_AWVALID ? S_CACHE_AXI_AWLEN : (S_INNER_AXI_AWVALID ? 8'b0 : 8'b0) );
	assign AWBURST = S_DM_AXI_AWVALID ? 2'b0 : ( S_CACHE_AXI_AWVALID ? S_CACHE_AXI_AWBURST : (S_INNER_AXI_AWVALID ? 2'b0 : 2'b0) );
	assign AWVALID = (~write_fifo_full) & (S_DM_AXI_AWVALID | S_CACHE_AXI_AWVALID | S_INNER_AXI_AWVALID);
	assign AWREADY =
		((isDM_AW_ROM | isINNER_AW_ROM) & M_ROM_AXI_AWREADY)
		|
		( (isDM_AW_PB | isINNER_AW_PB) & M_PB_AXI_AWREADY )
		|
		( (isDM_AW_CLINT | isINNER_AW_CLINT) & M_CLINT_AXI_AWREADY )
		|
		( (isDM_AW_PLIC | isINNER_AW_PLIC) & M_PLIC_AXI_AWREADY )
		|
		( (isDM_AW_PERIP | isINNER_AW_PERIP) & M_PERIP_AXI_AWREADY )
		|
		( (isDM_AW_SYS | isINNER_AW_SYS) & M_SYS_AXI_AWREADY )
		|
		( (isDM_AW_MEM | isCACHE_AW_MEM | isINNER_AW_MEM) & M_MEM_AXI_AWREADY );


	assign WDATA = 
		({64{isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM}} & M_ROM_AXI_WDATA)
		|
		({64{isDM_W_PB | isCACHE_W_PB | isINNER_W_PB}} & M_PB_AXI_WDATA)
		|
		({64{isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT}} & M_CLINT_AXI_WDATA)
		|
		({64{isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC}} & M_PLIC_AXI_WDATA)
		|
		({64{isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP}} & M_PERIP_AXI_WDATA)
		|
		({64{isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS}} & M_SYS_AXI_WDATA)
		|
		({64{isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM}} & M_MEM_AXI_WDATA);


	assign WSTRB = 
		({8{isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM}} & M_ROM_AXI_WSTRB)
		|
		({8{isDM_W_PB | isCACHE_W_PB | isINNER_W_PB}} & M_PB_AXI_WSTRB)
		|
		({8{isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT}} & M_CLINT_AXI_WSTRB)
		|
		({8{isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC}} & M_PLIC_AXI_WSTRB)
		|
		({8{isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP}} & M_PERIP_AXI_WSTRB)
		|
		({8{isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS}} & M_SYS_AXI_WSTRB)
		|
		({8{isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM}} & M_MEM_AXI_WSTRB);



	assign WLAST =
		({1{isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM}} & 1'b1)
		|
		({1{isDM_W_PB | isCACHE_W_PB | isINNER_W_PB}} & 1'b1)
		|
		({1{isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT}} & 1'b1)
		|
		({1{isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC}} & 1'b1)
		|
		({1{isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP}} & 1'b1)
		|
		({1{isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS}} & M_SYS_AXI_WLAST)
		|
		({1{isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM}} & M_MEM_AXI_WLAST);


	assign WVALID = S_DM_AXI_WVALID | S_CACHE_AXI_WVALID | S_INNER_AXI_WVALID;
	assign WREADY = 
		((isDM_W_ROM | isINNER_W_ROM) & M_ROM_AXI_WREADY)
		|
		( (isDM_W_PB | isINNER_W_PB) & M_PB_AXI_WREADY )
		|
		( (isDM_W_CLINT | isINNER_W_CLINT) & M_CLINT_AXI_WREADY )
		|
		( (isDM_W_PLIC | isINNER_W_PLIC) & M_PLIC_AXI_WREADY )
		|
		( (isDM_W_PERIP | isINNER_W_PERIP) & M_PERIP_AXI_WREADY )
		|
		( (isDM_W_SYS | isINNER_W_SYS) & M_SYS_AXI_WREADY )
		|
		( (isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM) & M_MEM_AXI_WREADY );
	


	assign BID = 
		({8{isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM}} & 8'b0)
		|
		({8{isDM_W_PB | isCACHE_W_PB | isINNER_W_PB}} & 8'b0)
		|
		({8{isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT}} & 8'b0)
		|
		({8{isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC}} & 8'b0)
		|
		({8{isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP}} & 8'b0)
		|
		({8{isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS}} & M_SYS_AXI_BID)
		|
		({8{isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM}} & M_MEM_AXI_BID);


	assign BRESP = 
		({2{isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM}} & M_ROM_AXI_BRESP)
		|
		({2{isDM_W_PB | isCACHE_W_PB | isINNER_W_PB}} & M_PB_AXI_BRESP)
		|
		({2{isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT}} & M_CLINT_AXI_BRESP)
		|
		({2{isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC}} & M_PLIC_AXI_BRESP)
		|
		({2{isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP}} & M_PERIP_AXI_BRESP)
		|
		({2{isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS}} & M_SYS_AXI_BRESP)
		|
		({2{isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM}} & M_MEM_AXI_BRESP);

	assign BVALID = 
		M_ROM_AXI_BVALID
		| M_PB_AXI_BVALID
		| M_CLINT_AXI_BVALID
		| M_PLIC_AXI_BVALID
		| M_PERIP_AXI_BVALID
		| M_SYS_AXI_BVALID
		| M_MEM_AXI_BVALID;

	assign BREADY =
		((isDM_W_ROM | isDM_W_PB | isDM_W_CLINT | isDM_W_PLIC | isDM_W_PERIP | isDM_W_SYS | isDM_W_MEM) & S_DM_AXI_BREADY)
		|
		((isCACHE_W_ROM | isCACHE_W_PB | isCACHE_W_CLINT | isCACHE_W_PLIC | isCACHE_W_PERIP | isCACHE_W_SYS | isCACHE_W_MEM) & S_CACHE_AXI_BREADY)
		|
		((isINNER_W_ROM | isINNER_W_PB | isINNER_W_CLINT | isINNER_W_PLIC | isINNER_W_PERIP | isINNER_W_SYS | isINNER_W_MEM) & S_INNER_AXI_BREADY);





	assign S_INNER_AXI_AWREADY =
		(isINNER_AW_ROM | isINNER_AW_PB | isINNER_AW_CLINT | isINNER_AW_PLIC | isINNER_AW_PERIP | isINNER_AW_SYS | isINNER_AW_MEM)
		& AWREADY;
	assign S_INNER_AXI_WREADY =
		(isINNER_W_ROM | isINNER_W_PB | isINNER_W_CLINT | isINNER_W_PLIC | isINNER_W_PERIP | isINNER_W_SYS | isINNER_W_MEM)
		& WREADY;
	assign S_INNER_AXI_BRESP = BRESP;
	assign S_INNER_AXI_BVALID =
		(isINNER_W_ROM | isINNER_W_PB | isINNER_W_CLINT | isINNER_W_PLIC | isINNER_W_PERIP | isINNER_W_SYS | isINNER_W_MEM)
		& BVALID;


	assign S_DM_AXI_AWREADY =
		(isDM_AW_ROM | isDM_AW_PB | isDM_AW_CLINT | isDM_AW_PLIC | isDM_AW_PERIP | isDM_AW_SYS | isDM_AW_MEM)
		& AWREADY;
	assign S_DM_AXI_WREADY =
		(isDM_W_ROM | isDM_W_PB | isDM_W_CLINT | isDM_W_PLIC | isDM_W_PERIP | isDM_W_SYS | isDM_W_MEM)
		& WREADY;
	assign S_DM_AXI_BRESP = BRESP;
	assign S_DM_AXI_BVALID =
		(isDM_W_ROM | isDM_W_PB | isDM_W_CLINT | isDM_W_PLIC | isDM_W_PERIP | isDM_W_SYS | isDM_W_MEM)
		& BREADY;


	assign S_CACHE_AXI_AWREADY =
		(isCACHE_AW_ROM | isCACHE_AW_PB | isCACHE_AW_CLINT | isCACHE_AW_PLIC | isCACHE_AW_PERIP | isCACHE_AW_SYS | isCACHE_AW_MEM)
		& AWREADY;
	assign S_CACHE_AXI_WREADY =
		(isCACHE_W_ROM | isCACHE_W_PB | isCACHE_W_CLINT | isCACHE_W_PLIC | isCACHE_W_PERIP | isCACHE_W_SYS | isCACHE_W_MEM)
		& WREADY;
	assign S_CACHE_AXI_BID = BID;
	assign S_CACHE_AXI_BRESP = BRESP;
	assign S_CACHE_AXI_BVALID =
		(isCACHE_W_ROM | isCACHE_W_PB | isCACHE_W_CLINT | isCACHE_W_PLIC | isCACHE_W_PERIP | isCACHE_W_SYS | isCACHE_W_MEM)
		& BREADY;



	assign M_ROM_AXI_AWADDR = AWADDR;
	assign M_ROM_AXI_AWVALID =
		(isDM_AW_ROM | isCACHE_AW_ROM | isINNER_AW_ROM) & AWVALID;
	assign M_ROM_AXI_WDATA = WDATA;
	assign M_ROM_AXI_WSTRB = WSTRB;
	assign M_ROM_AXI_WVALID = 
		(isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM) & WVALID;
	assign M_ROM_AXI_BREADY = 
		(isDM_W_ROM | isCACHE_W_ROM | isINNER_W_ROM) & BVALID;



	assign M_PB_AXI_AWADDR = AWADDR;
	assign M_PB_AXI_AWVALID =
		(isDM_AW_PB | isCACHE_AW_PB | isINNER_AW_PB) & AWVALID;
	assign M_PB_AXI_WDATA = WDATA;
	assign M_PB_AXI_WSTRB = WSTRB;
	assign M_PB_AXI_WVALID = 
		(isDM_W_PB | isCACHE_W_PB | isINNER_W_PB) & WVALID;
	assign M_PB_AXI_BREADY = 
		(isDM_W_PB | isCACHE_W_PB | isINNER_W_PB) & BVALID;



	assign M_CLINT_AXI_AWADDR = AWADDR;
	assign M_CLINT_AXI_AWVALID =
		(isDM_AW_CLINT | isCACHE_AW_CLINT | isINNER_AW_CLINT) & AWVALID;
	assign M_CLINT_AXI_WDATA = WDATA;
	assign M_CLINT_AXI_WSTRB = WSTRB;
	assign M_CLINT_AXI_WVALID = 
		(isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT) & WVALID;
	assign M_CLINT_AXI_BREADY = 
		(isDM_W_CLINT | isCACHE_W_CLINT | isINNER_W_CLINT) & BVALID;



	assign M_PLIC_AXI_AWADDR = AWADDR;
	assign M_PLIC_AXI_AWVALID =
		(isDM_AW_PLIC | isCACHE_AW_PLIC | isINNER_AW_PLIC) & AWVALID;
	assign M_PLIC_AXI_WDATA = WDATA;
	assign M_PLIC_AXI_WSTRB = WSTRB;
	assign M_PLIC_AXI_WVALID = 
		(isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC) & WVALID;
	assign M_PLIC_AXI_BREADY = 
		(isDM_W_PLIC | isCACHE_W_PLIC | isINNER_W_PLIC) & BVALID;



	assign M_SYS_AXI_AWID = AWID;
	assign M_SYS_AXI_AWADDR = AWADDR;
	assign M_SYS_AXI_AWLEN = AWLEN;
	assign M_SYS_AXI_AWBURST = AWBURST;
	assign M_SYS_AXI_AWVALID =
		(isDM_AW_SYS | isCACHE_AW_SYS | isINNER_AW_SYS) & AWVALID;
	assign M_SYS_AXI_WDATA = WDATA;
	assign M_SYS_AXI_WSTRB = WSTRB;
	assign M_SYS_AXI_WLAST = WLAST;
	assign M_SYS_AXI_WVALID = 
		(isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS) & WVALID;
	assign M_SYS_AXI_BREADY = 
		(isDM_W_SYS | isCACHE_W_SYS | isINNER_W_SYS) & BVALID;



	assign M_MEM_AXI_AWID = AWID;
	assign M_MEM_AXI_AWADDR = AWADDR;
	assign M_MEM_AXI_AWLEN = AWLEN;
	assign M_MEM_AXI_AWBURST = AWBURST;
	assign M_MEM_AXI_AWVALID =
		(isDM_AW_MEM | isCACHE_AW_MEM | isINNER_AW_MEM) & AWVALID;
	assign M_MEM_AXI_WDATA = WDATA;
	assign M_MEM_AXI_WSTRB = WSTRB;
	assign M_MEM_AXI_WLAST = WLAST;
	assign M_MEM_AXI_WVALID = 
		(isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM) & WVALID;
	assign M_MEM_AXI_BREADY = 
		(isDM_W_MEM | isCACHE_W_MEM | isINNER_W_MEM) & BVALID;



	assign M_PERIP_AXI_AWADDR = AWADDR;
	assign M_PERIP_AXI_AWVALID =
		(isDM_AW_PERIP | isCACHE_AW_PERIP | isINNER_AW_PERIP) & AWVALID;
	assign M_PERIP_AXI_WDATA = WDATA;
	assign M_PERIP_AXI_WSTRB = WSTRB;
	assign M_PERIP_AXI_WVALID = 
		(isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP) & WVALID;
	assign M_PERIP_AXI_BREADY = 
		(isDM_W_PERIP | isCACHE_W_PERIP | isINNER_W_PERIP) & BVALID;
















	wire isDM_AR_ROM =  (S_DM_AXI_ARADDR[63:16] == 48'h0) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_ROM = 1'b0;
	wire isINNER_AR_ROM = (S_INNER_AXI_ARADDR[63:16] == 48'h0) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PB =  (S_DM_AXI_ARADDR[63:16] == 48'h1) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PB = 1'b0;
	wire isINNER_AR_PB = (S_INNER_AXI_ARADDR[63:16] == 48'h1) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_CLINT = ( S_DM_AXI_ARADDR[63:24] == 40'h2 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_CLINT = 1'b0;
	wire isINNER_AR_CLINT = S_INNER_AXI_ARADDR[63:24] == 40'h2 & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PLIC = (S_DM_AXI_ARADDR[63:24] == 40'h3) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PLIC = 1'b0;
	wire isINNER_AR_PLIC = (S_INNER_AXI_ARADDR[63:24] == 40'h3) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_PERIP = ( S_DM_AXI_ARADDR[63:28] == 36'h2 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_PERIP = 1'b0;
	wire isINNER_AR_PERIP = (S_INNER_AXI_ARADDR[63:28] == 36'h2 ) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_SYS = (S_DM_AXI_ARADDR[63:28] == 36'h4) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_SYS = 1'b0;
	wire isINNER_AR_SYS = (S_INNER_AXI_ARADDR[63:28] == 36'h4) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;

	wire isDM_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & S_DM_AXI_ARVALID;
	wire isCACHE_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & ~S_DM_AXI_ARVALID & S_CACHE_AXI_ARVALID;
	wire isINNER_AR_MEM = ( S_DM_AXI_ARADDR[63:31] == 33'h1 ) & ~S_DM_AXI_ARVALID & ~S_CACHE_AXI_ARVALID & S_INNER_AXI_ARVALID;











wire access_error =
	(S_DM_AXI_ARVALID | S_CACHE_AXI_ARVALID | S_INNER_AXI_ARVALID)
	& ( ~(isDM_AR_ROM | isCACHE_AR_ROM | isINNER_AR_ROM
			| ) )

	| isDM_AR_PB | isCACHE_AR_PB | isINNER_AR_PB
	| isDM_AR_CLINT | isCACHE_AR_CLINT | isINNER_AR_CLINT 
	| isDM_AR_PLIC | isCACHE_AR_PLIC | isINNER_AR_PLIC
	| isDM_AR_PERIP | isCACHE_AR_PERIP | isINNER_AR_PERIP
	| isDM_AR_SYS | isCACHE_AR_SYS | isINNER_AR_SYS
	| isDM_AR_MEM | isCACHE_AR_MEM | isINNER_AR_MEM






assign systemBusError = | ;





gen_fifo #( .DW(M_NUM*S_NUM), .AW(4) ) read_req
(
	.fifo_pop(RLAST & RREADY), 
	.fifo_push(ARVALID),
	.data_push(readMuxList_push),

	.fifo_empty(), 
	.fifo_full(read_fifo_full), 
	.data_pop(readMuxList_pop),

	.flush(systemBusError),
	.CLK(CLK),
	.RSTn(RSTn)
);




gen_fifo # ( .DW(M_NUM*S_NUM), .AW(4) ) write_req
(
	.fifo_pop(BREADY), 
	.fifo_push(AWVALID),
	.data_push(writeMuxList_push),

	.fifo_empty(), 
	.fifo_full(write_fifo_full), 
	.data_pop(writeMuxList_pop),

	.flush(systemBusError),
	.CLK(CLK),
	.RSTn(RSTn)
);
























endmodule







