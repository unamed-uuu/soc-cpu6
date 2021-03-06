## Tic-Tac-Toe

It is the first game that runs on this RISC-V core. The soc does not have a keyboard controller. To input, it has to go through the UART.

The UART device only has one MMIO register that is the UART data register (uartdr) at 0x21000. It runs at baud-rate 9600, 8n1.

Tic-Tac-Toe does not require a timer. The big game loop keeps updating the text screen based on the game data. Every time a key strick arrives through the UART raises an interrupt, of which the handler updates game data accordingly. 

There is no CSR register to prevent the UART interrupts from reentering. Now I understand why the Intel x86 processor has the trap gate and interrupt gate mechanisms, and the only difference between these two is that the interrupt gate automatically disables interruption. For instance, the page fault handler is invoked through the interrupt gate because it gives the kernel opportunity to save the CR2 register. There is only one CR2 register on each core. If the page fault happens too soon, the new page fault overwrites it. It is possible. For example, if there is no disabling interruption, a thread context switch may occur right after a page fault exception. The new scheduled thread may trigger another page fault on this core.

On x86, when an interrupt happens, the processor hardware stores CS: EIP,  SS: ESP, error code on the kernel stack automatically. Then kernel stores other general registers on the kernel stacks too. In RISC-V specification, the \textit{mcause} is the equivalence of error code, \textit{mepc} as the EIP. So, nothing for kernel stack?

When interrupt reenters, the register used in the interrupt handler corrupts. That is why I set the baud-rate at 9600 instead of 115200 to give the handler more time to finish. But still, when pressing the key too fast, the game may freeze.


### Assembly code ###
````````
beq x0 x0 reset
beq x0 x0 trap

reset:
lw x6 1552(x0) # 0x184 data line 4, load the line 4 address in textram
lw x5 1564(x0) # 0x187  load Helloworld
sw x5 0(x6)
lw x5 1568(x0)
sw x5 4(x6)
lw x5 1572(x0)
sw x5 8(x6)
nop

game_loop:
#draw row 0 col 0
lw x4 1664(x0) # 0x1a0 game data row 0 col 0
lw x6 1600(x0) # 0x190 line 8
lw x5 1728(x4) # use tile
sw x5 0(x6)
lw x5 1732(x4)
sw x5 0x50(x6)
lw x5 1736(x4)
sw x5 0xa0(x6)


#draw row 0 col 1
lw x4 1668(x0) # 0x1a1 game data row 0 col 1
lw x6 1600(x0) # 0x190 line 8
lw x5 1728(x4) # tile
sw x5 0x4(x6)
lw x5 1732(x4)
sw x5 0x54(x6)
lw x5 1736(x4)
sw x5 0xa4(x6)


#draw row 0 col 2
lw x4 1672(x0) # 0x1a2 game data row 0 col 2
lw x6 1600(x0) # 0x190 line 8
lw x5 1728(x4) # tile
sw x5 0x8(x6)
lw x5 1732(x4)
sw x5 0x58(x6)
lw x5 1736(x4)
sw x5 0xa8(x6)



#draw row 1 col 0
lw x4 1676(x0) # 0x1a3 game data row 1 col 0
lw x6 1616(x0) # 0x194 line 12
lw x5 1728(x4) # use tile
sw x5 0(x6)
lw x5 1732(x4)
sw x5 0x50(x6)
lw x5 1736(x4)
sw x5 0xa0(x6)


#draw row 1 col 1
lw x4 1680(x0) # 0x1a4 game data row 1 col 1
lw x6 1616(x0) # 0x194 line 12
lw x5 1728(x4) # tile
sw x5 0x4(x6)
lw x5 1732(x4)
sw x5 0x54(x6)
lw x5 1736(x4)
sw x5 0xa4(x6)


#draw row 1 col 2
lw x4 1684(x0) # 0x1a5 game data row 1 col 2
lw x6 1616(x0) # 0x194 line 12
lw x5 1728(x4) # tile
sw x5 0x8(x6)
lw x5 1732(x4)
sw x5 0x58(x6)
lw x5 1736(x4)
sw x5 0xa8(x6)



