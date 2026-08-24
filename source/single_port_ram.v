// Code your design here
module ram(clk, address, rw , data_in , data_out , enable);
    input clk,rw,enable;
    input [2:0] address;
    input [7:0] data_in;
    output reg[7:0] data_out;

    reg [7:0] mem  [7:0];

  always@(posedge clk) begin 
        if(enable) begin 
            if(rw) begin 
                data_out[7:0]<=mem[address][7:0];
            end
            else begin 
                mem[address][7:0] <= data_in[7:0];
                data_out<= 8'bxxxxxxxx;
            end
        end
        else
            data_out<= 8'bxxxxxxxx;
    end
endmodule