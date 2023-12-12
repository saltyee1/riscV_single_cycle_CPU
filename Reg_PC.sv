module Reg_PC (
input clk,
input reset,
input [31:0] next_pc,
output reg [31:0] current_pc
);
always @(posedge clk or negedge reset) begin
    if(!reset)
        current_pc <= 32'd0;
    else
        current_pc <= next_pc;
end
endmodule