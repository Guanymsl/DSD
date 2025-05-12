module alu_always(
    ctrl,
    x,
    y,
    zero,
    out
);
    input  [3:0]        ctrl;
    input  [31:0]        x;
    input  [31:0]        y;
    //output reg          carry; //no need carry
    output reg [31:0]    out;
    output reg          zero;

    always@(*)begin
        case(ctrl) // synopsys parallel_case full_case
        4'b0010: //Add (signed)
            out = x+y;
        4'b0110: //Sub (signed)
            out = x-y;
        4'b0000: //Bitwise And
            out = x&y;
        4'b0001: //Bitwise Or
            out = x|y;
        4'b1000: //SLT
            out = ($signed(x) < $signed(y))? 32'd1:32'd0;
        endcase
        zero = (out == 32'd0)? 1'b1:1'b0;
    end

endmodule

module core(clk,
            rst_n,
            // for mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // for mem_I
            mem_addr_I,
            mem_rdata_I
    );

    input         clk, rst_n ;
    // for mem_D
    output reg       mem_wen_D  ;  // mem_wen_D is high, core writes data to D-mem; else, core reads data from D-mem
    output reg [31:0] mem_addr_D ;  // the specific address to fetch/store data, unit: byte 
    output reg [31:0] mem_wdata_D;  // data writing to D-mem little endian
    input  [31:0] mem_rdata_D;  // data reading from D-mem little endian
    // for mem_I
    output reg [31:0] mem_addr_I ;  // the fetching address of next instruction, unit: byte
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem

    reg [31:0] PC;
    reg [31:0] next_PC;
    wire [31:0] instruction; //the current instruction
    wire [31:0] mem_wdata; // big endian
    wire [31:0] mem_rdata; // big endian
    wire [31:0] data_read_1; // the data read from register
    wire [31:0] data_read_2; // the data read form register
    reg [31:0] alu_data_read_2; // the second data should be read from alu
    reg [31:0] data_write; //data write to register
    wire        zero_flag;
    wire [31:0] alu_result;
    reg        register_wen;
    reg [31:0] immediate;
    //control signal
    reg RegWrite, MemWrite, ALUsrc, MemtoReg, Branch, Jal, Jalr;
    //reg RegWrite, MemWrite, MemtoReg, Branch, Jal, Jalr;
    //reg RegWrite, MemWrite, MemtoReg;
    reg [3:0] alu_control;

    reg [31:0] reg_file [0:31];

    //parameter for opcode
    parameter R_format = 7'b0110011;
    parameter SW = 7'b0100011;
    parameter LW = 7'b0000011;
    parameter BEQ = 7'b1100011;
    parameter JALR = 7'b1100111;
    parameter JAL = 7'b1101111;
    integer i;

    //submodule
    //register_file RF (.clk(clk), .wen(register_wen), .rst_n(rst_n), .RW(instruction[11:7]), .busW(data_write), .RX(instruction[19:15]), .RY(instruction[24:20]), .busX(data_read_1), .busY(data_read_2));
    assign data_read_1 = reg_file[instruction[19:15]];
    assign data_read_2 = reg_file[instruction[24:20]];
    alu_always ALU (.ctrl(alu_control), .x(data_read_1), .y(alu_data_read_2), .zero(zero_flag), .out(alu_result));

    //endian convert
    assign instruction = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]}; //little -> big
    assign mem_rdata = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]}; //little -> big
    assign mem_wdata = data_read_2;

    always@(*)begin
        mem_addr_I = PC;
        case(instruction[6:0]) // synopsys parallel_case full_case
            R_format:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b0010000;

                if(instruction[30]) alu_control = 4'b0110;
                else if(instruction[12]) alu_control = 4'b0000;
                else if(~instruction[13]) alu_control = 4'b0010;
                else if(instruction[14]) alu_control = 4'b0001;
                else alu_control = 4'b1000;
                immediate = 32'dx;
            end
            SW:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b1x01000;
                immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]};
                alu_control = 4'b0010;
            end
            LW:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b1110000;
                immediate = {{20{instruction[31]}},instruction[31:20]};
                alu_control = 4'b0010;
            end
            BEQ:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b0x00100;
                immediate = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                alu_control = 4'b0110;
            end
            JALR:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b0x10001;
                immediate = {{20{instruction[31]}},instruction[31:20]};
                alu_control = 4'bxxxx;
            end
            JAL:begin
                {ALUsrc, MemtoReg, RegWrite, MemWrite, Branch, Jal, Jalr}=7'b0x10010;
                immediate = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
                alu_control = 4'bxxxx;
            end
        endcase

        mem_addr_D = alu_result;
        alu_data_read_2 = (ALUsrc)? immediate:data_read_2;
        data_write = (Jal|Jalr)? (PC+32'd4) : (MemtoReg)? mem_rdata:alu_result;
        mem_wdata_D = {mem_wdata[7:0], mem_wdata[15:8], mem_wdata[23:16], mem_wdata[31:24]}; //big -> little

        register_wen = RegWrite;
        mem_wen_D = MemWrite;
        next_PC = (Jalr)? (data_read_1+immediate):((Branch&zero_flag)|Jal)? (PC+immediate) : (PC+32'd4);
    end

    //sequential logic
    always@(posedge clk)begin
        if(!rst_n) begin
            PC <= 32'd0;
            for(i = 0; i < 32; i = i + 1)begin
                reg_file[i] <= 32'd0;
            end
        end
        else begin
            PC <= next_PC;
            if(register_wen && instruction[11:7] != 5'd0)begin
                reg_file[instruction[11:7]] <= data_write;
            end
        end
    end

endmodule