module GDC(clk,rst,RX,TX,SYNCIO,SDIO,SDO,SCLK,CS,IO_UPDATE,DROVER,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR);
	input clk,rst,RX,SDO,DROVER;
	output TX,SYNCIO,SDIO,SCLK,CS,IO_UPDATE,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR;
	(*KEEP="TRUE"*)wire wr_start,wr_done;
	(*KEEP="TRUE"*)wire[7:0] mem_din,mem_dout,wr_addr,fw_dout,fr_din;
	(*KEEP="TRUE"*)wire[31:0] wr_din,wr_dout;
	(*KEEP="TRUE"*)wr_cmd wr_cmd_module(wr_start,clk,wr_addr,wr_din,wr_dout,wr_done,SYNCIO,SDIO,SDO,SCLK,CS);
	(*KEEP="TRUE"*)wire mem_rclk,mem_wclk,mem_done;
	
	(*KEEP="TRUE"*)controller controller_module(clk,rst,DROVER,
								DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR,IO_UPDATE,	
								wr_start,wr_addr,wr_din,wr_done,wr_dout,				
								mem_dout,mem_din,mem_rclk,mem_wclk,mem_done);
	(*KEEP="TRUE"*)wire fr_write_clk,fr_read_done,fr_write_done,fw_read_done,fw_write_done,fw_read_clk;
	assign mem_done = fr_read_done & fw_write_done;
	(*KEEP="TRUE"*)fifo fr(clk,mem_rclk,fr_write_clk,fr_din,fr_read_done,fr_write_done,mem_dout);
	(*KEEP="TRUE"*)fifo fw(clk,fw_read_clk,mem_wclk,mem_din,fw_read_done,fw_write_done,fw_dout);
	(*KEEP="TRUE"*)uart uart_module(clk,rst,fw_read_done,fr_write_clk,fw_read_clk,fr_din,fw_dout,RX,TX);
endmodule