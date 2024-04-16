module uart 
  #(clk_freq = 100000,
    baud_rate = 9600)
  (input            clk, rst, send, rx,
   input      [7:0] tx_data,
   output reg       donetx, tx,
   output reg [7:0] rx_data,
   output           done
  );
  
  
  uarttx #(.clk_freq(clk_freq), .baud_rate(baud_rate)) uut
          (.clk(clk), .rst(rst), .send(send), .tx_data(tx_data),
            .donetx(donetx), .tx(tx));
           
           
  uartrx #(.clk_freq(clk_freq), .baud_rate(baud_rate)) uut
          (.clk(clk), .rst(rst), .rx(rx), .rx_data(rx_data),
            .done(done));
           
           
endmodule












module uarttx 
  #(clk_freq = 100000,
    baud_rate = 9600)
  (input            clk, rst, send,
   input      [7:0] tx_data, 
   output reg       donetx, 
   output reg       tx);
  
  localparam clk_count = clk_freq / baud_rate;
  integer count = 0;
  integer counts = 0;
  reg uclk = 0;
  
  
  enum bit [1:0] {idle = 2'b00, start = 2'b01, transfer = 2'b10, done = 2'b11} state;
  always @(posedge clk)
    begin
      if (count < clk_count/2)
        count = count + 1;
      else
        begin
          count = 0;
          uclk = ~uclk;
        end
        
    end
  
  reg [7:0] din;
  
  always @(posedge uclk)
    begin
      case (state)
        idle : begin
          count = 0;
          counts = 0;
          donetx <= 0;
          tx <= 1'b1;
          
          if (send)
            begin
              state <= transfer;
              din <= tx_data;
              tx <= 1'b0;
            end
          else
            state <= idle;
        end
        
        transfer: begin
          if (counts <= 7)
            begin
              counts = counts + 1;
              tx <= din[counts];
              state <= transfer;
            end
          else
            begin
              counts = 0;
              tx <= 1'b1;
              donetx <= 1'b1;
              state <= idle;
              
            end
        end
        
        default: state <= idle;
      endcase
    end
  
  
  
  
endmodule


module uartrx 
  #(clk_freq = 100000,
    baud_rate = 9600)
  (input            clk, rst, rx,
   output reg [7:0] rx_data,
   output reg       done
  );
  
  localparam clk_count = clk_freq / baud_rate;
  integer count = 0;
  integer counts = 0;
  reg uclk = 0;
  
  enum bit [1:0] {idle = 2'b00, start = 2'b01} state;
  always @(posedge clk)
    begin
      if (count < clk_count/2)
        count <= count + 1;
      else
        begin
          count <= 0;
          uclk <= ~uclk;
        end
        
    end
  
  
  always @(posedge uclk)
    begin
      if (rst)
        begin
          rx_data <= 8'h00;
          done <= 1'b0;
          counts <= 0;
        end
      else
        begin
          case (state)
            idle: begin
              rx_data <= 8'h00;
              done <= 1'b0;
              counts<=0;
              if (rx == 1'b0)
                begin
                  state <= start;
                end
              else
                state <= idle;
            end
            
            start: begin
              if (counts <= 7) begin
                counts <= count + 1;
                rx_data <= {rx, rx_data[7:1]};
              end
              else begin
                counts <= 0;
                done <= 1'b1;
                state <= idle;
              end
                
                  
            end
            
            default: state <= idle;
          endcase
        end
    end
  
  
  
  
  
endmodule
