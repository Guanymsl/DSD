module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);

//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;

//==== wire/reg definition ================================
localparam S_IDLE   = 2'd0;
localparam S_LOOKUP = 2'd1;
localparam S_WB     = 2'd2;
localparam S_REFILL = 2'd3;

reg [1:0] state_r, state_w;

// Single cache array: { valid(1), dirty(1), tag(24), data(128) }
// [154] = valid, [153] = dirty, [152:128] = tag, [127:0] = data
reg [154:0] cache_r [0:7];
reg [154:0] cache_w [0:7];

reg req_read_r, req_write_r;

wire [23:0] req_tag    = proc_addr[29:5];
wire [2:0]  req_index  = proc_addr[4:2];
wire [3:0]  req_offset = proc_addr[1:0];

wire valid, dirty, hit;
wire [23:0] tag;

assign valid = cache_r[req_index][154];
assign dirty = cache_r[req_index][153];
assign tag   = cache_r[req_index][152:128];

assign hit        = (valid && tag == req_tag);
assign proc_stall = (state_r != S_IDLE);

reg [127:0] evict_data;

integer i;

//==== combinational circuit ==============================
always @(*) begin
    state_w = state_r;
    case (state_r) // synopsys parallel_case full_case
        S_IDLE: begin
            if (proc_read || proc_write) state_w = S_LOOKUP;
        end
        S_LOOKUP: begin
            if (hit) begin
                state_w = S_IDLE;
            end else if (valid && dirty) begin
                state_w = S_WB;
            end else begin
                state_w = S_REFILL;
            end
        end
        S_WB: begin
            if (mem_ready) state_w = S_REFILL;
        end
        S_REFILL: begin
            if (mem_ready) state_w = S_IDLE;
        end
    endcase
end

always @(*) begin
    for (i = 0; i < 8; i = i + 1)
        cache_w[i] = cache_r[i];

    case (state_r) // synopsys parallel_case full_case
        S_LOOKUP: begin
            if (hit) begin
                if (req_read_r) begin
                    proc_rdata = cache_r[req_index][(req_offset << 5)+:32];
                end
                if (req_write_r) begin
                    // update word and set dirty
                    cache_w[req_index][127:0] &= (32'd0 << (req_offset << 5));
                    cache_w[req_index][127:0] |= (proc_wdata << (req_offset << 5));
                    cache_w[req_index][153] = 1'b1;
                    proc_rdata = proc_wdata;
                end
            end
        end
        S_WB: begin
            mem_write = 1'b1;
            mem_addr  = req_addr_r[29:4];
            mem_wdata = cache_r[req_index][127:0];
        end
        S_REFILL: begin
            mem_read = 1'b1;
            mem_addr = req_addr_r[29:4];
            if (mem_ready) begin
                cache_w[req_index] = {1'b1, 1'b0, req_tag, mem_rdata};
                if (req_write_r) begin
                    cache_w[req_index][127:0] &= (32'd0 << (req_offset << 5));
                    cache_w[req_index][127:0] |= (proc_wdata << (req_offset << 5));
                    cache_w[req_index][153] = 1'b1;
                    proc_rdata = proc_wdata;
                end else begin
                    proc_rdata = cache_w[req_index][(req_offset << 5)+:32];
                end
            end
        end
    endcase
end

//==== sequential circuit =================================
always @(posedge clk) begin
    if (proc_reset) begin
        state_r      <= S_IDLE;
        req_read_r   <= 1'b0;
        req_write_r  <= 1'b0;
        for (i = 0; i < 8; i = i + 1)
            cache_r[i] <= 155'd0;
    end else begin
        state_r      <= state_w;
        req_read_r   <= proc_read;
        req_write_r  <= proc_write;
        for (i = 0; i < 8; i = i + 1)
            cache_r[i] <= cache_w[i];
    end
end

endmodule
