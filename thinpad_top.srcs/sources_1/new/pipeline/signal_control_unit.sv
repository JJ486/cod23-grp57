`include "../header/inst_decoder.vh"

module signal_control_unit (
  input wire [4:0] inst_type_i,
  output reg pc_src_o, // 0 for pc + 4, 1 for jump
  output reg reg_dst_o, // 0 for rd, 1 for rs2
  output reg alu_src1_o,  // 0 for rs1_data, 1 for pc
  output reg alu_src2_o, // 0 for rs2_data, 1 for imm
  output reg [3:0] alu_op_o,
  output reg [1:0] branch_o, // 0 for not_branch, 1 for BEQ, 2 for BNE
  output reg mem_read_o, // 0 for is_mem_read, 1 for not_mem_read
  output reg mem_write_o, // 0 for is_mem_write, 1 for not_mem_write
  output reg [3:0] mem_sel_o,
  output reg reg_write_o, // 0 for is_reg_write, 1 for not_reg_write
  output reg [1:0] reg_src_o // 0 for ALU_result, 1 for mem_read_result, 2 for imm
);

always_comb begin
  case (inst_type_i)
    inst_ADD: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_XOR: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0101;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_OR: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0100;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_AND: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0011;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_ADDI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_ORI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0100;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_ANDI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0011;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_SLLI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0111;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_SRLI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b1000;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_LW: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 1;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 1;
    end
    inst_LB: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 1;
      mem_write_o = 0;
      mem_sel_o = 4'b0001;
      reg_write_o = 1;
      reg_src_o = 1;
    end
    inst_JALR: begin
      pc_src_o = 1;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_SB: begin
      pc_src_o = 0;
      reg_dst_o = 1;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 1;
      mem_sel_o = 4'b0001;
      reg_write_o = 0;
      reg_src_o = 0;
    end
    inst_SW: begin
      pc_src_o = 0;
      reg_dst_o = 1;
      alu_src1_o = 0;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 1;
      mem_sel_o = 4'b1111;
      reg_write_o = 0;
      reg_src_o = 0;
    end
    inst_BEQ: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0010;
      branch_o = 1;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 0;
      reg_src_o = 0;
    end
    inst_BNE: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0010;
      branch_o = 2;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 0;
      reg_src_o = 0;
    end
    inst_LUI: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 0;
      alu_src2_o = 0;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 2;
    end
    inst_AUIPC: begin
      pc_src_o = 0;
      reg_dst_o = 0;
      alu_src1_o = 1;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
    inst_JAL: begin
      pc_src_o = 1;
      reg_dst_o = 0;
      alu_src1_o = 1;
      alu_src2_o = 1;
      alu_op_o = 4'b0001;
      branch_o = 0;
      mem_read_o = 0;
      mem_write_o = 0;
      mem_sel_o = 4'b1111;
      reg_write_o = 1;
      reg_src_o = 0;
    end
  endcase
end

endmodule