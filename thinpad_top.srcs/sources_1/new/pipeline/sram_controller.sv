module sram_controller_unit #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n
);

  // TODO: 实现 SRAM 控制器
  typedef enum logic [3:0] {
    ST_IDLE,
    ST_READ,
    ST_READ_2,
    ST_WRITE,
    ST_WRITE_2,
    ST_WRITE_3,
    ST_DONE
  } state_t;

  state_t current_state;
  state_t next_state;

  wire [31:0] sram_data_i_comb;
  reg [31:0] sram_data_o_comb;
  reg sram_data_t_comb;

  assign sram_data = sram_data_t_comb ? 32'bz : sram_data_o_comb;
  assign sram_data_i_comb = sram_data;

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      current_state <= ST_IDLE;
    end else begin
      current_state <=next_state;
    end
  end

  always_comb begin
    case (current_state)
      ST_IDLE: begin
        if (wb_cyc_i && wb_stb_i) begin
          if (wb_we_i) begin
            next_state = ST_WRITE;
          end else begin
            next_state = ST_READ;
          end
        end else begin
          next_state = ST_IDLE;
        end
      end

      ST_WRITE: begin
        next_state = ST_WRITE_2;
      end

      ST_WRITE_2: begin
        next_state = ST_WRITE_3;
      end

      ST_WRITE_3: begin
        next_state = ST_DONE;
      end

      ST_READ: begin
        next_state = ST_READ_2;
      end

      ST_READ_2: begin
        next_state = ST_DONE;
      end

      ST_DONE: begin
        next_state = ST_IDLE;
      end

      default: begin
        next_state = ST_IDLE;
      end
    endcase
  end

  always_ff @ (posedge clk_i) begin
    if (rst_i) begin
      wb_ack_o <= 0;
      wb_dat_o <= 0;
      sram_addr <= 0;
      sram_ce_n <= 1;
      sram_oe_n <= 1;
      sram_we_n <= 1;
      sram_be_n <= 0;
      sram_data_t_comb <= 0;
      sram_data_o_comb <= 32'b0;
    end else begin
      case (current_state)
        ST_IDLE: begin
          if (wb_cyc_i && wb_stb_i) begin
            if (wb_we_i) begin
              sram_ce_n <= 0;
              sram_oe_n <= 1;
              sram_we_n <= 1;
              sram_be_n <= ~wb_sel_i;
              sram_addr <= wb_adr_i[21:2];
              sram_data_t_comb <= 0;
              sram_data_o_comb <= wb_dat_i;
            end else begin
              sram_ce_n <= 0;
              sram_oe_n <= 0;
              sram_we_n <= 1;
              sram_be_n <= 4'b0;
              sram_addr <= wb_adr_i[21:2];
              sram_data_t_comb <= 1;
            end
          end
        end

        ST_WRITE: begin
          sram_we_n <= 0;
        end

        ST_WRITE_2: begin
          sram_we_n <= 1;
        end

        ST_WRITE_3: begin
          sram_ce_n <= 1;
          wb_ack_o <= 1;
        end

        ST_READ: begin
          wb_dat_o <= sram_data_i_comb;
        end

        ST_READ_2: begin
          sram_ce_n <= 1;
          sram_oe_n <= 1;
          wb_ack_o <= 1;
        end

        ST_DONE: begin
          wb_ack_o <= 0;
        end
      endcase
    end
  end

endmodule
