/**
*   x100_0001  master_rest
*   x100_001x  delay
*   x100_01x?  enable auto DRCTL flip when posedge DROVER
*   x100_1???  set OSK,DRHOLD,DRCTL
*/
moudle controller(clk,rst,MREST,DRCTL,DRHOLD,DROVER,OSK);
  input clk,rst,DROVER;
  output DRCTL,DRHOLD,OSK,MREST;
  parameter N = 2;
  reg DRHOLE,OSK;
  /******/
  reg[N-1:0] DRCTL_DELAY_REG;   //N = 1 ~ 5  ?DRCTL??N?clk???
  reg busy,wr_start,auto_flip_en,con_drctl;
  reg[7:0] PC,order;
  reg[31:0] data; 
  reg[7:0] counter;
  wire wr_done;
  /**********/
  assign DRCTL = (auto_flip_en & DRCTL_DELAY_REG[0]) | (~auto_flip_en & con_drctl);
  always@(posedge clk or posedge DROVER)
    if(DROVER)
      DRCTL_DELAY_REG <= {DRCTL_DELAY_REG,~DRCTL_DELAY_REG[N-1]};
    else
      DRCTL_DELAY_REG <= 0;
  /**********/
  /****/
  always@(posedge clk or posedge rst)
    if(rst) begin
      busy <= 0;
      PC <= 8'd0;
      MREST <= 0;
      auto_flip_en <= 0;
      DRHOLD <= 0;
    end
    else if(~busy) begin
      /*****read ROM **/
      wr_start <= 0;
      order <= 
      busy <= 1;
      counter <= 0;
      PC <= PC+1;
    end
    else begin
      counter <= {counter[6:0],1'b1};
      case(order)
        8'bx0xx_xxxx: 
          case(counter)
            8'b0000_0xxx: begin
                data <= {data[23:0],8'b--ROM--};
                PC <= PC+1;
              end
            8'b000_1111:
              wr_start <= 1;
            default: begin
              wr_start <= 0;
              if(wr_done) busy <= 0;
            end
          endcase
        8'bx100_0001: 
          if(counter == 8'd0)
            MREST <= 1;
          else begin
            MREST <= 0;
            busy <= 0;
          end
        8'bx100_001x:
          case(counter)
            8'b0000_000x: begin
              data <= {data[23:0],8'b--ROM--};
              PC <= PC+1;
            end
            default: begin
              data <= data + 32'hffff_ffff;     //data = data -1;
              if(data == 32'd0) busy <= 0;
            end
          endcase
        8'bx100_01xx: begin
          auto_flip_en <= order[0];
          busy <= 0;
        end
        8'bx100_1xxx: begin
          {OSK,DRHOLE,con_drctl} <= order[2:0];
          busy <= 0;
        end
        default: begin
          PC <= PC + 8'hff;  //PC = PC -1;
          busy <= 0;
        end
      endcase
    end
    
  
  
