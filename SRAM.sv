module SRAM (
input clk,
input [3:0] w_en,
input [15:0] address,
input [31:0] write_data,
output [31:0] read_data
);
logic [7:0] mem [0:65535];
//reg [7:0] mem [0:16384];
//Write
always@(negedge clk) begin
    if(w_en[0]) 
        mem[address] <= write_data[7:0];
    if(w_en[1])
        mem[address+16'd1] <= write_data[15:8];
    if(w_en[2])
        mem[address+16'd2] <= write_data[23:16];
    if(w_en[3])
        mem[address+16'd3] <= write_data[31:24];
end

//Read
assign read_data[7:0] = mem[address];
assign read_data[15:8] = mem[address+16'd1];
assign read_data[23:16] = mem[address+16'd2];
assign read_data[31:24] = mem[address+16'd3];

endmodule