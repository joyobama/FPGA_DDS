`timescale 1ns/1ps
module controller_tb;
	reg clk,rst,DROVER,write_clk;
	reg[7:0] write_data;
	wire DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,wr_start,wr_done,mem_rclk,mem_wclk,mem_done;
	wire[7:0] wr_addr,mem_out,mem_in;
	wire[31:0] wr_data,wr_out;
	controller m1(clk,rst,
				DROVER,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,
				wr_start,wr_addr,wr_data,wr_done,wr_out,
				mem_out,mem_in,mem_rclk,mem_wclk,mem_done);
	fifo m2(clk,mem_rclk,write_clk,write_data,mem_done,write_done,mem_out);
	/** **/
	reg[8:0] wcnt = 0;
	always@(posedge write_done)
		wcnt <= wcnt+1;
	always #10 clk = ~clk;
	
	initial begin
		clk = 0;
		rst = 1;
		write_clk = 0;
		write_data = 8'b0100_0011;
		#76 write_clk = 1;
		#19 write_clk = 0;
		write_data = 0;
		#76 write_clk = 1;
		#19 write_clk = 0;
		write_data = 200;
		#70 write_clk = 1;
	end
endmodule
		