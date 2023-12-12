//`include "define.sv"
module Controller (
    input [4:0] opcode,
    input [2:0] func3,
    input       func7,
    input       alu_branch,
    output next_pc_sel,
    output [3:0]im_w_en, 
    output reg [3:0] dm_w_en,
    output reg wb_en,
    output jb_src1_sel,
    output reg alu_src1_sel, alu_src2_sel,
    output wb_sel,
    output ecall_sig
);
assign ecall_sig = (opcode == `ECALL) ? 1'b1 : 1'b0;

assign next_pc_sel = ((alu_branch && opcode == `BRANCH)|| opcode == `JALR || opcode == `JAL) ? 1'b1 : 1'b0;     //branch is 1

assign im_w_en = 1'b0;  //only read

always @(*) begin
    case (opcode)
        `STORE : begin 
            case (func3)
                3'b000 : dm_w_en = 4'b0001; //SB
                3'b001 : dm_w_en = 4'b0011; //SH
                3'b010 : dm_w_en = 4'b1111; //SW
                default : dm_w_en = 4'b0000;
            endcase
        end
        default : dm_w_en = 4'b000;
    endcase
end

always @(*) begin
    case (opcode)
        `R_R : wb_en = 1'b1; //R_type
        `R_I : wb_en = 1'b1;  //I_Type
        `LOAD : wb_en = 1'b1;  //I_Type
        `JALR : wb_en = 1'b1;  //I_Type
        `LUI : wb_en = 1'b1;    //U_Type
        `AUIPC : wb_en = 1'b1;    //U_Type
        `JAL : wb_en = 1'b1;   //J_Type
        default : wb_en = 1'b0; //else 0
    endcase
end

assign jb_src1_sel = (opcode == `JALR) ? 1'b1 : 1'b0;   // 1:rs1 0:imm

always @(*) begin
    case(opcode)
        `AUIPC  : alu_src1_sel = 1'b1;
        `JAL    : alu_src1_sel = 1'b1;
        `JALR   : alu_src1_sel = 1'b1;
        default : alu_src1_sel = 1'b0;      // 1:pc, 0:rs1
    endcase
end

always @(*) begin
    case(opcode)
        `R_R    : alu_src2_sel = 1'b1;
        `BRANCH : alu_src2_sel = 1'b1;
        default : alu_src2_sel = 1'b0;      // 1:rs2, 0:imm
    endcase
end

assign wb_sel = (opcode == `LOAD) ? 1'b1 : 1'b0;
                                                     


endmodule