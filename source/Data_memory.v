module data_mod(data_address,clk,write_data, Read_data, MemRead, MemWrite);
    input [31:0] data_address, write_data;
    input MemRead,MemWrite,clk;
    output reg [31:0] Read_data;


    reg [31:0] mem [0:63];
    initial $readmemh("dmem.hex", mem);
    always@(*) begin 
        Read_data = 32'b0;
        if(MemRead)
            Read_data = mem[data_address];
    end

    always@(posedge clk) begin 
        if(MemWrite)
            mem[data_address] <= write_data;
    end
endmodule