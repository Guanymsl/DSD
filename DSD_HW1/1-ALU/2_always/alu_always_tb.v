//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

module alu_always_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;

    alu_always alu_always(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out
    );

    initial begin
        $fsdbDumpfile("alu_always.fsdb");
        $fsdbDumpvars;
    end

    integer err_count;
    initial begin
        // initialization
        err_count = 0;

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "1: store multiplicand A=%2d in REG#1", A );
        $display( "    [REG#1 = add %b REG#0]", A );
        ctrl = 4'b0000; x = 1'b0; y = A;
        #(`CYCLE*0.3)
        if( out== && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, A );
        end
        #(`HCYCLE)

        if( err_count==0 ) begin
            $display("****************************        /|__/|");
            $display("**                        **      / O,O  |");
            $display("**   Congratulations !!   **    /_____   |");
            $display("** All Patterns Passed!!  **   /^ ^ ^ \\  |");
            $display("**                        **  |^ ^ ^ ^ |w|");
            $display("****************************   \\m___m__|_|");
        end
        else begin
            $display("**************************** ");
            $display("           Failed ...        ");
            $display("     Total %2d Errors ...     ", err_count );
            $display("**************************** ");
        end

        // finish tb
        #(`CYCLE) $finish;
    end
endmodule
