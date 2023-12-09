`include "../header/inst_decoder.vh"

module inst_decoder_unit (
  input wire [31:0] inst_i,
  output reg [4:0] rs1_o,
  output reg [4:0] rs2_o,
  output reg [4:0] rd_o,
  output reg [31:0] imm_o,
  output reg [4:0] inst_type_o
);

  always_comb begin
    rd_o = inst_i[11:7];
    rs1_o = inst_i[19:15];
    rs2_o = inst_i[24:20];

    if (inst_i[6:0] == 7'b0110011) begin
      if (inst_i[14:12] == 3'b000) begin
        inst_type_o = inst_ADD;
      end else if (inst_i[14:12] == 3'b100) begin
        inst_type_o = inst_XOR;
      end else if (inst_i[14:12] == 3'b110) begin
        inst_type_o = inst_OR;
      end else if (inst_i[14:12] == 3'b111) begin
        inst_type_o = inst_AND;
      end else begin
        inst_type_o = inst_NONE;
      end
    end else if (inst_i[6:0] == 7'b0010011) begin
      if (inst_i[14:12] == 3'b000) begin
        inst_type_o = inst_ADDI;
      end else if (inst_i[14:12] == 3'b110) begin
        inst_type_o = inst_ORI;
      end else if (inst_i[14:12] == 3'b111) begin
        inst_type_o = inst_ANDI;
      end else if (inst_i[14:12] == 3'b001) begin
        inst_type_o = inst_SLLI;
      end else if (inst_i[14:12] == 3'b101) begin
        inst_type_o = inst_SRLI;
      end else begin
        inst_type_o = inst_NONE;
      end
    end else if (inst_i[6:0] == 7'b0000011) begin
      if (inst_i[14:12] == 3'b010) begin
        inst_type_o = inst_LW;
      end else if (inst_i[14:12] == 3'b000) begin
        inst_type_o = inst_LB;
      end else begin
        inst_type_o = inst_NONE;
      end
    end else if (inst_i[6:0] == 7'b1100111) begin
      inst_type_o = inst_JALR;
    end else if (inst_i[6:0] == 7'b0100011) begin
      if (inst_i[14:12] == 3'b000) begin
        inst_type_o = inst_SB;
      end else if (inst_i[14:12] == 3'b010) begin
        inst_type_o = inst_SW;
      end else begin
        inst_type_o = inst_NONE;
      end
    end else if (inst_i[6:0] == 7'b1100011) begin
      if (inst_i[14:12] == 3'b000) begin
        inst_type_o = inst_BEQ;
      end else if (inst_i[14:12] == 3'b001) begin
        inst_type_o = inst_BNE;
      end else begin
        inst_type_o = inst_NONE;
      end
    end else if (inst_i[6:0] == 7'b0110111) begin
      inst_type_o = inst_LUI;
    end else if (inst_i[6:0] == 7'b0010111) begin
      inst_type_o = inst_AUIPC;
    end else if (inst_i[6:0] == 7'b1101111) begin
      inst_type_o = inst_JAL;
    end else begin
      inst_type_o = inst_NONE;
    end

    if (inst_i[31] == 1'b0) begin
      case (inst_type_o)
        inst_ADDI, inst_ORI, inst_ANDI, inst_LW, inst_LB, inst_JALR: begin
          imm_o = {20'h00000, inst_i[31:20]};
        end
        inst_SLLI, inst_SRLI: begin
          imm_o = {27'b000000000000000000000000000, inst_i[24:20]};
        end
        inst_SB, inst_SW: begin
          imm_o = {20'h00000, inst_i[31:25], inst_i[11:7]};
        end
        inst_BEQ, inst_BNE: begin
          imm_o = {19'b0000000000000000000, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        end
        inst_LUI, inst_AUIPC: begin
          imm_o = {inst_i[31:12], 12'h000};
        end
        inst_JAL: begin
          imm_o = {11'b00000000000, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end
        default: begin
          imm_o = 0;
        end
      endcase
    end else begin
      case (inst_type_o)
        inst_ADDI, inst_ORI, inst_ANDI, inst_LW, inst_LB, inst_JALR: begin
          imm_o = {20'hfffff, inst_i[31:20]};
        end
        inst_SB, inst_SW: begin
          imm_o = {20'hfffff, inst_i[31:25], inst_i[11:7]};
        end
        inst_BEQ, inst_BNE: begin
          imm_o = {19'b1111111111111111111, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
        end
        inst_JAL: begin
          imm_o = {11'b11111111111, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end
        default: begin
          imm_o = 0;
        end
      endcase
    end
  end

endmodule