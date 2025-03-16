`include "../1-ALU/1_assign/alu_assign.v"
`include "../2-RegisterFile/register_file.v"

module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    wire [7:0] busX;
    wire [7:0] alu_in;
    wire [7:0] alu_out;

// submodule instantiation
    assign alu_in = (Sel) ? busX : DataIn;

    alu_assign alu(
        .ctrl(Ctrl),
        .x(alu_in),
        .y(busY),
        .carry(Carry),
        .out(alu_out)
    );

    register_file reg_file(
        .Clk(Clk),
        .WEN(WEN),
        .RW(RW),
        .busW(alu_out),
        .RX(RX),
        .RY(RY),
        .busX(busX),
        .busY(busY)
    );

endmodule
