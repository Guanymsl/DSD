// Your SingleCycle RISC-V code

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
    output        mem_wen_D  ;  // mem_wen_D is high, core writes data to D-mem; else, core reads data from D-mem
    output [31:0] mem_addr_D ;  // the specific address to fetch/store data
    output [31:0] mem_wdata_D;  // data writing to D-mem
    input  [31:0] mem_rdata_D;  // data reading from D-mem
    // for mem_I
    output [31:0] mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem

    // For PC
    reg [31:0] PC, PC_nxt;
    reg        Branch, Jal, Jalr;

    // For Data Memory
    reg        wen_D_reg;
    reg [31:0] addr_D_reg;
    reg [31:0] wdata_D_reg;

    assign mem_wen_D  = wen_D_reg;
    assign mem_addr_D = addr_D_reg;
    assign mem_addr_I = PC;
    assign {mem_wdata_D[7:0], mem_wdata_D[15:8], mem_wdata_D[23:16], mem_wdata_D[31:24]} = wdata_D_reg[31:0];

    // For Instruction
    reg [31:0] instruction;
    reg [ 6:0] op;
    reg [ 2:0] funct3;
    reg [ 6:0] funct7;
    reg [ 4:0] rs1, rs2, rd;
    reg [31:0] imm;

    // For Register File
    reg         regWrite;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data, rs2_data;

    reg_file reg0(
        .clk(clk),
        .rst_n(rst_n),
        .wen(regWrite),
        .RW(rd),
        .busW(rd_data),
        .RX(rs1),
        .RY(rs2),
        .busX(rs1_data),
        .busY(rs2_data)
    );

    // For ALU
    wire [ 3:0] ALUCtrl;
    wire [31:0] ALUIn1, ALUIn2;
    wire [31:0] ALUResult;

    alu alu0(
        .ctrl(ALUCtrl),
        .a(ALUIn1),
        .b(ALUIn2),
        .out(ALUResult)
    );

    assign ALUCtrl[0] = op[4] & funct3[2] & funct3[1] & (!funct3[0]);
    assign ALUCtrl[1] = !(op[4] & (!op[3]) & funct3[1]);
    assign ALUCtrl[2] = ((!op[4]) & (!funct3[1])) | (funct7[5] & op[4]);
    assign ALUCtrl[3] = op[4] & (!funct3[2]) & funct3[1];

    assign ALUIn1 = rs1_data;
    assign ALUIn2 = (op[4] | op[6]) ? rs2_data : imm;

    always @(*) begin
        instruction[31:0] = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]};

        imm         = 0;
        addr_D_reg  = 0;
        wdata_D_reg = 0;
        wen_D_reg   = 0;
        rd_data     = 0;
        regWrite    = 0;

        //For ALU
        op     = instruction[6:0];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        rd     = instruction[11:7];

        // For PC
        Branch = 0;
        Jal    = 0;
        Jalr   = 0;
        PC_nxt = (Branch | Jal) ? PC + imm:
                 (Jalr) ? rs1_data + imm:
                 PC + 4;

        case (op)
            // R-type instructions: add, sub, and, or
            7'b0110011: begin
                rd_data  = ALUResult;
                regWrite = 1;
            end

            // R-type instructions: slt
            7'b0010011: begin
                rd_data  = ALUResult;
                regWrite = 1;
            end

            // I-type instructions: lw
            7'b0000011: begin
                imm           = {{20{instruction[31]}}, instruction[31:20]};
                addr_D_reg    = ALUResult;
                rd_data[31:0] = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]};
                regWrite      = 1;
            end

            // B-type instructions: beq
            7'b1100011: begin
                if (ALUResult == 32'd0) begin
                    imm    = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    Branch = 1;
                end
            end

            // S-type instructions: sw
            7'b0100011: begin
                imm         = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                addr_D_reg  = ALUResult;
                wdata_D_reg = rs2_data;
                wen_D_reg   = 1;
            end

            // J-type instructions: jal
            7'b1101111: begin
                imm      = {{20{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                Jal      = 1;
                rd_data  = PC + 4;
                regWrite = 1;
            end

            // I-type instructions: jalr
            7'b1100111: begin
                imm      = {{20{instruction[31]}}, instruction[31:20]};
                Jalr     = 1;
                rd_data  = PC + 4;
                regWrite = 1;
            end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n)
            PC <= 32'd0;
        else
            PC <= PC_nxt;
    end
endmodule

module reg_file(clk, rst_n, wen, RW, busW, RX, RY, busX, busY);
    input        clk, rst_n, wen;
    input  [31:0] busW;
    input  [ 4:0] RW, RX, RY;
    output [31:0] busX, busY;

    reg [31:0] mem [0:31];

    assign busX = mem[RX];
    assign busY = mem[RY];

    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<32; i=i+1)
                mem[i] <= 0;
        end
        else begin
            mem[0] <= 0;
            if (wen && RW != 5'd0)
                mem[RW] <= busW;
        end
    end
endmodule

module alu(ctrl, a, b, out);
    input  [ 3:0] ctrl;
    input  [31:0] a;
    input  [31:0] b;
    output [31:0] out;

    assign out = (ctrl == 4'b0000) ? a & b :
                 (ctrl == 4'b0001) ? a | b :
                 (ctrl == 4'b0010) ? a + b :
                 (ctrl == 4'b0110) ? a - b :
                 (ctrl == 4'b1000) ? (($signed(a) < $signed(b)) ? 1 : 0) : 0;
endmodule
