#include "uart_hal.h"
#include "isa.h"
#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>

#define COM_PORT 3
#define BAUD_RATE 115200
#define INSTRUCTION_SIZE 3 // (bytes)
#define MATRIX_DIM 16   // matrix size is MATRIX_DIM x MATRIX_DIM
#define WEIGHT_BASE_ADDR 0x000    // weights
#define ACTIVATION_BASE_ADDR 0x100  // input activations
#define RESULT_BASE_ADDR 0x200    // output results
#define DONE_SIGNAL 0xAA // done signal from fpga after MAC finishes
#define RESULTS_SIZE 10


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
  
  // === Initialize UART Stuff === // 
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

  // === Load Weights === // 
  // LDR_W
  // indicates to control unit in FSM that data being sent is the weight data
  // knows to write that data to W_PTR in memory
  if (!send_instr(uart, isa::ldr_w(), "LDR_W")) return 1;

  // open file
  std::string weight_file_path = "bpTPU/host_side/data/weights.bin";
  std::ifstream weight_file(weight_file_path, std::ios::binary | std::ios::ate);  // ate sets read pointer to end of file
  if (!weight_file.is_open()){
    std::cerr << "ERROR: Couldn't open weights file. Filepath is " << weight_file_path << "\n";
    return 1; 
  }
  
  int weight_file_size = static_cast<int>(weight_file.tellg());  // file size in bytes using ate pointer
  weight_file.seekg(0, std::ios::beg); // set read pointer back to beginning
  std::vector<uint8_t> weight_file_vector; 
  weight_file_vector.resize(weight_file_size); 
  weight_file.read(reinterpret_cast<char*>(weight_file_vector.data()), weight_file_size); 
  int weight_file_bytes_written = uart.write_data(weight_file_vector);
  if (weight_file_bytes_written != weight_file_size) {
    std::cerr << "ERROR: Weight file transmitted the incorrect amount of bytes over UART. Expected " 
              << weight_file_size << " bytes, got " 
              << weight_file_bytes_written << " bytes.\n";
    return 1; 
  }

  // === Input Loading / Execution === //
  // MAC 
  // open input_activations.bin (same as weights logic)
  // create a new vector, send vector over uart
  // add a delay to let the matrix multiplier finish
  // OR (prob this) have fpga send a done signal over UART

  // MAC
  if (!send_instr(uart, isa::mac(), "MAC")) return 1; 

  // open file
  std::string activation_file_path = "bpTPU/host_side/data/input_activations.bin";
  std::ifstream activation_file(activation_file_path, std::ios::binary | std::ios::ate);
  if (!activation_file.is_open()) {
    std::cerr << "ERROR: Couldn't open activations file. Filepath is " << activation_file_path << "\n";
    return 1; 
  }

  int activation_file_size = static_cast<int>(activation_file.tellg());  

  activation_file.seekg(0, std::ios::beg); 

  std::vector<uint8_t> activation_file_vector; 
  activation_file_vector.resize(activation_file_size); 
  activation_file.read(reinterpret_cast<char*>(activation_file_vector.data()), activation_file_size); 

  int activation_file_bytes_written = uart.write_data(activation_file_vector);
  if (activation_file_bytes_written != activation_file_size) {
    std::cerr << "ERROR: Activation file transmitted the incorrect amount of bytes over UART. Expected " 
              << activation_file_size << " bytes, got " 
              << activation_file_bytes_written << " bytes.\n";
    return 1; 
  }

  // once activations are sent, delay until fpga sends done signal before reading results
  std::vector<uint8_t> read_buffer(1);
  bool is_done = false;
  while (!is_done){
    if (uart.read_data(read_buffer, 1) == 1){
      if (read_buffer[0] == DONE_SIGNAL){
        is_done = true;
      } else {
        std::clog << "WARNING: Received 0x" << std::hex << static_cast<int>(read_buffer[0])
                  << " while waiting for MAC to complete. Does not match the expected done signal 0x"
                  << static_cast<int>(DONE_SIGNAL) << std::dec << "\n";
      }
    } 

    // sleep cpu when polling for response
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
  } 


  // === Results === // 
  // TX_RD
  // create empty vector, size is whatever expected output is (eg. 10 bytes for 10 digits on mnist)
  // use .read_data()
  // find highest value in vector (result)
  // print all items in vector
  // do some python visualization shit

  // TX_RD
  // tell fpga to send results over uart
  if (!send_instr(uart, isa::tx_rd(), "TX_RD")) return 1; 

  std::vector<uint8_t> results_buffer(MATRIX_DIM);
  // should read MATRIX_DIM bytes bc results are that size, even if dataset results < 10
  int results_read_size = uart.read_data(results_buffer, MATRIX_DIM);
  if (results_read_size != MATRIX_DIM){  
    std::cerr << "ERROR: read incorrect number of bytes when reading results from fpga. Read "
              << results_read_size << "bytes, expected " << MATRIX_DIM << " bytes.\n"; 
    return 1; 
  }

  // find predicted result (highest percentage)
  uint8_t highest_val = 0x00;
  int predicted_digit = 0;  
  for (int i = 0; i < RESULTS_SIZE; i++){
    std::cout << i << ": " << static_cast<int>(results_buffer[i]) << "\n";
    if (results_buffer[i] > highest_val){
      highest_val = results_buffer[i];
      predicted_digit = i; 
    }
  }

  std::cout << "\nRESULT: " << predicted_digit 
            << "Confidence:" << static_cast<int>(highest_val) << "\n";

  return 0; 
}

