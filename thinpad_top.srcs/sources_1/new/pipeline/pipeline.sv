`include "../header/inst_decoder.vh"

module pipeline (
  input wire clk_i,
  input wire rst_i,
  input wire push_btn_i,

  output reg [31:0] wbs_adr_o,
  input wire [31:0] wbs_dat_i,
  output reg [31:0] wbs_dat_o,
  output reg wbs_we_o,
  output reg [3:0] wbs_sel_o,
  output reg wbs_stb_o,
  input wire wbs_ack_i,
  input wire wbs_err_i,
  input wire wbs_rty_i,
  output reg wbs_cyc_o 
);

  // if stage
  logic [31:0] if_pc;
  logic [31:0] if_inst;
  logic if_ready;

  // id stage
  logic [31:0] id_pc;
  logic [31:0] id_imm;
  logic [4:0] id_rs1_addr;
  logic [4:0] id_rs2_addr;
  logic [4:0] id_rd_addr;
  logic [31:0] id_rs1_data;
  logic [31:0] id_rs2_data;
  logic id_pc_src;
  logic id_reg_dst;
  logic id_alu_src1;
  logic id_alu_src2;
  logic [3:0] id_alu_op;
  logic [1:0] id_branch;
  logic id_mem_read;
  logic id_mem_write;
  logic [3:0] id_mem_sel;
  logic id_reg_write;
  logic [1:0] id_reg_src;

  // exe stage
  logic [31:0] exe_pc;
  logic [31:0] exe_rs1_data;
  logic [31:0] exe_rs2_data;
  logic [4:0] exe_rd_addr;
  logic [4:0] exe_rs2_addr;
  logic [31:0] exe_alu_y;
  logic [31:0] exe_imm;
  logic exe_reg_dst;
  logic exe_mem_read;
  logic exe_mem_write;
  logic [3:0] exe_mem_sel;
  logic exe_reg_write;
  logic [1:0] exe_reg_src;
  
  // mem stage
  logic [31:0] mem_pc;
  logic [4:0] mem_rd_addr;
  logic [4:0] mem_rs2_addr;
  logic [31:0] mem_mem_rdata;
  logic [31:0] mem_alu_y;
  logic [31:0] mem_imm;
  logic mem_reg_dst;
  logic mem_reg_write;
  logic [1:0] mem_reg_src;

  // wb stage
  

  // controller (bypass, hazard)
  logic if_stall;
  logic ctrl_if_ready;
  logic id_stall;
  logic id_hazard;
  logic exe_stall;
  logic mem_ready;
  logic [1:0] forward_1;
  logic [1:0] forward_2;
  logic [31:0] exe_bypass_result;
  logic [31:0] mem_bypass_result;

  // alu
  logic [31:0] alu_a;
  logic [31:0] alu_b;
  logic [3:0] alu_op;
  logic [31:0] alu_y;

  // regfile
  logic [4:0] rf_raddr_a;
  logic [4:0] rf_raddr_b;
  logic [31:0] rf_rdata_a;
  logic [31:0] rf_rdata_b;
  logic [4:0] rf_waddr;
  logic [31:0] rf_wdata;
  logic rf_we;

  // inst decoder
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rd;
  logic [31:0] imm;
  logic [4:0] inst_type;

  // signal
  logic pc_src;
  logic reg_dst;
  logic alu_src1;
  logic alu_src2;
  logic [3:0] sig_alu_op;
  logic [1:0] sig_branch;
  logic mem_read;
  logic mem_write;
  logic [3:0] mem_sel;
  logic reg_write;
  logic [1:0] reg_src;

  // branch detect
  logic branch_jump;
  logic [31:0] branch_jump_addr;
  logic [31:0] branch_rs1_data;
  logic [31:0] branch_rs2_data;
  logic [31:0] branch_pc;
  logic [31:0] branch_imm;
  logic [1:0] branch;

  // jump
  logic if_flush;
  logic [31:0] if_jump_pc;
  logic ctrl_jump;
  logic [31:0] ctrl_jump_addr;

  // wishbone
  logic wb0_cyc_o;
  logic wb0_stb_o;
  logic wb0_ack_i;
  logic [31:0] wb0_adr_o;
  logic [31:0] wb0_dat_i;
  logic [3:0] wb0_sel_o;
  logic wb0_we_o;
  logic wb0_err_o;
  logic wb0_rty_o;

  logic wb1_cyc_o;
  logic wb1_stb_o;
  logic wb1_ack_i;
  logic [31:0] wb1_adr_o;
  logic [31:0] wb1_dat_o;
  logic [31:0] wb1_dat_i;
  logic [3:0] wb1_sel_o;
  logic wb1_we_o;
  logic wb1_err_o;
  logic wb1_rty_o;
  
  if_stage u_if_stage (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .push_btn_i(push_btn_i),
    .if_stall_i(if_stall),
    .if_flush_i(if_flush),
    .if_ready_o(if_ready),
    .if_jump_pc_i(if_jump_pc),
    .if_pc_o(if_pc),
    .if_inst_o(if_inst),
    .wb_cyc_o(wb0_cyc_o),
    .wb_stb_o(wb0_stb_o),
    .wb_ack_i(wb0_ack_i),
    .wb_adr_o(wb0_adr_o),
    .wb_dat_i(wb0_dat_i),
    .wb_sel_o(wb0_sel_o),
    .wb_we_o(wb0_we_o)
  );

  id_stage u_id_stage (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .id_pc_i(if_pc),
    .id_stall_i(id_stall),
    .id_hazard_i(id_hazard),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rd_i(rd),
    .imm_i(imm),
    .rf_raddr_a(rf_raddr_a),
    .rf_raddr_b(rf_raddr_b),
    .rf_rdata_a(rf_rdata_a),
    .rf_rdata_b(rf_rdata_b),
    .pc_src_i(pc_src),
    .reg_dst_i(reg_dst),
    .alu_src1_i(alu_src1),
    .alu_src2_i(alu_src2),
    .alu_op_i(sig_alu_op),
    .branch_i(sig_branch),
    .mem_read_i(mem_read),
    .mem_write_i(mem_write),
    .mem_sel_i(mem_sel),
    .reg_write_i(reg_write),
    .reg_src_i(reg_src),
    .id_pc_o(id_pc),
    .id_imm_o(id_imm),
    .id_rs1_addr_o(id_rs1_addr),
    .id_rs2_addr_o(id_rs2_addr),
    .id_rd_addr_o(id_rd_addr),
    .id_rs1_data_o(id_rs1_data),
    .id_rs2_data_o(id_rs2_data),
    .id_pc_src_o(id_pc_src),
    .id_reg_dst_o(id_reg_dst),
    .id_alu_src1_o(id_alu_src1),
    .id_alu_src2_o(id_alu_src2),
    .id_alu_op_o(id_alu_op),
    .id_branch_o(id_branch),
    .id_mem_read_o(id_mem_read),
    .id_mem_write_o(id_mem_write),
    .id_mem_sel_o(id_mem_sel),
    .id_reg_write_o(id_reg_write),
    .id_reg_src_o(id_reg_src)
  );

  exe_stage u_exe_stage(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .exe_pc_i(id_pc),
    .exe_stall_i(exe_stall),
    .exe_rs1_data_i(id_rs1_data),
    .exe_rs2_data_i(id_rs2_data),
    .exe_rd_addr_i(id_rd_addr),
    .exe_rs2_addr_i(id_rs2_addr),
    .exe_imm_i(id_imm),
    .exe_reg_dst_i(id_reg_dst),
    .exe_alu_src1_i(id_alu_src1),
    .exe_alu_src2_i(id_alu_src2),
    .exe_alu_op_i(id_alu_op),
    .exe_mem_read_i(id_mem_read),
    .exe_mem_write_i(id_mem_write),
    .exe_mem_sel_i(id_mem_sel),
    .exe_reg_write_i(id_reg_write),
    .exe_reg_src_i(id_reg_src),
    .forward_1_i(forward_1),
    .forward_2_i(forward_2),
    .exe_bypass_result_i(exe_bypass_result),
    .mem_bypass_result_i(mem_bypass_result),
    .alu_a_o(alu_a),
    .alu_b_o(alu_b),
    .alu_op_o(alu_op),
    .alu_y_i(alu_y),
    .exe_pc_o(exe_pc),
    .exe_rs1_data_o(exe_rs1_data),
    .exe_rs2_data_o(exe_rs2_data),
    .exe_rd_addr_o(exe_rd_addr),
    .exe_rs2_addr_o(exe_rs2_addr),
    .exe_alu_y_o(exe_alu_y),
    .exe_imm_o(exe_imm),
    .exe_reg_dst_o(exe_reg_dst),
    .exe_mem_read_o(exe_mem_read),
    .exe_mem_write_o(exe_mem_write),
    .exe_mem_sel_o(exe_mem_sel),
    .exe_reg_write_o(exe_reg_write),
    .exe_reg_src_o(exe_reg_src)
  );

  mem_stage u_mem_stage (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .mem_pc_i(exe_pc),
    .mem_rs2_data_i(exe_rs2_data),
    .mem_rd_addr_i(exe_rd_addr),
    .mem_rs2_addr_i(exe_rs2_addr),
    .mem_alu_y_i(exe_alu_y),
    .mem_imm_i(exe_imm),
    .mem_reg_dst_i(exe_reg_dst),
    .mem_mem_read_i(exe_mem_read),
    .mem_mem_write_i(exe_mem_write),
    .mem_mem_sel_i(exe_mem_sel),
    .mem_reg_write_i(exe_reg_write),
    .mem_reg_src_i(exe_reg_src),
    .wb_cyc_o(wb1_cyc_o),
    .wb_stb_o(wb1_stb_o),
    .wb_ack_i(wb1_ack_i),
    .wb_adr_o(wb1_adr_o),
    .wb_dat_i(wb1_dat_i),
    .wb_dat_o(wb1_dat_o),
    .wb_sel_o(wb1_sel_o),
    .wb_we_o(wb1_we_o),
    .mem_pc_o(mem_pc),
    .mem_rd_addr_o(mem_rd_addr),
    .mem_rs2_addr_o(mem_rs2_addr),
    .mem_mem_rdata_o(mem_mem_rdata),
    .mem_alu_y_o(mem_alu_y),
    .mem_imm_o(mem_imm),
    .mem_reg_dst_o(mem_reg_dst),
    .mem_reg_write_o(mem_reg_write),
    .mem_reg_src_o(mem_reg_src),
    .if_ready_i(ctrl_if_ready),
    .mem_ready_o(mem_ready)
  );

  wb_stage u_wb_stage (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .wb_rd_addr_i(mem_rd_addr),
    .wb_rs2_addr_i(mem_rs2_addr),
    .wb_mem_rdata_i(mem_mem_rdata),
    .wb_alu_y_i(mem_alu_y),
    .wb_imm_i(mem_imm),
    .wb_reg_dst_i(mem_reg_dst),
    .wb_reg_write_i(mem_reg_write),
    .wb_reg_src_i(mem_reg_src),
    .wb_rf_waddr_o(rf_waddr),
    .wb_rf_wdata_o(rf_wdata),
    .wb_reg_write_o(rf_we)
  );

  alu_unit u_alu_unit (
    .a(alu_a),
    .b(alu_b),
    .op(alu_op),
    .y(alu_y)
  );

  reg_file_unit u_reg_file_unit (
    .clk(clk_i),
    .reset(rst_i),
    .waddr(rf_waddr),
    .wdata(rf_wdata),
    .we(rf_we),
    .raddr_a(rf_raddr_a),
    .raddr_b(rf_raddr_b),
    .rdata_a(rf_rdata_a),
    .rdata_b(rf_rdata_b)
  );

  inst_decoder_unit u_inst_decoder_unit (
    .inst_i(if_inst),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .rd_o(rd),
    .imm_o(imm),
    .inst_type_o(inst_type)
  );

  signal_control_unit u_signal_control_unit (
    .inst_type_i(inst_type),
    .pc_src_o(pc_src),
    .reg_dst_o(reg_dst),
    .alu_src1_o(alu_src1),
    .alu_src2_o(alu_src2),
    .alu_op_o(sig_alu_op),
    .branch_o(sig_branch),
    .mem_read_o(mem_read),
    .mem_write_o(mem_write),
    .mem_sel_o(mem_sel),
    .reg_write_o(reg_write),
    .reg_src_o(reg_src)
  );

  branch_detect_unit u_branch_detect_unit (
    .rs1_data_i(branch_rs1_data),
    .rs2_data_i(branch_rs2_data),
    .pc_i(branch_pc),
    .imm_i(branch_imm),
    .branch_i(branch),
    .branch_jump_o(branch_jump),
    .branch_jump_addr_o(branch_jump_addr)
  );

  jump_unit u_jump_unit (
    .branch_jump_i(branch_jump),
    .branch_jump_addr_i(branch_jump_addr),
    .ctrl_jump_i(ctrl_jump),
    .ctrl_jump_addr_i(ctrl_jump_addr),
    .if_flush_o(if_flush),
    .if_jump_pc_o(if_jump_pc)
  );

  pipeline_controller u_pipeline_controller (
    .if_stall_o(if_stall),
    .if_ready_i(if_ready),
    .if_ready_o(ctrl_if_ready),
    .id_stall_o(id_stall),
    .id_hazard_o(id_hazard),
    .id_rs1_addr_i(id_rs1_addr),
    .id_rs2_addr_i(id_rs2_addr),
    .id_rs1_data_i(id_rs1_data),
    .id_rs2_data_i(id_rs2_data),
    .id_imm_i(id_imm),
    .id_pc_i(id_pc),
    .id_branch_i(id_branch),
    .id_pc_src_i(id_pc_src),
    .id_alu_src1_i(id_alu_src1),
    .exe_stall_o(exe_stall),
    .exe_rd_addr_i(exe_rd_addr),
    .exe_mem_read_i(exe_mem_read),
    .exe_reg_write_i(exe_reg_write),
    .exe_reg_src_i(exe_reg_src),
    .exe_alu_y_i(exe_alu_y),
    .exe_imm_i(exe_imm),
    .mem_ready_i(mem_ready),
    .mem_rd_addr_i(mem_rd_addr),
    .mem_reg_write_i(mem_reg_write),
    .mem_reg_src_i(mem_reg_src),
    .mem_mem_rdata_i(mem_mem_rdata),
    .mem_alu_y_i(mem_alu_y),
    .mem_imm_i(mem_imm),
    .forward_1_o(forward_1),
    .forward_2_o(forward_2),
    .exe_bypass_result_o(exe_bypass_result),
    .mem_bypass_result_o(mem_bypass_result),
    .branch_rs1_data_o(branch_rs1_data),
    .branch_rs2_data_o(branch_rs2_data),
    .branch_pc_o(branch_pc),
    .branch_imm_o(branch_imm),
    .branch_o(branch),
    .ctrl_jump_o(ctrl_jump),
    .ctrl_jump_addr_o(ctrl_jump_addr)
  );

  wb_arbiter_2 u_wb_arbiter_2 (
    .clk(clk_i),
    .rst(rst_i),
    .wbm0_adr_i(wb0_adr_o),
    .wbm0_dat_i(32'b0),
    .wbm0_dat_o(wb0_dat_i),
    .wbm0_we_i(wb0_we_o),
    .wbm0_sel_i(wb0_sel_o),
    .wbm0_stb_i(wb0_stb_o),
    .wbm0_ack_o(wb0_ack_i),
    .wbm0_err_o(wb0_err_o),
    .wbm0_rty_o(wb0_rty_o),
    .wbm0_cyc_i(wb0_cyc_o),
    .wbm1_adr_i(wb1_adr_o),
    .wbm1_dat_i(wb1_dat_o),
    .wbm1_dat_o(wb1_dat_i),
    .wbm1_we_i(wb1_we_o),
    .wbm1_sel_i(wb1_sel_o),
    .wbm1_stb_i(wb1_stb_o),
    .wbm1_ack_o(wb1_ack_i),
    .wbm1_err_o(wb1_err_o),
    .wbm1_rty_o(wb1_rty_o),
    .wbm1_cyc_i(wb1_cyc_o),
    .wbs_adr_o(wbs_adr_o),
    .wbs_dat_i(wbs_dat_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_we_o(wbs_we_o),
    .wbs_sel_o(wbs_sel_o),
    .wbs_stb_o(wbs_stb_o),
    .wbs_ack_i(wbs_ack_i),
    .wbs_err_i(wbs_err_i),
    .wbs_rty_i(wbs_rty_i),
    .wbs_cyc_o(wbs_cyc_o)
  );

endmodule