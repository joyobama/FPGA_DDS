`timescale 1ns / 1ps

module uart_tx_tb;

	// Inputs
	reg [7:0] din;
	reg tx_cmd;
	reg sys_clk;
	reg reset;
	reg bclk;

	// Outputs
	wire txd;
	wire tx_ready;

	// Instantiate the Unit Under Test (UUT)
	uart_tx uut (bclk, reset, din, tx_cmd, tx_ready, txd);

	initial begin
		// Initialize Inputs
		din = 0;
		tx_cmd = 0;
		reset = 0;
		bclk = 0;

		// Wait 100 ns for global reset to finish
		#100; 
      reset = 1;
      #200;
      din = 8'b0110_0101;
		tx_cmd = 1;	
      		
		// Add stimulus here
	end
	
	always #3255 bclk = !bclk;
	 
	
      
endmodule

