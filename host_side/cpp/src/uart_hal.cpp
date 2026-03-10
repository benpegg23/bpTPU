// handle usb driver stuff

#include "uart_hal.h"

uart_hal::uart_hal(){
  HANDLE hSerial = INVALID_HANDLE_VALUE;  // initialize hserial, start in safe state
};

uart_hal::~uart_hal(){
  close_port();
};

bool uart_hal::open_port(const std::string& port_name, unsigned long baud_rate){

  std::string port_formatted = "\\\\.\\" + port_name; 

  // hardware handle
  hSerial = CreateFileA(
    port_formatted.c_str(),
    GENERIC_READ | GENERIC_WRITE,
    0,      // exclusive access
    NULL,   // default security
    OPEN_EXISTING,
    0,      // non-overlapped (synchronous) I/O
    NULL
  );

  if (hSerial == INVALID_HANDLE_VALUE) {
    return false;
  }

  // device control block
  DCB dcbSerialParams = {0};
  dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

  if (!GetCommState(hSerial, &dcbSerialParams)) {
    CloseHandle(hSerial);
    hSerial = INVALID_HANDLE_VALUE;
    return false;
  }

  dcbSerialParams.BaudRate = baud_rate;
  dcbSerialParams.ByteSize = 8;
  dcbSerialParams.StopBits = ONESTOPBIT;
  dcbSerialParams.Parity   = NOPARITY;

  if (!SetCommState(hSerial, &dcbSerialParams)) {
    CloseHandle(hSerial);
    hSerial = INVALID_HANDLE_VALUE;
    return false;
  }

  // timeouts
  // read_file will return immediately if there is data, or wait until data arrives
  COMMTIMEOUTS timeouts = {0};
  timeouts.ReadIntervalTimeout         = MAXDWORD;
  timeouts.ReadTotalTimeoutConstant    = 0;
  timeouts.ReadTotalTimeoutMultiplier  = 0;
  timeouts.WriteTotalTimeoutConstant   = 50;
  timeouts.WriteTotalTimeoutMultiplier = 10;

  if (!SetCommTimeouts(hSerial, &timeouts)) {
      CloseHandle(hSerial);
      hSerial = INVALID_HANDLE_VALUE;
      return false;
  }

  return true;
};  

void uart_hal::close_port(){
  if (hSerial != INVALID_HANDLE_VALUE) {
    CloseHandle(hSerial);
    hSerial = INVALID_HANDLE_VALUE;
  }
};

int uart_hal::write_data(const std::vector<uint8_t>& data){
  if (hSerial == INVALID_HANDLE_VALUE) {
    return -1;
  }

  DWORD bytes_written = 0;
  
  // WriteFile needs raw pointer to the memory array
  BOOL success = WriteFile(
    hSerial,
    data.data(),  // .data() function gets uint8_t* from data (the vector)
    static_cast<DWORD>(data.size()), 
    &bytes_written,
    NULL
  );

  if (!success) {
    return -1; 
  }

  return static_cast<int>(bytes_written);
};

int uart_hal::read_data(std::vector<uint8_t>& buffer, size_t length){
  if (hSerial == INVALID_HANDLE_VALUE) {
    return -1;
  }

  // allocate vector memory to prevent buffer overflows when passing pointer to os
  buffer.resize(length);

  DWORD bytes_read = 0;

  BOOL success = ReadFile(
    hSerial,
    buffer.data(),
    static_cast<DWORD>(length),
    &bytes_read,
    NULL
  );

  if (!success) {
    buffer.clear(); 
    return -1;    
  }

  // shrink vector to match actual valid bytes recieved
  buffer.resize(bytes_read);

  return static_cast<int>(bytes_read);
};

