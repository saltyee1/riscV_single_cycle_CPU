
//`include "define.sv"
module Imm_Ext (
input [31:0] inst,
output reg [31:0] imm_ext_out
);
always@(*) begin
    case(inst[6:2])
        `R_R : imm_ext_out = 32'b0; //{27'b0, inst[24:20]};   //R_Type for shamt
        `R_I : imm_ext_out = {{20{inst[31]}}, inst[31:20]};  //I_Type
        `LOAD : imm_ext_out = {{20{inst[31]}}, inst[31:20]};  //I_Type
        `JALR : imm_ext_out = {{20{inst[31]}}, inst[31:20]};  //I_Type
        `STORE : imm_ext_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};    //S_Type
        `BRANCH : imm_ext_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8] , 1'b0};    //B_Type
        `LUI : imm_ext_out = {inst[31:12], 12'b0};    //U_Type
        `AUIPC : imm_ext_out = {inst[31:12], 12'b0};    //U_Type
        `JAL : imm_ext_out = {{12{inst[31]}}, inst[19:12] , inst[20] , inst[30:21] , 1'b0};   //J_Type
        default : imm_ext_out = 32'b0;
    endcase 
end
endmodule