#draw row 2 col 0
lw x4 1688(x0) # 0x1a6 game data row 2 col 0
lw x6 1632(x0) # 0x198 line 16
lw x5 1728(x4) # use tile
sw x5 0(x6)
lw x5 1732(x4)
sw x5 0x50(x6)
lw x5 1736(x4)
sw x5 0xa0(x6)


#draw row 2 col 1
lw x4 1692(x0) # 0x1a6 game data row 2 col 1
lw x6 1632(x0) # 0x198 line 16
lw x5 1728(x4) # tile
sw x5 0x4(x6)
lw x5 1732(x4)
sw x5 0x54(x6)
lw x5 1736(x4)
sw x5 0xa4(x6)


#draw row 2 col 2
lw x4 1696(x0) # 0x1a7 game data row 2 col 2
lw x6 1632(x0) # 0x198 line 16
lw x5 1728(x4) # tile
sw x5 0x8(x6)
lw x5 1732(x4)
sw x5 0x58(x6)
lw x5 1736(x4)
sw x5 0xa8(x6)


beq x0 x0 game_loop

loop_in_rest:
beq x0 x0 loop_in_rest

trap:
#lw x16 1560(x0) # 0x186 load screen line 6
#lw x18 1584(x0) # 0x18c load screen current column 0
lw x17 1576(x0) # 0x18a load uartdr address 0x21000
lw x15 0(x17)    # read uartdr
#add x19 x16 x18
#sw x15 0(x19)    # write textram
#sw x15 0(x17)    # write uartdr, echo back
#addi x18 x18 0x4 # next character column
#sw x18 1584(x0) # store current column

lw x16 1596(x0) # 0x18f current position

# x11 tmp

addi x11 x0 0x41
beq x11 x15 key_up
addi x11 x0 0x42
beq x11 x15 key_down
addi x11 x0 0x43
beq x11 x15 key_right
addi x11 x0 0x44
beq x11 x15 key_left
addi x11 x0 0x78
beq x11 x15 key_x
addi x11 x0 0x6f
beq x11 x15 key_o
addi x11 x0 0x72
beq x11 x15 key_r
nop            # mret 30200073

key_up:
addi x11 x0 1664 # 0x1a0 at left boarder
beq x11 x16 key_up_exit
addi x11 x0 1668 # 0x1a1
beq x11 x16 key_up_exit
addi x11 x0 1672 # 0x1a2
beq x11 x16 key_up_exit

#
lw x15 0x0(x16)
addi x11 x0 0x30
sub x15 x15 x11
sw x15 0x0(x16)     # current set to tile-3

addi x11 x0 0xc
sub x16 x16 x11   # mov to the upper spot

lw x15 0x0(x16)
addi x15 x15 0x30    
sw x15 0x0(x16)    # set to tile 3

sw x16 1596(x0) # 0x18f write current position back

key_up_exit:
nop   

key_down:
addi x11 x0 1688 # 0x1a6 at bottom boarder
beq x11 x16 key_down_exit
addi x11 x0 1692 # 0x1a7
beq x11 x16 key_down_exit
addi x11 x0 1696 # 0x1a8
beq x11 x16 key_down_exit

#
lw x15 0x0(x16)
addi x11 x0 0x30
sub x15 x15 x11
sw x15 0x0(x16)     # current set to tile-3

addi x16 x16 0xc   # mov to the spot bellow

lw x15 0x0(x16)
addi x15 x15 0x30 
sw x15 0x0(x16)    # set to tile+3

sw x16 1596(x0)    # 0x18f write current position back

key_down_exit:
nop            # mret 30200073   

key_left:
addi x11 x0 1664 # 0x1a0 at left boarder
beq x11 x16 key_left_exit
addi x11 x0 1676 # 0x1a3
beq x11 x16 key_left_exit
addi x11 x0 1688 # 0x1a6
beq x11 x16 key_left_exit

#
lw x15 0x0(x16)
addi x11 x0 0x30
sub x15 x15 x11
sw x15 0x0(x16)     # current set to tile-3

addi x11 x0 0x4
sub x16 x16 x11   # mov to the left spot

lw x15 0x0(x16)
addi x15 x15 0x30   
sw x15 0x0(x16)    # set to tile+3

sw x16 1596(x0) # 0x18f write current position back

key_left_exit:
nop            # mret 30200073

