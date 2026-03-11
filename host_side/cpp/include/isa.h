#pragma once

#include <windows.h>
#include <cstdint>
#include <string>
#include <vector>

/*
==== ISA DEFINITION =====
- 24-bit (3-byte) instruction length
- reg-imm instruction structure
- 8-bit opcodes
- 4-bit register IDs
- 12-bit immediate values

Instruction layout:
| opcode  | reg ID  |  imm   |
| [23:16] | [15:12] | [11:0] |

Opcodes:
0x01 (00000001): LDI, load immediate. Writes 12-bit imm value into specified register.
0x02 (00000010): LDR_W, load weights. Moves FGPA control unit fsm from instr fetch to data fetch.
0x03 (00000011): MAC, multiply-accumulate. Tells FGPA to start fetch activation bytes, start matrix multiplication. 
0x04 (00000100): TX_RD, transmit read. Tells FPGA to transmit result over UART TX line.  

Register Mapping:
0x0 (0000), W_PTR: Base memory address pointer for weights
0x1 (0001), I_PTR: Base memory address pointer for input activations
0x2 (0010), O_PTR: Base memory address pointer for outputs 
0x3 (0100), K_DIM: Defines dimensions of matrix (K x K)

UART config is 8N1 (8 data bits, no parity bit, 1 stop bit)
Therefore we need to send 24-bit instructions as 3 vectors
Assuming big endian (msb first)
byte[0] = instr[23:16] (opcode)
byte[1] = instr[15:8] (reg + part of imm)
byte[2] = instr[7:0] (rest of imm) 


*/

namespace isa{
    enum class opcode_t : uint8_t {
      LDI = 0x01,
      LDR_W = 0x02,
      MAC = 0x03, 
      TX_RD = 0x04
    };

    enum class reg_t : uint8_t {
      W_PTR = 0x00,
      I_PTR = 0x01,
      O_PTR = 0x02,
      K_DIM = 0x03
    };

    std::vector<uint8_t> ldi(reg_t reg, uint16_t imm);
    std::vector<uint8_t> ldr_w();
    std::vector<uint8_t> mac();
    std::vector<uint8_t> tx_rd(); 
}