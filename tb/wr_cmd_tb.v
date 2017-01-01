/* charset = ascii */
`timescale 1ns / 1ps
module cmd_write_tb;
  // input 
  reg clk,start,rst;
  reg[7:0] addr;
  reg[31:0] din;
  // output
  wire done,SCLK,CS,SYNCIO,SDIO;
  wire[1:0] state;
  wr_cmd m1(
  .clk(clk),
  .start(start),
  .addr(addr),
  .din(din),
  .done(done),
  .SCLK(SCLK),.SDIO(SDIO),.SYNCIO(SYNCIO),.CS(CS));
  
  initial begin
    clk = 0;
    start = 0;
    rst = 0;
    addr = {$random}%256;
    din = {$random};
    #100 start = 1;
    #101 start = 0;
  end
  
  always #10 clk = ~clk;
endmodule