key_right:
addi x11 x0 1672 # 0x1a2 at right boarder
beq x11 x16 key_right_exit
addi x11 x0 1684 # 0x1a5
beq x11 x16 key_right_exit
addi x11 x0 1696 # 0x1a8
beq x11 x16 key_right_exit

# 
lw x15 0x0(x16)
addi x11 x0 0x30
sub x15 x15 x11
sw x15 0x0(x16)     # current set to tile-3

addi x16 x16 0x4   # mov to right spot

lw x15 0x0(x16)
addi x15 x15 0x30   
sw x15 0x0(x16)    # set to tile+3

sw x16 1596(x0) # 0x18f write current position back

key_right_exit:
nop            # mret 30200073


key_x:
lw x15 0x0(x16)
addi x11 x0 0x30
bne x15 x11 key_x_exit # if not tile-3, which is empty

addi x15 x0 0x40   
sw x15 0x0(x16)    # set to tile 4
key_x_exit:
nop            # mret 30200073


key_o:
lw x15 0x0(x16)
addi x11 x0 0x30
bne x15 x11 key_o_exit # if not tile-3, which is empty

addi x15 x0 0x50   
sw x15 0x0(x16)    # set to tile 5
key_o_exit:
nop            # mret 30200073

key_r:
# reset game data
addi x15 x0 0x30
sw x15 1664(x0)
sw x0 1668(x0)
sw x0 1672(x0)
sw x0 1676(x0)
sw x0 1680(x0)
sw x0 1684(x0)
sw x0 1688(x0)
sw x0 1692(x0)
sw x0 1696(x0)
# reset current position
addi x11 x0 1664 # 0x1a0
sw x11 1596(x0) 
nop            # mret 30200073

````````

### ram.mif ###
````````
-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- Quartus II generated Memory Initialization File (.mif)

WIDTH=32;
DEPTH=2048;

ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;

CONTENT BEGIN


	0:		00000463;  --		beq x0 x0 8 <reset>
	1:		14000663;  --		beq x0 x0 332 <trap>

--  <reset>:
	2:		61002303;  --		lw x6 1552(x0)   # 0x184 data line 4, load the line 4 address in textram
	3:		61c02283;  --		lw x5 1564(x0)   # 0x187  load Helloworld
	4:		00532023;  --		sw x5 0(x6)
	5:		62002283;  --		lw x5 1568(x0)
	6:		00532223;  --		sw x5 4(x6)
	7:		62402283;  --		lw x5 1572(x0)
	8:		00532423;  --		sw x5 8(x6)
	9:		00000013;  --		nop


