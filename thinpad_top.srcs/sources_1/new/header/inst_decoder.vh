`ifndef INST_DECODER_HEADER
`define INST_DECODER_HEADER

typedef enum logic [4:0] {
  inst_ADD,
  inst_XOR,
  inst_OR,
  inst_AND,
  inst_ADDI,
  inst_ORI,
  inst_ANDI,
  inst_SLLI,
  inst_SRLI,
  inst_LW,
  inst_LB,
  inst_JALR,
  inst_SB,
  inst_SW,
  inst_BEQ,
  inst_BNE,
  inst_LUI,
  inst_AUIPC,
  inst_JAL,
  inst_MINU,
  inst_SBSET,
  inst_XNOR,
  inst_NONE
} inst_type;

`endif