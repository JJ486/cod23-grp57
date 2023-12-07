`default_nettype none

module reg_file_unit (
    input wire clk,
    input wire reset,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire we,
    input wire [4:0] raddr_a,
    input wire [4:0] raddr_b,
    output wire [31:0] rdata_a,
    output wire [31:0] rdata_b
);

    logic [31:0] registers [31:0];
    logic [31:0] reg_rdata_a;
    logic [31:0] reg_rdata_b;

    always_ff @ (posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i = i + 1) begin
                registers[i] <=32'h0;
            end
        end else if (we) begin
            if (waddr != 0) begin
                registers[waddr] <= wdata;
            end
        end
    end

    always_comb begin
        reg_rdata_a = registers[raddr_a];
        reg_rdata_b = registers[raddr_b];
    end

    assign rdata_a = reg_rdata_a;
    assign rdata_b = reg_rdata_b;

endmodule