--  <game_loop>:
	a:		68002203;  --		lw x4 1664(x0)
	b:		64002303;  --		lw x6 1600(x0)
	c:		6c022283;  --		lw x5 1728(x4)
	d:		00532023;  --		sw x5 0(x6)
	e:		6c422283;  --		lw x5 1732(x4)
	f:		04532823;  --		sw x5 80(x6)
	10:		6c822283;  --		lw x5 1736(x4)
	11:		0a532023;  --		sw x5 160(x6)
	12:		68402203;  --		lw x4 1668(x0)
	13:		64002303;  --		lw x6 1600(x0)
	14:		6c022283;  --		lw x5 1728(x4)
	15:		00532223;  --		sw x5 4(x6)
	16:		6c422283;  --		lw x5 1732(x4)
	17:		04532a23;  --		sw x5 84(x6)
	18:		6c822283;  --		lw x5 1736(x4)
	19:		0a532223;  --		sw x5 164(x6)
	1a:		68802203;  --		lw x4 1672(x0)
	1b:		64002303;  --		lw x6 1600(x0)
	1c:		6c022283;  --		lw x5 1728(x4)
	1d:		00532423;  --		sw x5 8(x6)
	1e:		6c422283;  --		lw x5 1732(x4)
	1f:		04532c23;  --		sw x5 88(x6)
	20:		6c822283;  --		lw x5 1736(x4)
	21:		0a532423;  --		sw x5 168(x6)

	22:		68c02203;  --		lw x4 1676(x0)
	23:		65002303;  --		lw x6 1616(x0)
	24:		6c022283;  --		lw x5 1728(x4)
	25:		00532023;  --		sw x5 0(x6)
	26:		6c422283;  --		lw x5 1732(x4)
	27:		04532823;  --		sw x5 80(x6)
	28:		6c822283;  --		lw x5 1736(x4)
	29:		0a532023;  --		sw x5 160(x6)
	2a:		69002203;  --		lw x4 1680(x0)
	2b:		65002303;  --		lw x6 1616(x0)
	2c:		6c022283;  --		lw x5 1728(x4)
	2d:		00532223;  --		sw x5 4(x6)
	2e:		6c422283;  --		lw x5 1732(x4)
	2f:		04532a23;  --		sw x5 84(x6)
	30:		6c822283;  --		lw x5 1736(x4)
	31:		0a532223;  --		sw x5 164(x6)
	32:		69402203;  --		lw x4 1684(x0)
	33:		65002303;  --		lw x6 1616(x0)
	34:		6c022283;  --		lw x5 1728(x4)
	35:		00532423;  --		sw x5 8(x6)
	36:		6c422283;  --		lw x5 1732(x4)
	37:		04532c23;  --		sw x5 88(x6)
	38:		6c822283;  --		lw x5 1736(x4)
	39:		0a532423;  --		sw x5 168(x6)

	3a:		69802203;  --		lw x4 1688(x0)
	3b:		66002303;  --		lw x6 1632(x0)
	3c:		6c022283;  --		lw x5 1728(x4)
	3d:		00532023;  --		sw x5 0(x6)
	3e:		6c422283;  --		lw x5 1732(x4)
	3f:		04532823;  --		sw x5 80(x6)
	40:		6c822283;  --		lw x5 1736(x4)
	41:		0a532023;  --		sw x5 160(x6)
	42:		69c02203;  --		lw x4 1692(x0)
	43:		66002303;  --		lw x6 1632(x0)
	44:		6c022283;  --		lw x5 1728(x4)
	45:		00532223;  --		sw x5 4(x6)
	46:		6c422283;  --		lw x5 1732(x4)
	47:		04532a23;  --		sw x5 84(x6)
	48:		6c822283;  --		lw x5 1736(x4)
	49:		0a532223;  --		sw x5 164(x6)
	4a:		6a002203;  --		lw x4 1696(x0)
	4b:		66002303;  --		lw x6 1632(x0)
	4c:		6c022283;  --		lw x5 1728(x4)
	4d:		00532423;  --		sw x5 8(x6)
	4e:		6c422283;  --		lw x5 1732(x4)
	4f:		04532c23;  --		sw x5 88(x6)
	50:		6c822283;  --		lw x5 1736(x4)
	51:		0a532423;  --		sw x5 168(x6)
	52:		ee0000e3;  --		beq x0 x0 -288 <game_loop>

--  <loop_in_rest>:
	53:		00000063;  --		beq x0 x0 0 <loop_in_rest>


--  <trap>:
	54:		62802883;  --		lw x17 1576(x0)
	55:		0008a783;  --		lw x15 0(x17)
	56:		63c02803;  --		lw x16 1596(x0)
	57:		04100593;  --		addi x11 x0 65
	58:		02f58c63;  --		beq x11 x15 56 <key_up>
	59:		04200593;  --		addi x11 x0 66
	5a:		06f58a63;  --		beq x11 x15 116 <key_down>
	5b:		04300593;  --		addi x11 x0 67
	5c:		0ef58863;  --		beq x11 x15 240 <key_right>
	5d:		04400593;  --		addi x11 x0 68
	5e:		0af58263;  --		beq x11 x15 164 <key_left>
	5f:		07800593;  --		addi x11 x0 120
	60:		12f58063;  --		beq x11 x15 288 <key_x>
	61:		06f00593;  --		addi x11 x0 111
	62:		12f58863;  --		beq x11 x15 304 <key_o>
	63:		07200593;  --		addi x11 x0 114
	64:		14f58063;  --		beq x11 x15 320 <key_r>
	65:		30200073;  --           mret

