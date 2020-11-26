/*
* @File name: reset_halt_control
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:35:49
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-26 17:37:26
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

module reset_halt_control #
(
	parameter MAXHART = 1
	
)
	(

);











	wire [9:0] hartsello_dnxt = 10'd0;
	wire [9:0] hartsello_qout;

	wire [9:0] hartselhi_dnxt = 10'd0;
	wire [9:0] hartselhi_qout;

	wire hasel = 1'b0;

	
	wire haltreq;

















endmodule

