module alu_unit (
  input wire [31:0] a,
  input wire [31:0] b,
  input wire [3:0] op,
  output wire [31:0] y
);

  logic [31:0] y_comb;
  always_comb begin
    y_comb = 32'h0;
    case (op)
      4'b0001: y_comb = a + b;
      4'b0010: y_comb = a - b;
      4'b0011: y_comb = a & b;
      4'b0100: y_comb = a | b;
      4'b0101: y_comb = a ^ b;
      4'b0110: y_comb = ~a;
      4'b0111: y_comb = a << (b % 32);
      4'b1000: y_comb = a >> (b % 32);
      4'b1001: y_comb = $signed(a) >>> (b % 32);
      4'b1010: y_comb = (a << (b % 32)) + (a >> (32 - (b % 32)));
    endcase
  end
  assign y = y_comb;

endmodule