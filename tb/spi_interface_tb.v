/* charset = ascii */
`timescale 1ns / 1ps
module spi_write_tb;
	reg clk;
	reg [7:0] send_data;
	reg start;
	wire SCLK;
	wire MOSI;
	wire CS;
	// Instantiate the Unit Under Test (UUT)
	spi_interface uut (
		.clk(clk), 
		.in(send_data), 
		.start(start), 
		.SCLK(SCLK), 
		.MOSI(MOSI),
		.CS(CS)
	);

	initial begin
		clk = 0;
		send_data = 8'b1001_0011;
		start = 0;
		#100;
      start = 1;
		#50
		start = 0;
	end
	always #5 clk = ~clk;
endmodule
module spi_read_tb;
	reg clk;
	reg [7:0] slaver_data;
	reg start;
	wire [7:0] read_data;
	wire SCLK;
	wire CS;
	// Instantiate the Unit Under Test (UUT)
	spi_interface uut (
		.clk(clk), 
		.start(start), 
		.SCLK(SCLK), 
		.MISO(slaver_data[7]),
		.CS(CS),
		.out(read_data)
	);

	initial begin
		clk = 0;
		start = 0;
		#100;
      start = 1;
		slaver_data = {$random}%256;
		#50
		start = 0;
	end
	always #5 clk = ~clk;
	// slaver behavior
	always @(negedge SCLK)
		if(~CS)
			slaver_data <= {slaver_data[6:0],1'b0};
	
endmodule
