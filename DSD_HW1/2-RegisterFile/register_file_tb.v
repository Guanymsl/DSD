`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;

    // instantiate the design-under-test
    register_file rf(
        Clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );

    // write your test pattern here
    // waveform dump
    initial begin
       $fsdbDumpfile("register_file.fsdb");
       $fsdbDumpvars;
    end

    // clock generation
    always#(`HCYCLE) Clk = ~Clk;

    // simulation
    integer err_count;
    initial begin
        // initialization
        Clk = 1'b1;
        err_count = 0;

        #(`CYCLE*0.2)
        $display( "Store 1 in REG#1" );
        WEN = 1'b1; RW = 3'd1; RX = 3'd0; RY = 3'd0; busW = 8'd1;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        WEN = 1'b0; RW = 3'd0; RX = 3'd1; RY = 3'd0; busW = 8'd0;
        #(`CYCLE*0.3)
        if( busX==8'd1 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b) != expected(%b)", busX, 8'd1 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Store 2 in REG#2" );
        WEN = 1'b1; RW = 3'd2; RX = 3'd0; RY = 3'd0; busW = 8'd2;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        WEN = 1'b0; RW = 3'd0; RX = 3'd0; RY = 3'd2; busW = 8'd0;
        #(`CYCLE*0.3)
        if( busY==8'd2 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b) != expected(%b)", busY, 8'd2 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Store 3 in REG#1" );
        WEN = 1'b1; RW = 3'd1; RX = 3'd0; RY = 3'd0; busW = 8'd3;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        WEN = 1'b0; RW = 3'd0; RX = 3'd1; RY = 3'd0; busW = 8'd0;
        #(`CYCLE*0.3)
        if( busX==8'd3 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b) != expected(%b)", busX, 8'd3 );
        end
        #(`HCYCLE)

        #(`CYCLE*0.2)
        $display( "Store 4 in REG#0" );
        WEN = 1'b1; RW = 3'd0; RX = 3'd0; RY = 3'd0; busW = 8'd4;
        #(`CYCLE*0.8)
        #(`CYCLE*0.2)
        WEN = 1'b0; RW = 3'd0; RX = 3'd0; RY = 3'd0; busW = 8'd0;
        #(`CYCLE*0.3)
        if( busX==8'd0 ) $display( "    .... passed." );
        else begin
            err_count = err_count+1;
            $display( "    .... failed, design(%b) != expected(%b)", busX, 8'd0 );
        end
        #(`HCYCLE)

        // show total results
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
