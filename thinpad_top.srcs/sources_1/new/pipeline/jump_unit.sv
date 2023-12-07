module jump_unit (
  input wire branch_jump_i,
  input wire [31:0] branch_jump_addr_i,
  input wire ctrl_jump_i,
  input wire [31:0] ctrl_jump_addr_i,

  output reg if_flush_o,
  output reg if_jump_pc_o
);

  always_comb begin
    if (branch_jump_i) begin
      if_flush_o = 1;
      if_jump_pc_o = branch_jump_addr_i;
    end else if (ctrl_jump_i) begin
      if_flush_o = 1;
      if_jump_pc_o = ctrl_jump_addr_i;
    end else begin
      if_flush_o = 0;
      if_jump_pc_o = 32'b0;
    end
  end

endmodule