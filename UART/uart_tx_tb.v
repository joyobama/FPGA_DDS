`timescale 1ns / 1ps

module uart_tx_tb(bclk,rst,txd);
	
	output bclk,rst,txd;
	reg [7:0] din;
	reg tx_cmd;
	reg sys_clk;
	reg rst;
	reg bclk;
	wire txd;
	wire tx_ready;

	// Instantiate the Unit Under Test (UUT)
	uart_tx uut (bclk, rst, din, tx_cmd, tx_ready, txd);

	initial begin
		// Initialize Inputs
		din = 0;
		tx_cmd = 0;
		rst = 0;
		bclk = 0;

		// Wait 100 ns for global rst to finish
		#100; 
      rst = 1;
      #200;
      din = 8'b0110_0101;
		tx_cmd = 1;	
      		
		// Add stimulus here
	end
	
	always #3255 bclk = !bclk;
	 
	
      
endmodule

