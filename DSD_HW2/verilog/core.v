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

    reg  [31:0] PC, PC_nxt;
    reg         regWrite;
    reg  [ 4:0] rs1, rs2, rd;
    wire [31:0] rs1_data, rs2_data;
    reg  [31:0] rd_data;

    reg [31:0] instruction;

    reg        wen_D_reg;
    reg [31:0] addr_D_reg;
    reg [31:0] wdata_D_reg;

    reg [31:0] imm;
    reg [ 6:0] opcode;
    reg [ 2:0] funct3;
    reg [ 6:0] funct7;

    reg_file reg0(
        .clk(clk),
        .rst_n(rst_n),
        .wen(regWrite),
        .a1(rs1),
        .a2(rs2),
        .aw(rd),
        .d(rd_data),
        .q1(rs1_data),
        .q2(rs2_data)
    );

    assign mem_wen_D  = wen_D_reg;
    assign mem_addr_D = addr_D_reg;
    assign mem_addr_I = PC;

    assign {mem_wdata_D[7:0], mem_wdata_D[15:8], mem_wdata_D[23:16], mem_wdata_D[31:24]} = wdata_D_reg[31:0];

    always @(*) begin
        instruction[31:0] = {mem_rdata_I[7:0], mem_rdata_I[15:8], mem_rdata_I[23:16], mem_rdata_I[31:24]};

        imm         = 0;
        addr_D_reg  = 0;
        wdata_D_reg = 0;
        wen_D_reg   = 0;
        rd_data     = 0;
        regWrite    = 0;
        PC_nxt      = PC + 4;

        opcode = instruction[6:0];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        funct7 = instruction[30];

        case (opcode)
            // R-type instructions: add, sub, and, or
            7'b0110011: begin
                case (funct7)
                    1'b0: rd_data = (funct3 == 3'b000) ? rs1_data + rs2_data :          // ADD
                                          (funct3 == 3'b111) ? rs1_data & rs2_data :    // AND
                                          (funct3 == 3'b110) ? rs1_data | rs2_data : 0; // OR
                    1'b1: rd_data = rs1_data - rs2_data;                                // SUB
                    default: rd_data = 0;
                endcase
                regWrite = 1;
            end

            // R-type instructions: slt
            7'b0010011: begin
                rd_data = ($signed(rs1_data) < $signed(rs2_data)) ? 1 : 0; // SLT
                regWrite = 1;
            end

            // I-type instructions: lw
            7'b0000011: begin
                imm           = {{20{instruction[31]}}, instruction[31:20]};
                addr_D_reg    = rs1_data + imm;
                rd_data[31:0] = {mem_rdata_D[7:0], mem_rdata_D[15:8], mem_rdata_D[23:16], mem_rdata_D[31:24]};
                regWrite      = 1;
            end

            // B-type instructions: beq
            7'b1100011: begin
                if (rs1_data == rs2_data) begin
                    imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    PC_nxt = PC + imm;
                end
            end

            // S-type instructions: sw
            7'b0100011: begin
                imm         = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                addr_D_reg  = rs1_data + imm;
                wdata_D_reg = rs2_data;
                wen_D_reg   = 1;
            end

            // J-type instructions: jal
            7'b1101111: begin
                imm      = {{20{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                PC_nxt   = PC + imm;
                rd_data  = PC + 4;
                regWrite = 1;
            end

            // I-type instructions: jalr
            7'b1100111: begin
                imm      = {{20{instruction[31]}}, instruction[31:20]};
                PC_nxt   = rs1_data + imm;
                rd_data  = PC + 4;
                regWrite = 1;
            end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            PC <= 32'd0;
        end
        else begin
            PC <= PC_nxt;
        end
    end
endmodule

module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);
    input        clk, rst_n, wen;
    input [31:0] d;
    input [4:0]  a1, a2, aw;

    output [31:0] q1, q2;

    reg [31:0] mem [0:31];

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i=0; i<32; i=i+1)
                mem[i] <= 0;
        end
        else begin
            mem[0] <= 0;
            if (wen && aw != 5'd0)
                mem[aw] <= d;
        end
    end
endmodule
