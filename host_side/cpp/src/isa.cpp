// take instructions, generate the data transmitted to the fpga over uart

#include "isa.h"

// for all instructions:
// big endian (msb first)
// vec[0] = opcode
// vec[1] = reg + imm[11:8]
// vec[2] = imm[7:0]
 
namespace isa {
  
  std::vector<uint8_t> ldi(reg_t reg, uint16_t imm){
    std::vector<uint8_t> ldi_vec; 
    ldi_vec.push_back(static_cast<uint8_t>(opcode_t::LDI)); // opcode
    ldi_vec.push_back(static_cast<uint8_t>(
      (static_cast<uint8_t>(reg) << 4) | ((imm >> 8) & 0x0F)  // (reg << 4) | imm[11:8]
    )); 
    ldi_vec.push_back(static_cast<uint8_t>(imm & 0x0FF)); // imm[7:0] (rest of imm)
    return ldi_vec; 
  }

  std::vector<uint8_t> ldr_w(){
    std::vector<uint8_t> ldr_w_vec;
    ldr_w_vec.push_back(static_cast<uint8_t>(opcode_t::LDR_W)); // opcode
    // no reg/imm
    ldr_w_vec.push_back(0x00);
    ldr_w_vec.push_back(0x00);
    return ldr_w_vec;
  }

  std::vector<uint8_t> mac(){
    std::vector<uint8_t> mac_vec;
    mac_vec.push_back(static_cast<uint8_t>(opcode_t::MAC)); // opcode
    // no reg/imm
    mac_vec.push_back(0x00);
    mac_vec.push_back(0x00);
    return mac_vec;
  }

  std::vector<uint8_t> tx_rd(){
    std::vector<uint8_t> tx_rd_vec;
    tx_rd_vec.push_back(static_cast<uint8_t>(opcode_t::TX_RD)); // opcode
    // no reg/imm
    tx_rd_vec.push_back(0x00);
    tx_rd_vec.push_back(0x00);
    return tx_rd_vec;
  }


}


