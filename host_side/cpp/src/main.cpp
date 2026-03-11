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

int main(){
  uart_hal uart;

  // open com port
  // slash stuff is a weird windows quirk when your com port is > 9
  std::string com_port_name = "\\\\.\\COM" + std::to_string(COM_PORT);
  if (!uart.open_port(com_port_name, BAUD_RATE)){
    std::cerr << "Can't open " << com_port_name << " at baud rate " << BAUD_RATE << "\n";
    return 1;
  }  

  // send data over uart
  // LDI K_DIM, #16 (loads dimension register with 16 to set matrix dimensions to 16 x 16)
  if (uart.write_data(isa::ldi(isa::reg_t::K_DIM, 16)) != INSTRUCTION_SIZE){   // 3 is number of bytes written
    std::cerr << "Write failed, did not send " << INSTRUCTION_SIZE << " bytes\n";
    return 1; 
  }    
  

  return 0; 
}

