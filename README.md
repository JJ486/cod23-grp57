Thinpad 模板工程
---------------

工程包含示例代码和所有引脚约束，可以直接编译。

代码中包含中文注释，编码为utf-8，在Windows版Vivado下可能出现乱码问题。  
请用别的代码编辑器打开文件，并将编码改为GBK。

指令：

```asm
R:
ADD   0000000SSSSSsssss000ddddd0110011 1
XOR   0000000SSSSSsssss100ddddd0110011 1
OR    0000000SSSSSsssss110ddddd0110011 1
AND   0000000SSSSSsssss111ddddd0110011 1

I:
ADDI  iiiiiiiiiiiisssss000ddddd0010011 1
ORI   iiiiiiiiiiiisssss110ddddd0010011 1
ANDI  iiiiiiiiiiiisssss111ddddd0010011 1
SLLI  0000000iiiiisssss001ddddd0010011 1
SRLI  0000000iiiiisssss101ddddd0010011 1
LW    iiiiiiiiiiiisssss010ddddd0000011 2
LB    iiiiiiiiiiiisssss000ddddd0000011 2
JALR  iiiiiiiiiiiisssss000ddddd1100111 1

S:
SB    iiiiiiiSSSSSsssss000iiiii0100011 2
SW    iiiiiiiSSSSSsssss010iiiii0100011 2

B:
BEQ   iiiiiiiSSSSSsssss000iiiii1100011
BNE   iiiiiiiSSSSSsssss001iiiii1100011 

U:
LUI   iiiiiiiiiiiiiiiiiiiiddddd0110111 1
AUIPC iiiiiiiiiiiiiiiiiiiiddddd0010111 1

J:
JAL   iiiiiiiiiiiiiiiiiiiiddddd1101111 1

MINU  11000abSSSSSsssss010ddddd0101111
SBSET
XNOR
```
