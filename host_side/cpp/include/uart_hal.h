#include <windows.h>
#include <cstdint>
#include <string>
#include <vector>

class uart_hal {
  public:
    // constructor/destructor 
    uart_hal();
    ~uart_hal();

    // open COM port, initialize baud rate 
    bool open_port(const std::string& port_name, unsigned long baud_rate);  // win32 api defines baud_rate as an unsigned long

    // close COM port
    void close_port();

    // transmit bytes, returns bytes written, -1 on error
    int write_data(const std::vector<uint8_t>& data);

    int read_data(std::vector<uint8_t>& buffer, size_t length);

  private: 
    HANDLE hSerial;   // handle is windows typedef for void*
};
