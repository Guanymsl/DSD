//RT �Vlevel (event-driven)
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out
);

    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;

    reg [7:0] out_r;
    reg       carry_r;

    assign carry = carry_r;
    assign out   = out_r;

    always @(*) begin
        carry_r = 1'b0;
        case (ctrl)
            4'b0000: {carry_r, out_r} = $signed(x) + $signed(y);
            4'b0001: {carry_r, out_r} = $signed(x) - $signed(y);
            4'b0010: out_r = x & y;
            4'b0011: out_r = x | y;
            4'b0100: out_r = ~x;
            4'b0101: out_r = x ^ y;
            4'b0110: out_r = ~(x | y);
            4'b0111: out_r = y << x[2:0];
            4'b1000: out_r = y >> x[2:0];
            4'b1001: out_r = {x[7], x[7:1]};
            4'b1010: out_r = {x[6:0], x[7]};
            4'b1011: out_r = {x[0], x[7:1]};
            4'b1100: out_r = x == y ? 8'd1 : 8'd0;
            default: out_r = 8'b00000000;
        endcase
    end

endmodule
