module pipeline_controller (

  output reg if_stall_o,
  input wire if_ready_i,
  output reg if_ready_o,

  output reg id_stall_o,
  output reg id_hazard_o,
  input wire [4:0] id_rs1_addr_i,
  input wire [4:0] id_rs2_addr_i,
  input wire [31:0] id_rs1_data_i,
  input wire [31:0] id_rs2_data_i,
  input wire [31:0] id_imm_i,
  input wire [31:0] id_pc_i,
  input wire [1:0] id_branch_i,
  input wire id_pc_src_i,
  input wire id_alu_src1_i,

  output reg exe_stall_o,
  input wire [4:0] exe_rd_addr_i,
  input wire exe_mem_read_i,
  input wire exe_reg_write_i,
  input wire [1:0] exe_reg_src_i,
  input wire [31:0] exe_alu_y_i,
  input wire [31:0] exe_imm_i,
  
  input wire mem_ready_i,
  input wire [4:0] mem_rd_addr_i,
  input wire mem_reg_write_i,
  input wire [1:0] mem_reg_src_i,
  input wire [31:0] mem_mem_rdata_i,
  input wire [31:0] mem_alu_y_i,
  input wire [31:0] mem_imm_i,

  output reg [1:0] forward_1_o,
  output reg [1:0] forward_2_o,
  output reg [31:0] exe_bypass_result_o,
  output reg [31:0] mem_bypass_result_o,

  output reg [31:0] branch_rs1_data_o,
  output reg [31:0] branch_rs2_data_o,
  output reg [31:0] branch_pc_o,
  output reg [31:0] branch_imm_o,
  output reg [1:0] branch_o,
  output reg ctrl_jump_o,
  output reg [31:0] ctrl_jump_addr_o

);

  logic [31:0] mem_bypass_result;
  logic [31:0] exe_bypass_result;

  always_comb begin
    if (mem_reg_src_i == 2'b00) begin
      mem_bypass_result = mem_alu_y_i;
    end else if (mem_reg_src_i == 2'b01) begin
      mem_bypass_result = mem_mem_rdata_i;
    end else if (mem_reg_src_i == 2'b10) begin
      mem_bypass_result = mem_imm_i;
    end else begin
      mem_bypass_result = 32'b0;
    end

    if (exe_reg_src_i == 2'b00) begin
      exe_bypass_result = exe_alu_y_i;
    end else if (exe_reg_src_i == 2'b10) begin
      exe_bypass_result = exe_imm_i;
    end else begin
      exe_bypass_result = 32'b0;
    end
  end

  // bypass ALU and bypass MEM
  always_comb begin
    if (exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i == id_rs1_addr_i)) begin
      forward_1_o = 10;
      exe_bypass_result_o = exe_bypass_result;
      mem_bypass_result_o = 0;
    end else if (mem_reg_write_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == id_rs1_addr_i) && !(exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i != id_rs1_addr_i))) begin
      forward_1_o = 01;
      exe_bypass_result_o = 0;
      mem_bypass_result_o = mem_bypass_result;
    end else begin
      forward_1_o = 00;
      exe_bypass_result_o = 0;
      mem_bypass_result_o = 0;
    end
    if (exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i == id_rs2_addr_i)) begin
      forward_2_o = 10;
      exe_bypass_result_o = exe_bypass_result;
      mem_bypass_result_o = 0;
    end else if (mem_reg_write_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == id_rs2_addr_i) && !(exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i != id_rs2_addr_i))) begin
      forward_2_o = 01;
      exe_bypass_result_o = 0;
      mem_bypass_result_o = mem_bypass_result;
    end else begin
      forward_2_o = 00;
      exe_bypass_result_o = 0;
      mem_bypass_result_o = 0;
    end
  end

  always_comb begin
    if (!mem_ready_i) begin
      if_stall_o = 0;
      id_stall_o = 0;
      exe_stall_o = 0;
      id_hazard_o = 0;
      branch_o = 0;
      branch_pc_o = 0;
      branch_imm_o = 0;
      branch_rs1_data_o = 0;
      branch_rs2_data_o = 0;
      ctrl_jump_o = 0;
      ctrl_jump_addr_o = 0;
    end else begin
      if_stall_o = 1;
      id_stall_o = 1;
      exe_stall_o = 0;
      id_hazard_o = 0;
      branch_o = 0;
      branch_pc_o = 0;
      branch_imm_o = 0;
      branch_rs1_data_o = 0;
      branch_rs2_data_o = 0;
      ctrl_jump_o = 0;
      ctrl_jump_addr_o = 0;
      if (exe_mem_read_i && ((mem_rd_addr_i == id_rs1_addr_i) || (mem_rd_addr_i == id_rs2_addr_i))) begin
        if_stall_o = 1;
        id_stall_o = 1;
        exe_stall_o = 0;
        id_hazard_o = 1;
        branch_o = 0;
        branch_pc_o = 0;
        branch_imm_o = 0;
        branch_rs1_data_o = 0;
        branch_rs2_data_o = 0;
        ctrl_jump_o = 0;
        ctrl_jump_addr_o = 0;
      end else begin
        if_stall_o = 1;
        id_stall_o = 0;
        exe_stall_o = 0;
        id_hazard_o = 0;
        branch_o = 0;
        branch_pc_o = 0;
        branch_imm_o = 0;
        branch_rs1_data_o = 0;
        branch_rs2_data_o = 0;
        ctrl_jump_o = 0;
        ctrl_jump_addr_o = 0;
        if (id_pc_src_i) begin
          if (id_alu_src1_i) begin
            if_stall_o = 1;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = 0;
            branch_pc_o = 0;
            branch_imm_o = 0;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 1;
            ctrl_jump_addr_o = id_pc_i + id_imm_i;
          end else begin
            if (exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i == id_rs1_addr_i)) begin
              if_stall_o = 1;
              id_stall_o = 0;
              exe_stall_o = 0;
              id_hazard_o = 0;
              branch_o = 0;
              branch_pc_o = 0;
              branch_imm_o = 0;
              branch_rs1_data_o = 0;
              branch_rs2_data_o = 0;
              ctrl_jump_o = 1;
              ctrl_jump_addr_o = exe_bypass_result + id_imm_i;
            end else if (mem_reg_write_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == id_rs1_addr_i) && !(exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i != id_rs1_addr_i))) begin
              if_stall_o = 1;
              id_stall_o = 0;
              exe_stall_o = 0;
              id_hazard_o = 0;
              branch_o = 0;
              branch_pc_o = 0;
              branch_imm_o = 0;
              branch_rs1_data_o = 0;
              branch_rs2_data_o = 0;
              ctrl_jump_o = 1;
              ctrl_jump_addr_o = mem_bypass_result + id_imm_i;
            end else if (exe_mem_read_i && (mem_rd_addr_i == id_rs1_addr_i)) begin
              if_stall_o = 1;
              id_stall_o = 0;
              exe_stall_o = 0;
              id_hazard_o = 1;
              branch_o = 0;
              branch_pc_o = 0;
              branch_imm_o = 0;
              branch_rs1_data_o = 0;
              branch_rs2_data_o = 0;
              ctrl_jump_o = 0;
              ctrl_jump_addr_o = 0;
            end else begin
              if_stall_o = 1;
              id_stall_o = 0;
              exe_stall_o = 0;
              id_hazard_o = 0;
              branch_o = 0;
              branch_pc_o = 0;
              branch_imm_o = 0;
              branch_rs1_data_o = 0;
              branch_rs2_data_o = 0;
              ctrl_jump_o = 1;
              ctrl_jump_addr_o = id_rs1_data_i + id_imm_i;
            end
          end
        end else if (id_branch_i != 2'b00) begin
          if_stall_o = 0;
          id_stall_o = 0;
          exe_stall_o = 0;
          id_hazard_o = 0;
          branch_o = id_branch_i;
          branch_pc_o = id_pc_i;
          branch_imm_o = id_imm_i;
          branch_rs1_data_o = 0;
          branch_rs2_data_o = 0;
          ctrl_jump_o = 0;
          ctrl_jump_addr_o = 0;
          if (exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i == id_rs1_addr_i)) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = exe_bypass_result;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else if (mem_reg_write_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == id_rs1_addr_i) && !(exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i != id_rs1_addr_i))) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = mem_bypass_result;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else if (exe_mem_read_i && (mem_rd_addr_i == id_rs1_addr_i)) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 1;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = id_rs1_data_i;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end
          if (exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i == id_rs2_addr_i)) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = exe_bypass_result;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else if (mem_reg_write_i && (mem_rd_addr_i != 0) && (mem_rd_addr_i == id_rs2_addr_i) && !(exe_reg_write_i && (exe_rd_addr_i != 0) && (exe_rd_addr_i != id_rs2_addr_i))) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = mem_bypass_result;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else if (exe_mem_read_i && (mem_rd_addr_i == id_rs2_addr_i)) begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 1;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = 0;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end else begin
            if_stall_o = 0;
            id_stall_o = 0;
            exe_stall_o = 0;
            id_hazard_o = 0;
            branch_o = id_branch_i;
            branch_pc_o = id_pc_i;
            branch_imm_o = id_imm_i;
            branch_rs1_data_o = 0;
            branch_rs2_data_o = id_rs2_data_i;
            ctrl_jump_o = 0;
            ctrl_jump_addr_o = 0;
          end
        end else begin
          if_stall_o = 0;
          id_stall_o = 0;
          exe_stall_o = 0;
          id_hazard_o = 0;
          branch_o = 0;
          branch_pc_o = 0;
          branch_imm_o = 0;
          branch_rs1_data_o = 0;
          branch_rs2_data_o = 0;
          ctrl_jump_o = 0;
          ctrl_jump_addr_o = 0;
        end
      end
    end
  end

  always_comb begin
    if_ready_o = if_ready_i;
  end


endmodule