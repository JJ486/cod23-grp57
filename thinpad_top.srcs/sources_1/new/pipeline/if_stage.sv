module if_stage (
  input wire clk_i,
  input wire rst_i,

  input wire if_stall_i,
  input wire if_flush_i,
  output reg if_ready_o,

  input wire [31:0] if_jump_pc_i,

  output reg [31:0] if_pc_o,
  output reg [31:0] if_inst_o,

  output reg wb_cyc_o,
  output reg wb_stb_o,
  input wire wb_ack_i,
  output reg [31:0] wb_adr_o,
  input wire [31:0] wb_dat_i,
  output reg [3:0] wb_sel_o,
  output reg wb_we_o

);

  logic [31:0] pc;
  logic [31:0] pc_next;

  typedef enum logic [1:0] {
    IF_IDLE,
    IF_READ,
    IF_DONE
  }state_if;

  state_if if_current_state, if_next_state;

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      if_current_state <= IF_IDLE;
    end else begin
      if_current_state <= if_next_state;
    end
  end

  always_comb begin
    case (if_current_state)
      IF_IDLE: begin
        if (if_stall_i) begin
          if_next_state = IF_IDLE;
        end else begin
          if_next_state = IF_READ;
        end
      end
      IF_READ: begin
        if (if_flush_i) begin
          if_next_state = IF_DONE;
        end else begin
          if (wb_ack_i) begin
            if_next_state = IF_DONE;
          end else begin
            if_next_state = IF_READ;
          end
        end
      end
      IF_DONE: begin
        if_next_state = IF_IDLE;
      end
      default: begin
        if_next_state = IF_IDLE;
      end
    endcase
  end

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      pc <= 32'h80000000;
      if_inst_o <= 32'b0;
      wb_cyc_o <= 0;
      wb_stb_o <= 0;
      wb_we_o <= 0;
      wb_sel_o <= 4'b1111;
      wb_adr_o <= 32'b0;
      if_ready_o <= 1;
    end else begin
      case (if_current_state)
        IF_IDLE: begin
          if (!if_stall_i) begin
            wb_cyc_o <= 1;
            wb_stb_o <= 1;
            wb_we_o <= 0;
            wb_adr_o <= pc;
            if_ready_o <= 0;
          end
        end
        IF_READ: begin
          if (if_flush_i) begin
            if_inst_o <= 32'b0;
          end else begin
            if (wb_ack_i) begin
              wb_cyc_o <= 0;
              wb_stb_o <= 0;
              wb_we_o <= 0;
              if_pc_o <= pc;
              if_inst_o <= wb_dat_i;
            end
          end
        end
        IF_DONE: begin
          pc <= pc_next;
          if_ready_o <= 1;
        end
      endcase
    end
  end

  always_comb begin
    if (if_flush_i) begin
      pc_next = if_jump_pc_i;
    end else begin
      pc_next = pc + 4;
    end
  end

endmodule