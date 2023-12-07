module branch_detect_unit (
  input wire [31:0] rs1_data_i,
  input wire [31:0] rs2_data_i,
  input wire [31:0] pc_i,
  input wire [31:0] imm_i,
  input wire [1:0] branch_i,
  
  output reg branch_jump_o,
  output reg [31:0] branch_jump_addr_o
);

  always_comb begin
    if (branch_i == 1) begin
      if (rs1_data_i == rs2_data_i) begin
        branch_jump_o = 1;
        branch_jump_addr_o = pc_i + imm_i;
      end else begin
        branch_jump_o = 0;
        branch_jump_addr_o = 32'b0;
      end
    end else if (branch_i == 2) begin
      if (rs1_data_i != rs2_data_i) begin
        branch_jump_o = 1;
        branch_jump_addr_o = pc_i + imm_i;
      end else begin
        branch_jump_o = 0;
        branch_jump_addr_o = 32'b0;
      end
    end else begin
      branch_jump_o = 0;
      branch_jump_addr_o = 32'b0;
    end
  end

endmodule