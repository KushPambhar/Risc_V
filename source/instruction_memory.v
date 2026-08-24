module inst_mem(address, instruction_out);
    input [31:0] address;
    output wire [31:0] instruction_out;
    reg [31:0] mem [0:63];
    
    initial $readmemh("imem.hex",mem);
    assign instruction_out=mem[address[31:0]];


endmodule