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

  logic temp_pc_src_o;
  logic temp_reg_dst_o;
  logic temp_alu_src1_o;
  logic temp_alu_src2_o;
  logic [3:0] temp_alu_op_o;
  logic [1:0] temp_branch_o;
  logic temp_mem_read_o;
  logic temp_mem_write_o;
  logic [3:0] temp_mem_sel_o;
  logic temp_reg_write_o;
  logic [1:0] temp_reg_src_o;

  always_comb begin
    case (inst_type_i)
      inst_ADD: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_XOR: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0101;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_OR: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0100;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_AND: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0011;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_ADDI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_ORI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0100;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_ANDI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0011;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_SLLI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0111;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_SRLI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b1000;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_LW: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 1;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 1;
      end
      inst_LB: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 1;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b0001;
        temp_reg_write_o = 1;
        temp_reg_src_o = 1;
      end
      inst_JALR: begin
        temp_pc_src_o = 1;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_SB: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 1;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 1;
        temp_mem_sel_o = 4'b0001;
        temp_reg_write_o = 0;
        temp_reg_src_o = 0;
      end
      inst_SW: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 1;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 1;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 0;
        temp_reg_src_o = 0;
      end
      inst_BEQ: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0010;
        temp_branch_o = 1;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 0;
        temp_reg_src_o = 0;
      end
      inst_BNE: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0010;
        temp_branch_o = 2;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 0;
        temp_reg_src_o = 0;
      end
      inst_LUI: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 2;
      end
      inst_AUIPC: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 1;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      inst_JAL: begin
        temp_pc_src_o = 1;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 1;
        temp_alu_src2_o = 1;
        temp_alu_op_o = 4'b0001;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 1;
        temp_reg_src_o = 0;
      end
      default: begin
        temp_pc_src_o = 0;
        temp_reg_dst_o = 0;
        temp_alu_src1_o = 0;
        temp_alu_src2_o = 0;
        temp_alu_op_o = 4'b0000;
        temp_branch_o = 0;
        temp_mem_read_o = 0;
        temp_mem_write_o = 0;
        temp_mem_sel_o = 4'b1111;
        temp_reg_write_o = 0;
        temp_reg_src_o = 0;
      end
    endcase
  end

  assign pc_src_o = temp_pc_src_o;
  assign reg_dst_o = temp_reg_dst_o;
  assign alu_src1_o = temp_alu_src1_o;
  assign alu_src2_o = temp_alu_src2_o;
  assign alu_op_o = temp_alu_op_o;
  assign branch_o = temp_branch_o;
  assign mem_read_o = temp_mem_read_o;
  assign mem_write_o = temp_mem_write_o;
  assign mem_sel_o = temp_mem_sel_o;
  assign reg_write_o = temp_reg_write_o;
  assign reg_src_o = temp_reg_src_o;

endmodule