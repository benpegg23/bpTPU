package types

typedef enum logic {
	1'b0 = activation_data,
	1'b1 = relu_output
} activation_mux_t; 

typedef enum logic [2:0] {
	s_idle = 3'b000, 
	s_decode = 3'b001, 
	s_load = 3'b010,
	s_compute = 3'b011, 
	s_transmit = 3'b100	
} state_t; 

typedef enum logic [7:0] {
	op_ldi = 8'h01,
	op_ldr_w = 8'h02,
	op_mac   = 8'h03,
    op_tx_rd = 8'h04
} opcode_t; 

// isa regs
typedef enum logic [3:0] {
    reg_w_ptr = 4'h0,
    reg_i_ptr = 4'h1,
    reg_o_ptr = 4'h2,
    reg_k_dim = 4'h3
} reg_id_t;


endpackage
