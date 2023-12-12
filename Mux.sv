module Mux(
    input [31:0] true_choice,
    input [31:0] false_choice,
    input sel,
    output [31:0]result
);
assign result = (sel) ? true_choice : false_choice;
endmodule