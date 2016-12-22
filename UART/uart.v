module uart(clk,rst,tx_start,rx_done,tx_done,rx_data,tx_data,RX,TX);
	input clk,rst,tx_start,RX;
	input[7:0] tx_data;
	output rx_done,tx_done,TX;
	output[7:0] rx_data;
	
	(*KEEP="TRUE"*)wire          bclk;
	(*KEEP="TRUE"*)half_int_div  m1(clk,rst,bclk);
	(*KEEP="TRUE"*)uart_tx       m2(bclk,rst,tx_data,tx_start,tx_done,TX);
	(*KEEP="TRUE"*)uart_rx		 m3(bclk,rst,RX,rx_done,rx_data);
endmodule
	