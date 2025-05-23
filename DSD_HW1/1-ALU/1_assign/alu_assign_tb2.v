//continuous assignment tb
`timescale 1ns/10ps
`define CYCLE   10
`define HCYCLE  5

module alu_assign_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;

    alu_assign alu_assign(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out
    );

    initial begin
        $fsdbDumpfile("alu_assign.fsdb");
        $fsdbDumpvars;
    end

    integer err_count;
    initial begin
        // initialization
        err_count = 0;
        ctrl = 4'b0000; x = 8'b00000000; y = 8'b00000000;

        #(`CYCLE*0.2)
        $display( "Testing -1 + 1" );
        ctrl = 4'b0000; x = 8'b11111111; y = 8'b00000001;
        #(`CYCLE*0.3)
        if( out==8'b00000000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000000 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing 0 - 1" );
        ctrl = 4'b0001; x = 8'b00000000; y = 8'b00000001;
        #(`CYCLE*0.3)
        if( out==8'b11111111 && carry==1  ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b111111111 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing AND" );
        ctrl = 4'b0010; x = 8'b00000101; y = 8'b00000011;
        #(`CYCLE*0.3)
        if( out==8'b00000001 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000001 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing OR" );
        ctrl = 4'b0011; x = 8'b00000101; y = 8'b00000011;
        #(`CYCLE*0.3)
        if( out==8'b00000111 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000111 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing NOT" );
        ctrl = 4'b0100; x = 8'b00000001; y = 8'b00000000;
        #(`CYCLE*0.3)
        if( out==8'b11111110 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b011111110 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing XOR" );
        ctrl = 4'b0101; x = 8'b00000101; y = 8'b00000011;
        #(`CYCLE*0.3)
        if( out==8'b00000110 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000110 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Testing NOR" );
        ctrl = 4'b0110; x = 8'b00000101; y = 8'b00000011;
        #(`CYCLE*0.3)
        if( out==8'b11111000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b011111000 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Shift left" );
        ctrl = 4'b0111; x = 8'b00000001; y = 8'b00000001;
        #(`CYCLE*0.3)
        if( out==8'b00000010 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000010 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Shift right" );
        ctrl = 4'b1000; x = 8'b00000001; y = 8'b10000000;
        #(`CYCLE*0.3)
        if( out==8'b01000000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b001000000 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Shift Right Arithmetic" );
        ctrl = 4'b1001; x = 8'b10000000; y = 8'b00000000;
        #(`CYCLE*0.3)
        if( out==8'b11000000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b011000000 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Rotate Left" );
        ctrl = 4'b1010; x = 8'b11000000; y = 8'b00000000;
        #(`CYCLE*0.3)
        if( out==8'b10000001 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b010000001 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Rotate Right" );
        ctrl = 4'b1011; x = 8'b10000001; y = 8'b00000000;
        #(`CYCLE*0.3)
        if( out==8'b11000000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b011000000 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Equal" );
        ctrl = 4'b1100; x = 8'b11111111; y = 8'b11111111;
        #(`CYCLE*0.3)
        if( out==8'b00000001 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000001 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Not Equal" );
        ctrl = 4'b1100; x = 8'b00000000; y = 8'b11111111;
        #(`CYCLE*0.3)
        if( out==8'b00000000 && carry==0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b%b) != expected(%b)", carry, out, 9'b000000000 );
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
