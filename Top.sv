/*`include "define.sv"
`include "ALU.sv"
`include "Controller.sv"
`include "Decoder.sv"
`include "Imme_Ext.sv"
`include "JB_Unit.sv"
`include "LD_Filter.sv"
`include "Mux.sv"
`include "Reg_PC.sv"
`include "RegFile.sv"
`include "SRAM.sv"*/
module Top (
    input logic clk,
    input logic rst,
    output logic halt
);
wire [4:0]  opcode;
wire [2:0]  func3;
wire        func7;
wire [31:0] alu_src1, alu_src2, alu_out;
wire [31:0] imm_ext_out;
wire [31:0] inst;

wire [4:0]  rs1_index;
wire [4:0]  rs2_index;
wire [4:0]  rd_index;

wire [31:0] JB_src1, JB_out;
wire [31:0] ld_data_f;

wire [31:0] current_pc, next_pc;

wire [3:0]  im_w_en, dm_w_en;
wire        wb_en;
wire [31:0] dm_read_data;
wire [31:0] rs1_data_out, rs2_data_out;
wire [31:0] wb_data;

wire next_pc_sel, jb_src1_sel, alu_src1_sel, alu_src2_sel, wb_sel;
wire ecall_sig;


ALU alu (
    .opcode (opcode),
    .func3 (func3),
    .func7 (func7),
    .alu_src1 (alu_src1),
    .alu_src2 (alu_src2),
    .alu_out (alu_out)
);

Decoder decoder(
    .inst (inst),
    .dc_out_opcode (opcode),
    .dc_out_func3 (func3),
    .dc_out_func7 (func7),
    .dc_out_rs1_index (rs1_index),
    .dc_out_rs2_index (rs2_index),
    .dc_out_rd_index (rd_index)
);

Imm_Ext imm_ext(
    .inst (inst),
    .imm_ext_out (imm_ext_out)
);

JB_Unit jb_unit(
    .opcode (opcode),
    .JB_src1 (JB_src1),
    .JB_src2 (imm_ext_out),
    .JB_out (JB_out)  
);

LD_Filter ld_filter(
    .func3 (func3),
    .ld_data (dm_read_data),
    .ld_data_f (ld_data_f)
);

Reg_PC PC(
    .clk (clk),
    .reset (rst),
    .next_pc (next_pc),
    .current_pc (current_pc)
);


Controller contr(
    .opcode (opcode),
    .func3 (func3),
    .func7 (func7),
    .alu_branch (alu_out[0]),
    .next_pc_sel (next_pc_sel),
    .im_w_en (im_w_en),
    .dm_w_en (dm_w_en),
    .wb_en (wb_en),
    .jb_src1_sel (jb_src1_sel),
    .alu_src1_sel (alu_src1_sel),
    .alu_src2_sel (alu_src2_sel),
    .wb_sel (wb_sel),
    .ecall_sig(ecall_sig)
);

RegFile regfile(
    .clk (clk),
    .reset (rst),
    .ecall_sig (ecall_sig),
    .wb_en (wb_en),
    .wb_data (wb_data),
    .rd_index (rd_index),
    .rs1_index (rs1_index),
    .rs2_index (rs2_index),
    .rs1_data_out (rs1_data_out),
    .rs2_data_out (rs2_data_out),
    .halt (halt)
);

SRAM im(
    .clk (clk),
    .w_en (im_w_en),
    .address (current_pc),
    .write_data (32'b0),
    .read_data (inst)
);

SRAM dm(
    .clk (clk),
    .w_en (dm_w_en),
    .address (alu_out),
    .write_data (rs2_data_out),
    .read_data (dm_read_data)
);
wire [31:0]n_pc = current_pc + 32'd4;
Mux m1(
    .true_choice(JB_out),
    .false_choice(n_pc),
    .sel(next_pc_sel),
    .result(next_pc)
);  //choose next pc

Mux m2(
    .true_choice(current_pc),
    .false_choice(rs1_data_out),
    .sel(alu_src1_sel),
    .result(alu_src1)
);  //choose alu_src1

Mux m3(
    .true_choice(rs2_data_out),
    .false_choice(imm_ext_out),
    .sel(alu_src2_sel),
    .result(alu_src2)
);  //choose alu_src2

Mux m4(
    .true_choice(rs1_data_out),
    .false_choice(current_pc),
    .sel(jb_src1_sel),
    .result(JB_src1)
);  //choose JB_src1

Mux m5(
    .true_choice(ld_data_f),
    .false_choice(alu_out),
    .sel(wb_sel),
    .result(wb_data)
);  //choose wb_data


endmodule