module exe_stage (
  input wire clk_i,
  input wire rst_i,

  input wire [31:0] exe_pc_i,

  input wire exe_stall_i,

  input wire [31:0] exe_rs1_data_i,
  input wire [31:0] exe_rs2_data_i,

  input wire [4:0] exe_rd_addr_i,
  input wire [4:0] exe_rs2_addr_i,
  input wire [31:0] exe_imm_i,

  input wire exe_reg_dst_i,
  input wire exe_alu_src1_i,
  input wire exe_alu_src2_i,
  input wire [3:0] exe_alu_op_i,
  input wire exe_mem_read_i,
  input wire exe_mem_write_i,
  input wire [3:0] exe_mem_sel_i,
  input wire exe_reg_write_i,
  input wire [1:0] exe_reg_src_i,

  input wire [1:0] forward_1_i,
  input wire [1:0] forward_2_i,
  input wire [31:0] exe_bypass_result_i,
  input wire [31:0] mem_bypass_result_i,

  output reg [31:0] alu_a_o,
  output reg [31:0] alu_b_o,
  output reg [3:0] alu_op_o,
  input wire [31:0] alu_y_i,

  output reg [31:0] exe_pc_o,
  output reg [31:0] exe_rs1_data_o,
  output reg [31:0] exe_rs2_data_o,
  output reg [4:0] exe_rd_addr_o,
  output reg [4:0] exe_rs2_addr_o,
  output reg [31:0] exe_alu_y_o,
  output reg [31:0] exe_imm_o,

  output reg exe_reg_dst_o,
  output reg exe_mem_read_o,
  output reg exe_mem_write_o,
  output reg [3:0] exe_mem_sel_o,
  output reg exe_reg_write_o,
  output reg [1:0] exe_reg_src_o

);

  typedef enum logic [1:0] {
    EXE_IDLE,
    EXE_WORK
  }state_exe;

  state_exe exe_current_state, exe_next_state;

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      exe_current_state <= EXE_IDLE;
    end else begin
      exe_current_state <= exe_next_state;
    end
  end

  always_comb begin
    case (exe_current_state)
      EXE_IDLE: begin
        if (exe_stall_i) begin
          exe_next_state = EXE_IDLE;
        end else begin
          exe_next_state = EXE_WORK;
        end
      end
      EXE_WORK: begin
        exe_next_state = EXE_IDLE;
      end
      default: begin
        exe_next_state = EXE_IDLE;
      end
    endcase
  end

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      alu_a_o <= 32'b0;
      alu_b_o <= 32'b0;
      alu_op_o <= 4'b0;
    end else begin
      if (exe_current_state == EXE_WORK) begin
        if (!exe_stall_i) begin
          alu_op_o <= exe_alu_op_i;
          if (forward_1_i == 2'b00) begin
            if (exe_alu_src1_i) begin
              alu_a_o <= {exe_rs1_data_i, 12'h000};
            end else begin
              alu_a_o <= exe_pc_i;
            end
          end else if (forward_1_i == 2'b10) begin
            alu_a_o <= exe_bypass_result_i;
          end else if (forward_1_i == 2'b01) begin
            alu_a_o <= mem_bypass_result_i;
          end
          
          if (forward_2_i == 2'b00) begin
            if (exe_alu_src2_i) begin
              alu_b_o <= {exe_rs2_data_i, 12'h000};
            end else begin
              alu_b_o <= exe_imm_i;
            end
          end else if (forward_2_i == 2'b10) begin
            alu_b_o <= exe_bypass_result_i;
          end else if (forward_2_i == 2'b01) begin
            alu_b_o <= mem_bypass_result_i;
          end
        end
      end
    end
  end

  always_comb begin
    exe_pc_o = exe_pc_i;
    exe_rs1_data_o = exe_rs1_data_i;
    exe_rs2_data_o = exe_rs2_data_i;
    exe_rd_addr_o = exe_rd_addr_i;
    exe_rs2_addr_o = exe_rs2_addr_i;
    exe_imm_o = exe_imm_i;

    exe_reg_dst_o = exe_reg_dst_i;
    exe_mem_read_o = exe_mem_read_i;
    exe_mem_write_o = exe_mem_write_i;
    exe_mem_sel_o = exe_mem_sel_i;
    exe_reg_write_o = exe_reg_write_i;
    exe_reg_src_o = exe_reg_src_i;

    exe_alu_y_o = alu_y_i;
  end

endmodule