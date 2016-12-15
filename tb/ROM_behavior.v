module ROM_behavior(clk,addr,dout);
  input clk;
  input [7:0] addr;
  output [7:0] dout;
  reg[7:0] dout,rom[0:255];
  always@(posedge clk)
    dout <= rom[addr];
  /**---------**/
  initial begin
   rom[0] = 8'b00_100101;
   rom[1] = 123;
   rom[2] = 34;
   rom[3] = 38;
   rom[4] = 78;
  end
endmodule