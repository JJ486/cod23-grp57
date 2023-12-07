module id_stage (
  input wire clk_i,
  input wire rst_i,

  input wire [31:0] id_pc_i,

  input wire id_stall_i,
  input wire id_hazard_i,

  input wire [4:0] rs1_i,
  input wire [4:0] rs2_i,
  input wire [4:0] rd_i,
  input wire [31:0] imm_i,
  
  output reg [4:0] rf_raddr_a,
  output reg [4:0] rf_raddr_b,
  input wire [31:0] rf_rdata_a,
  input wire [31:0] rf_rdata_b,

  input wire pc_src_i,
  input wire reg_dst_i,
  input wire alu_src1_i,
  input wire alu_src2_i,
  input wire [3:0] alu_op_i,
  input wire [1:0] branch_i,
  input wire mem_read_i,
  input wire mem_write_i,
  input wire [3:0] mem_sel_i,
  input wire reg_write_i,
  input wire [1:0] reg_src_i,

  output reg [31:0] id_pc_o,
  output reg [31:0] id_imm_o,
  output reg [4:0] id_rs1_addr_o,
  output reg [4:0] id_rs2_addr_o,
  output reg [4:0] id_rd_addr_o,
  output reg [31:0] id_rs1_data_o,
  output reg [31:0] id_rs2_data_o,

  output reg id_pc_src_o,
  output reg id_reg_dst_o,
  output reg id_alu_src1_o,
  output reg id_alu_src2_o,
  output reg [3:0] id_alu_op_o,
  output reg [1:0] id_branch_o,
  output reg id_mem_read_o,
  output reg id_mem_write_o,
  output reg [3:0] id_mem_sel_o,
  output reg id_reg_write_o,
  output reg [1:0] id_reg_src_o

);

  typedef enum logic [1:0] {
    ID_IDLE,
    ID_WORK,
    ID_BUBBLE
  }state_id;

  state_id id_current_state, id_next_state;

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      id_current_state <= ID_IDLE;
    end else begin
      id_current_state <= id_next_state;
    end
  end

  always_comb begin
    case (id_current_state)
      ID_IDLE: begin
        if (id_stall_i) begin
          id_next_state = ID_IDLE;
        end else begin
          if (id_hazard_i) begin
            id_next_state = ID_BUBBLE;
          end else begin
            id_next_state = ID_WORK;
          end
        end
      end
      ID_WORK: begin
        id_next_state = ID_IDLE;
      end
      ID_BUBBLE: begin
        id_next_state = ID_IDLE;
      end
      default: begin
        id_next_state = ID_IDLE;
      end
    endcase
  end

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      id_rs1_data_o <= 32'b0;
      id_rs2_data_o <= 32'b0;
      id_pc_src_o <= 0;
      id_reg_dst_o <= 0;
      id_alu_src1_o <= 0;
      id_alu_src2_o <= 0;
      id_alu_op_o <= 4'b0;
      id_mem_read_o <= 0;
      id_mem_write_o <= 0;
      id_mem_sel_o <= 4'b1111;
      id_reg_write_o <= 0;
      id_reg_src_o <= 0;
    end else begin
      case (id_current_state)
        ID_WORK: begin
          id_rs1_data_o <= rf_rdata_a;
          id_rs2_data_o <= rf_rdata_b;
          id_pc_src_o <= pc_src_i;
          id_reg_dst_o <= reg_dst_i;
          id_alu_src1_o <= alu_src1_i;
          id_alu_src2_o <= alu_src2_i;
          id_alu_op_o <= alu_op_i;
          id_mem_read_o <= mem_read_i;
          id_mem_write_o <= mem_write_i;
          id_mem_sel_o <= mem_sel_i;
          id_reg_write_o <= reg_write_i;
          id_reg_src_o <= reg_src_i;
        end
        ID_BUBBLE: begin
          id_rs1_data_o <= 32'b0;
          id_rs2_data_o <= 32'b0;
          id_pc_src_o <= 0;
          id_reg_dst_o <= 0;
          id_alu_src1_o <= 0;
          id_alu_src2_o <= 0;
          id_alu_op_o <= 4'b0;
          id_mem_read_o <= 0;
          id_mem_write_o <= 0;
          id_mem_sel_o <= 4'b1111;
          id_reg_write_o <= 0;
          id_reg_src_o <= 0;
        end
      endcase
    end
  end

  always_comb begin
    rf_raddr_a = rs1_i;
    rf_raddr_b = rs2_i;
    id_pc_o = id_pc_i;
    id_rs1_addr_o = rs1_i;
    id_rs2_addr_o = rs2_i;
    id_rd_addr_o = rd_i;
    id_imm_o = imm_i;
    id_branch_o = branch_i;
  end

endmodule