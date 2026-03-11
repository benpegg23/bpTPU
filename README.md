# bpTPU
WIP SystemVerilog implementation of a Google TPU-inspired systolic array accelerator on an FPGA (Urbana Board).

## ISA

#### Instruction Encoding
| Instruction  | Opcode (8 bits) `[23:16]` | Register (4 bits) `[15:12]` | Immediate (12 bits) `[11:0]` | Meaning
| :---- | :---- | :---- | :---- | :---- |
| **`LDI`** |  `00000001` | `<Reg ID>` | `<12-bit Value>` |Load Immediate  |
| **`LDR_W`** |  `00000010` | `0000` | `000000000000` | Load Weights  |
| **`MAC`** |  `00000011` | `0000` | `000000000000` | Multiply-Accumulate |
| **`TX_RD`** |   `00000100` | `0000` | `000000000000` | Transmit Read  |

#### Register Mapping

| Register Name | 4-bit ID | Function |
| :--- | :--- | :--- |
| **`W_PTR`** | `0000` | Base memory pointer for Weights |
| **`I_PTR`** | `0001` | Base memory pointer for Input Activations |
| **`O_PTR`** | `0010` | Base memory pointer for Output Results |
| **`K_DIM`** | `0011` | Matrix dimensions (`K_DIM` x `K_DIM`)|

*see* `bpTPU/host_side/cpp/include/isa_formatter.h` *for implementation details*