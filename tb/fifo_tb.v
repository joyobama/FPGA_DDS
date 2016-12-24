`timescale 1ns/1ps
module fifo_tb;
	reg clk,write_clk,read_clk;
	wire read_done,write_done;
	reg [8:0] write_conter;
	reg [7:0] write_data;
	wire [7:0] read_data;
	

	initial begin
		clk = 0;
		write_conter = 0;
		read_clk = 0;
		write_data = {$random}%256;
		write_clk = 0;
		#37 read_clk = 1;
		#7 read_clk = 0;
		#40 write_clk = 1;
		#5  write_clk = 0;
		#79 read_clk = 1;
		#8 read_clk = 0;
		write_data = {$random}%256;
		#69 write_clk = 1;
	end
	always #10 clk=~clk;
	
	fifo m1(clk,read_clk,write_clk,write_data,read_done,write_done,read_data);
endmodule