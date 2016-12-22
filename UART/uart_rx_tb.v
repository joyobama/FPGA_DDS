/** charset = ascii **/
`timescale 1ns / 1ps
module uart_rx_tb;
	wire bclk,rst,RX;
	wire rx_done,rx_dout;
	uart_rx m1(bclk,rst,RX,rx_done,rx_dout);
	uart_tx_tb m2(bclk,rst,RX);
endmodule