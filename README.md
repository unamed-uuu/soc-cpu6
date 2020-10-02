# soc1 implementing...

Currently, soc1 only has cpu6 and vga controller.

RISC-V RV32I(lw sw addi add sub beq bne jalr) four-stage pipeline. IFID, EX, MEM, WB.

csr registers mepc mtvec

csr instructions csrrw csrrs csrrc csrrwi csrrsi csrrci

No cache, 2-port RAM. 64KB

Video RAM 64KB  640 x 480  25MHz


# Exception 
illegal instruction


# Interrupts


# Vectors
Reset 0x00000000
Trap  0x00000004

----------------------------


# Directories

`````````````````
soc1
├── doc  		# Documents of simulation test cases
├── README.md
├── simulation          # Simulation test cases, using modelsim
├── soc			# Rtl code	
├── systhesis           # \altera\makefile                  
└── tb			# Testbench files for simulation test cases
`````````````````

# Compile
`````````````
cd systhesis/altera
make
`````````````
 (or make map)

# Run simulation tests
```````````````
cd simulation
./run_all_test.sh
```````````````

test2_addi_cpu_clk_initial_1 is supposed to fail. Others are not.

see doc/test*.md for details
