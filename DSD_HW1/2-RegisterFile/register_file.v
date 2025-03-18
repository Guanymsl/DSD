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

    reg [7:0] register [7:0];
    reg [7:0] busX_r, busY_r;

    assign busX = busX_r;
    assign busY = busY_r;

    always @(posedge Clk) begin
        register[0] <= 8'b0;

        busX_r <= register[RX];
        busY_r <= register[RX];

        if (WEN && RW != 3'b000) begin
            register[RW] <= busW;
        end

    end

endmodule
