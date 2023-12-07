module wb_stage (
  input wire clk_i,
  input wire rst_i,

  input wire [4:0] wb_rd_addr_i,
  input wire [4:0] wb_rs2_addr_i,
  input wire [31:0] wb_mem_rdata_i,
  input wire [31:0] wb_alu_y_i,
  input wire [31:0] wb_imm_i,
  input wire wb_reg_dst_i,
  input wire wb_reg_write_i,
  input wire [1:0] wb_reg_src_i,

  output reg [31:0] wb_rf_waddr_o,
  output reg [31:0] wb_rf_wdata_o,
  output reg wb_reg_write_o

);

  logic [31:0] rf_waddr;
  logic [31:0] rf_wdata;

  always_comb begin
    if (wb_reg_write_i) begin
      if (wb_reg_dst_i) begin
        wb_rf_waddr_o = wb_rd_addr_i;
      end else begin
        wb_rf_waddr_o = wb_rs2_addr_i;
      end
      if (wb_reg_src_i == 2'b00) begin
        wb_rf_wdata_o = wb_alu_y_i;
      end else if (wb_reg_src_i == 2'b01) begin
        wb_rf_wdata_o = wb_mem_rdata_i;
      end else if (wb_reg_src_i == 2'b10) begin
        wb_rf_wdata_o = wb_imm_i;
      end else begin
        wb_rf_wdata_o = 32'b0;
      end
    end else begin
      wb_rf_waddr_o = 32'b0;
      wb_rf_wdata_o = 32'b0;
    end
    wb_reg_write_o = wb_reg_write_i;
  end

endmodule