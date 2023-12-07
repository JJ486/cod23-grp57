module mem_stage (
  input wire clk_i,
  input wire rst_i,

  input wire [31:0] mem_pc_i,

  input wire [31:0] mem_rs2_data_i,
  input wire [4:0] mem_rd_addr_i,
  input wire [4:0] mem_rs2_addr_i,
  input wire [31:0] mem_alu_y_i,
  input wire [31:0] mem_imm_i,

  input wire mem_reg_dst_i,
  input wire mem_mem_read_i,
  input wire mem_mem_write_i,
  input wire [3:0] mem_mem_sel_i,
  input wire mem_reg_write_i,
  input wire [1:0] mem_reg_src_i,

  output reg wb_cyc_o,
  output reg wb_stb_o,
  input wire wb_ack_i,
  output reg [31:0] wb_adr_o,
  input wire [31:0] wb_dat_i,
  output reg [31:0] wb_dat_o,
  output reg [3:0] wb_sel_o,
  output reg wb_we_o,

  output reg [31:0] mem_pc_o,
  output reg [4:0] mem_rd_addr_o,
  output reg [4:0] mem_rs2_addr_o,
  output reg [31:0] mem_mem_rdata_o,
  output reg [31:0] mem_alu_y_o,
  output reg [31:0] mem_imm_o,
  output reg mem_reg_dst_o,
  output reg mem_reg_write_o,
  output reg [1:0] mem_reg_src_o,

  input reg if_ready_i,
  output reg mem_ready_o

);

  typedef enum logic [2:0] {
    MEM_IDLE,
    MEM_READ,
    MEM_READ_DONE,
    MEM_WRITE,
    MEM_WRITE_DONE
  }state_mem;

  state_mem mem_current_state, mem_next_state;

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      mem_current_state <= MEM_IDLE;
    end else begin
      mem_current_state <= mem_next_state;
    end
  end

  always_comb begin
    case (mem_current_state)
      MEM_IDLE: begin
        if (if_ready_i) begin
          if (mem_mem_read_i) begin
            mem_next_state = MEM_READ;
          end else if (mem_mem_write_i) begin
            mem_next_state = MEM_WRITE;
          end else begin
            mem_next_state = MEM_IDLE;
          end
        end else begin
          mem_next_state = MEM_IDLE;
        end
      end
      MEM_READ: begin
        if (wb_ack_i) begin
          mem_next_state = MEM_READ_DONE;
        end else begin
          mem_next_state = MEM_READ;
        end
      end
      MEM_WRITE: begin
        if (wb_ack_i) begin
          mem_next_state = MEM_WRITE_DONE;
        end else begin
          mem_next_state = MEM_WRITE;
        end
      end
      MEM_READ_DONE: begin
        mem_next_state = MEM_IDLE;
      end
      MEM_WRITE_DONE: begin
        mem_next_state = MEM_IDLE;
      end
      default: begin
        mem_next_state = MEM_IDLE;
      end
    endcase
  end

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      wb_cyc_o <= 0;
      wb_stb_o <= 0;
      wb_we_o <= 0;
      wb_sel_o <= 4'b1111;
      wb_adr_o <= 32'b0;
      wb_dat_o <= 32'b0;
      mem_ready_o <= 0;
    end else begin
      case (mem_current_state)
        MEM_IDLE: begin
          if (if_ready_i) begin
            mem_ready_o <= 0;
            if (mem_mem_read_i) begin
              wb_cyc_o <= 1;
              wb_stb_o <= 1;
              wb_we_o <= 0;
              wb_sel_o <= mem_mem_sel_i;
              wb_adr_o <= mem_alu_y_i;
            end else begin
              wb_cyc_o <= 1;
              wb_stb_o <= 1;
              wb_we_o <= 1;
              wb_sel_o <= mem_mem_sel_i;
              wb_adr_o <= mem_alu_y_i;
              wb_dat_o <= mem_rs2_data_i;
            end
          end
        end
        MEM_READ: begin
          if (wb_ack_i) begin
            wb_cyc_o <= 0;
            wb_stb_o <= 0;
            wb_we_o <= 0;
          end
        end
        MEM_READ_DONE: begin
          mem_ready_o <= 1;
        end
        MEM_WRITE: begin
          wb_cyc_o <= 0;
          wb_stb_o <= 0;
          wb_we_o <= 0;
        end
        MEM_WRITE_DONE: begin
          mem_ready_o <= 1;
        end
      endcase
    end
  end

  always_comb begin
    mem_pc_o = mem_pc_i;
    mem_rd_addr_o = mem_rd_addr_i;
    mem_rs2_addr_o = mem_rs2_addr_i;
    mem_imm_o = mem_imm_i;

    mem_mem_rdata_o = wb_dat_i;
    mem_alu_y_o = mem_alu_y_i;
    
    mem_reg_dst_o = mem_reg_dst_i;
    mem_reg_write_o = mem_reg_write_i;
    mem_reg_src_o = mem_reg_src_i;
  end

endmodule