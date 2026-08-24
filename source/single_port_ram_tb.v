

module ram_tb;

reg clk;
reg rw;
reg enable;
reg [2:0] address;
reg [7:0] data_in;
wire [7:0] data_out;

ram uut (
.clk(clk),
.address(address),
.rw(rw),
.data_in(data_in),
.data_out(data_out),
.enable(enable)
);


initial begin
clk = 0;
forever #5 clk = ~clk;
end


initial begin
$dumpfile("ram.vcd");
$dumpvars(0, ram_tb);
end


initial 
    begin
        enable = 1;

        rw = 1;
        address = 3'b000; data_in = 8'hA1;
        #10;
        address = 3'b001; data_in = 8'hB2;
        #10;
        address = 3'b010; data_in = 8'hC3;
        #10;

        rw = 0;
        address = 3'b000;
        #10;
        address = 3'b001;
        #10;
        address = 3'b010;
        #10;

        #20 $finish;


    end

endmodule