-- 00000190 <key_up>:

	66:		68000593;  --		addi x11 x0 1664
	67:		03058e63;  --		beq x11 x16 60 <key_up_exit>
	68:		68400593;  --		addi x11 x0 1668
	69:		03058a63;  --		beq x11 x16 52 <key_up_exit>
	6a:		68800593;  --		addi x11 x0 1672
	6b:		03058663;  --		beq x11 x16 44 <key_up_exit>
	6c:		00082783;  --		lw x15 0(x16)
	6d:		03000593;  --		addi x11 x0 48
	6e:		40b787b3;  --		sub x15 x15 x11
	6f:		00f82023;  --		sw x15 0(x16)
	70:		00c00593;  --		addi x11 x0 12
	71:		40b80833;  --		sub x16 x16 x11
	72:		00082783;  --		lw x15 0(x16)
	73:		03078793;  --		addi x15 x15 48
	74:		00f82023;  --		sw x15 0(x16)
	75:		63002e23;  --		sw x16 1596(x0)

-- 000001c0 <key_up_exit>:
	76:		30200073;  --           mret


-- 00000194 <key_down>:

	77:		69800593;  --		addi x11 x0 1688
	78:		03058c63;  --		beq x11 x16 56 <key_down_exit>
	79:		69c00593;  --		addi x11 x0 1692
	7a:		03058863;  --		beq x11 x16 48 <key_down_exit>
	7b:		6a000593;  --		addi x11 x0 1696
	7c:		03058463;  --		beq x11 x16 40 <key_down_exit>
	7d:		00082783;  --		lw x15 0(x16)
	7e:		03000593;  --		addi x11 x0 48
	7f:		40b787b3;  --		sub x15 x15 x11
	80:		00f82023;  --		sw x15 0(x16)
	81:		00c80813;  --		addi x16 x16 12
	82:		00082783;  --		lw x15 0(x16)
	83:		03078793;  --		addi x15 x15 48
	84:		00f82023;  --		sw x15 0(x16)
	85:		63002e23;  --		sw x16 1596(x0)

-- 000001c0 <key_down_exit>:
	86:		30200073;  --           mret

-- 00000198 <key_left>:

	87:		68000593;  --		addi x11 x0 1664
	88:		03058e63;  --		beq x11 x16 60 <key_left_exit>
	89:		68c00593;  --		addi x11 x0 1676
	8a:		03058a63;  --		beq x11 x16 52 <key_left_exit>
	8b:		69800593;  --		addi x11 x0 1688
	8c:		03058663;  --		beq x11 x16 44 <key_left_exit>
	8d:		00082783;  --		lw x15 0(x16)
	8e:		03000593;  --		addi x11 x0 48
	8f:		40b787b3;  --		sub x15 x15 x11
	90:		00f82023;  --		sw x15 0(x16)
	91:		00400593;  --		addi x11 x0 4
	92:		40b80833;  --		sub x16 x16 x11
	93:		00082783;  --		lw x15 0(x16)
	94:		03078793;  --		addi x15 x15 48
	95:		00f82023;  --		sw x15 0(x16)
	96:		63002e23;  --		sw x16 1596(x0)

-- 000001c8 <key_left_exit>:
	97:		30200073;  --           mret

-- 0000019c <key_right>:

	98:		68800593;  --		addi x11 x0 1672
	99:		03058c63;  --		beq x11 x16 56 <key_right_exit>
	9a:		69400593;  --		addi x11 x0 1684
	9b:		03058863;  --		beq x11 x16 48 <key_right_exit>
	9c:		6a000593;  --		addi x11 x0 1696
	9d:		03058463;  --		beq x11 x16 40 <key_right_exit>
	9e:		00082783;  --		lw x15 0(x16)
	9f:		03000593;  --		addi x11 x0 48
	a0:		40b787b3;  --		sub x15 x15 x11
	a1:		00f82023;  --		sw x15 0(x16)
	a2:		00480813;  --		addi x16 x16 4
	a3:		00082783;  --		lw x15 0(x16)
	a4:		03078793;  --		addi x15 x15 48
	a5:		00f82023;  --		sw x15 0(x16)
	a6:		63002e23;  --		sw x16 1596(x0)

-- 000001c8 <key_right_exit>:
	a7:		30200073;  --           mret


-- 000001cc <key_x>:
	a8:		00082783;  --		lw x15 0(x16)
	a9:		03000593;  --		addi x11 x0 48
	aa:		00b79663;  --		bne x15 x11 12 <key_x_exit>
	ab:		04000793;  --		addi x15 x0 64
	ac:		00f82023;  --		sw x15 0(x16)
	ad:		30200073;  --           mret

