/* charset = ascii */
`timescale 1ns / 1ps
module cmd_write_tb;
  // input 
  reg clk,start,rst,SYNC_CLK;
  reg[7:0] addr;
  reg[31:0] din;
  // output
  wire done,SCLK,CS,SYNCIO,SDIO,IO_UPDATE;
  wr_cmd m1(
  .clk(clk),
  .rst(rst),
  .start(start),
  .SYNC_CLK(SYNC_CLK),
  .addr(addr),
  .din(din),
  .done(done),
  .SCLK(SCLK),.SDIO(SDIO),.SYNCIO(SYNCIO),.CS(CS),
  .IO_UPDATE(IO_UPDATE));
  
  initial begin
    clk = 0;
    start = 0;
    rst = 0;
    SYNC_CLK = 0;
    addr = {$random}%256;
    din = {$random};
    #100 start = 1;
    #101 start = 0;
  end
  
  always #({$random}%15+3) SYNC_CLK = ~SYNC_CLK;
  always #5 clk = ~clk;
endmodule