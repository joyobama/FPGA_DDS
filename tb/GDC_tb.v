`timescale 1ns / 1ps
module GDC_tb;
	reg clk = 0;
	reg rst = 0;
	reg SDO = 0;
	reg SYNC_CLK = 0;
	reg uart_en = 0;
	wire RX,TX,SYNCIO,SDIO,SCLK,CS,IO_UPDATE,DROVER,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR,rx_done,tx_done;
	wire[7:0] rx_data;
	always #10 clk = ~clk;
	always@(negedge clk)
		SDO <= {$random}%2;
	always #({$random}%10+5) SYNC_CLK <= ~SYNC_CLK;
	
	parameter N = 1;
	reg tx_start = 0;
	reg[3:0] rx_cnt = 0;
	reg[3:0] tx_cnt = 0;
	reg[7:0] tx_data;
	reg[7:0] rx_datas[0:16];
	reg[7:0] tx_datas[0:16];
	
	initial begin
		tx_datas[0] = 8'b1000_0000;
		#5 rst = 1;
		uart_en = 1;
	end
	
	always@(posedge rx_done)
		if(uart_en) begin
			rx_datas[rx_cnt] <= rx_data;
			rx_cnt <= rx_cnt+1;
		end
		
	always@(negedge tx_done)
		tx_cnt <= tx_cnt+1;
		
		
	always@(posedge clk)
	begin
		tx_data <= tx_datas[tx_cnt];
		if(uart_en) 
			if(tx_cnt<N)
				tx_start <= 1;
			else
				tx_start <= 0;
	end
	GDC m1(clk,rst,ut_TX,ut_RX,SYNCIO,SDIO,SDO,SCLK,CS,IO_UPDATE,SYNC_CLK,DROVER,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR);
	uart m2(clk,rst,tx_start,rx_done,tx_done,rx_data,tx_data,ut_RX,ut_TX);
endmodule		
			
	