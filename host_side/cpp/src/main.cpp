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

int main(){
  uart_hal uart;

  // open com port
  std::string com_port_name = "COM" + std::to_string(COM_PORT);
  if (!uart.open_port(com_port_name, BAUD_RATE)){
    std::cerr << "Can't open " << com_port_name << " at baud rate " << BAUD_RATE << "\n";
    return 1;
  }  

  // create data to send
  isa::ldi(isa::reg_t::K_DIM, 16);  // LDI K_DIM, 16 (loads dimension register with 16 to set matrix dimensions to 16 x 16)  
  

  return 0; 
}

