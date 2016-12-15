module ROM_behavior(clk,addr,dout);
  input clk;
  input [7:0] addr;
  output [7:0] dout;
  reg[7:0] dout,rom[255:0];
  always@(posedge clk)
    dout <= rom[addr];
  /**---------**/
//  initial begin
//    rom[0] = {$random}%64;
//    rom[1] = {$random}%256;
//    rom[2] = {$random}%256;
//    rom[3] = {$random}%256;
//    rom[4] = {$random}%256;
//  end
endmodule