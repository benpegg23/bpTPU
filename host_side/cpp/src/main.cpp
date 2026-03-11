// parse cli arguments
// open data/<>.bin files
// use isa_formatter.cpp to build execution sequence
// push through uart_hal.cpp
// write fpga response to output_results.bin

#include "uart_hal.h"
#include "isa.h"
#include <iostream>

#define COM_PORT 3
#define BAUD_RATE 115200
#define INSTRUCTION_SIZE 3 // (bytes)
#define MATRIX_DIM 16   // matrix size is MATRIX_DIM x MATRIX_DIM
#define WEIGHT_BASE_ADDR 0x000    // weights
#define ACTIVATION_BASE_ADDR 0x100  // input activations
#define RESULT_BASE_ADDR 0x200    // output results


// helper function to call instructions and do error checking
bool send_instr(uart_hal& uart, const std::vector<uint8_t>& instr_encoded, const std::string& instr_name){
  int bytes_written = uart.write_data(instr_encoded);
  
  if (bytes_written != INSTRUCTION_SIZE){
    std::cerr << "ERROR: " << instr_name << " failed. Sent " << bytes_written << " bytes instead of " << INSTRUCTION_SIZE << "\n";
    return false; 
  }

  return true; 
}



int main(){
  uart_hal uart;

  // open com port
  // slash stuff is a weird windows quirk when your com port is > 9
  std::string com_port_name = "\\\\.\\COM" + std::to_string(COM_PORT);
  if (!uart.open_port(com_port_name, BAUD_RATE)){
    std::cerr << "ERROR: Can't open " << com_port_name << " at baud rate " << BAUD_RATE << "\n";
    return 1;
  }  

  // === Initialize regs === // 
  // LDI K_DIM, #(MATRIX_DIM) (loads dimension register with MATRIX_DIM to set matrix dimensions to M_D x M_D)
  if (!send_instr(uart, isa::ldi(isa::reg_t::K_DIM, MATRIX_DIM), "LDI K_DIM")) return 1; 
  // LDI W_PTR, #(WEIGHT_BASE_ADDR)
  if (!send_instr(uart, isa::ldi(isa::reg_t::W_PTR, WEIGHT_BASE_ADDR), "LDI W_PTR")) return 1; 
  // LDI I_PTR, #(ACTIVATION_BASE_ADDR)
  if (!send_instr(uart, isa::ldi(isa::reg_t::I_PTR, ACTIVATION_BASE_ADDR), "LDI I_PTR")) return 1;
  // LDI O_PTR, #(RESULT_BASE_ADDR)
  if (!send_instr(uart, isa::ldi(isa::reg_t::O_PTR, RESULT_BASE_ADDR), "LDI O_PTR")) return 1;

  // === Load weights === // 
  // LDR_W 
  // use ifstream to open weights.bin in binary mode
  // find byte size
  // allocate a vector<uint8_t> of the same size
  // read mem contents into vector
  // transmit vector over uart

  return 0; 
}

