//`include "define.sv"
module JB_Unit(
    input [4:0] opcode,
    input [31:0] JB_src1,
    input [31:0] JB_src2,
    output reg [31:0] JB_out
);
always @(*) begin
    case(opcode)
        `JAL   : JB_out = JB_src1 + JB_src2;   //pc + imm
        `JALR   : JB_out = ((JB_src1 + JB_src2) & (~32'd1));   //(rs1+imm) last bit = 0
        `BRANCH : JB_out = JB_src1 + JB_src2;  //pc + imm
        default JB_out = 32'b0;
    endcase
end
endmodule