-- 000001d0 <key_o>:
	ae:		00082783;  --		lw x15 0(x16)
	af:		03000593;  --		addi x11 x0 48
	b0:		00b79663;  --		bne x15 x11 12 <key_o_exit>
	b1:		05000793;  --		addi x15 x0 80
	b2:		00f82023;  --		sw x15 0(x16)
	b3:		30200073;  --           mret

-- 000002d0 <key_r>:
	b4:		03000793;  --		addi x15 x0 48
	b5:		68f02023;  --		sw x15 1664(x0)
	b6:		68002223;  --		sw x0 1668(x0)
	b7:		68002423;  --		sw x0 1672(x0)
	b8:		68002623;  --		sw x0 1676(x0)
	b9:		68002823;  --		sw x0 1680(x0)
	ba:		68002a23;  --		sw x0 1684(x0)
	bb:		68002c23;  --		sw x0 1688(x0)
	bc:		68002e23;  --		sw x0 1692(x0)
	bd:		6a002023;  --		sw x0 1696(x0)
	be:		68000593;  --		addi x11 x0 1664
	bf:		62b02e23;  --		sw x11 1596(x0)
	c0:		30200073;  --           mret


	[c1..17F] :     00000000;

-- <data>:

	180  :   00010000;      -- data line 0
	181  :   00010050;      -- data line 1
	182  :   000100a0;      -- data line 2
	183  :   000100f0;      -- data line 3
	184  :   00010140;      -- data line 4
	185  :   00010190;      -- data line 5
	186  :   000101e0;      -- data line 6

	187  :   2d636954;  -- "Tic-Tac-Toe"
	188  :   2d636154;
	189  :   03656f54; 
	18a  :   00021000;  -- mmio uartdr
	18b  :   000101e0;  -- current line, line 6
	18c  :   00000000;  -- current column
	18d  :   2a2a2a2a;  -- ascii '****'
	18e  :   00000000;
	18f  :   00000680;  -- current position, reset 1a0, row 0 col 0



	190  :   00010280;      -- data line 8
	191  :   000102d0;      -- data line 9
	192  :   00010320;      -- data line 10
	193  :   00010370;      -- data line 11
	194  :   000103c0;      -- data line 12
	195  :   00010410;      -- data line 13
	196  :   00010460;      -- data line 14
	197  :   000104b0;      -- data line 15
	198  :   00010500;      -- data line 16
	199  :   00010550;      -- data line 17
	19a  :   000105a0;      -- data line 18
	19b  :   00000000;
	19c  :   00000000;
	19d  :   00000000;
	19e  :   00000000;
	19f  :   00000000;

-- ; game data

	1a0  :   00000030;  -- row 0
	1a1  :   00000000;
	1a2  :   00000000;

	1a3  :   00000000;  -- row 1
	1a4  :   00000000;
	1a5  :   00000000;

	1a6  :   00000000;  -- row 2
	1a7  :   00000000;
	1a8  :   00000000;


	[1a9..1af]  :   00000000;

-- ; tile data

			    --  tile 0
	1b0  :   00000000;  --     
	1b1  :   00000700;  --   .   
	1b2  :   00000000;  --     
	1b3  :   00000000;

                            --  tile 1
	1b4  :   002F005C;  --  \ /  
	1b5  :   00005C00;  --   / 
	1b6  :   005C002F;  --  / \
	1b7  :   00000000;

                            --  tile 2
	1b8  :   00002D00;  --   - 
	1b9  :   00290028;  --  ( )
	1ba  :   00002D00;  --   - 
	1bb  :   00000000;

                            --  tile 3
	1bc  :   00000000;  --    
	1bd  :   00000700;  --   .
	1be  :   005F5F5F;  --  ___ 
	1bf  :   00000000;

                            --  tile 4
	1c0  :   002F005C;  --  \ /  
	1c1  :   00005C00;  --   / 
	1c2  :   005F5F5F;  --  ___
	1c3  :   00000000;

                            --  tile 5
	1c4  :   00002D00;  --   - 
	1c5  :   00290028;  --  O O
	1c6  :   005F5F5F;  --  ___
	1c7  :   00000000;


	[1c8..7FF]  :   00000000;

END;

````````

### Screenshot ###

![tic-tac-toe](image/tic-tac-toe.jpg)
