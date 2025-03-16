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
    wire [7:0] alu_out;
    wire [7:0] write_data;

// submodule instantiation
    assign write_data = (Sel) ? alu_out : DataIn;

    register_file reg_file(
        .Clk(Clk),
        .WEN(WEN),
        .RW(RW),
        .busW(write_data),
        .RX(RX),
        .RY(RY),
        .busX(busX),
        .busY(busY)
    );

    alu_assign alu (
        .ctrl(Ctrl),
        .x(busX),
        .y(busY),
        .carry(Carry),
        .out(alu_out)
    );

endmodule
