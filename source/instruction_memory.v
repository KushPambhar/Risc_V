module inst_mem(address, instruction_out);
    input [31:0] address;
    output wire [31:0] instruction_out;
    reg [7:0] mem [0:1023];
    
    initial $readmemh("imem.hex",mem);
    
    assign instruction_out[7:0]=mem[address[9:0]];
    assign instruction_out[15:8]=mem[address[9:0]+1];
    assign instruction_out[23:16]=mem[address[9:0]+2];
    assign instruction_out[31:24]=mem[address[9:0]+3];


endmodule
