module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
    input        Clk, WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] busW;
    output [7:0] busX, busY;

    reg  [7:0] register [7:0];
    wire [7:0] readX;
    wire [7:0] readY;

    assign readX = register[RX];
    assign readY = register[RY];

    always @(posedge Clk) begin
        register[0] <= 8'b0;
        busX <= readX;
        busY <= readY;
        if (WEN && RW != 3'b000) begin
            register[RW] <= busW;
        end
    end

endmodule
