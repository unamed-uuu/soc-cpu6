`include "../soc/cpu6/defines.v"

// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module soc_top_tb();

   reg clk;
   reg reset;

   wire [2:0] vga_rgb;
   wire vga_hsync;
   wire vga_vsync;

   //wire [`CPU6_XLEN-1:0] writedata, dataadr;
   //wire memwrite;

   // instantiate device to be tested
   soc_top dut(clk, reset, vga_rgb, vga_hsync, vga_vsync);

   // initialize test
   initial
      begin
	 $display("Start ...");
	 dut.cpu_clk = 0;
	 dut.vga_clk = 0;
	 reset <= 0; #22; reset <= 1;
      end

   // generate clock to sequence tests
   always
      begin
	 clk <= 1; #5 ;clk <= 0; #5;
      end

   // check results
   always @(posedge clk)
      begin
	 if (1'b1 === dut.cpu_clk)
	    $display("+");
      end
   
   always @(negedge clk)
      begin
	 if (1'b0 === dut.cpu_clk)
	    begin
	       $display("-");
	       $display("reset %b", reset);
	       $display("cpu_clk %b", dut.cpu_clk);
	       $display("pc %x", dut.pc);
	       $display("vga_rgb %b", vga_rgb);
	       $display("reg[1] %x", dut.core.dp.rf.regs[1].other_regs.rf_dffl.qout);
	       $display("reg[2] %x", dut.core.dp.rf.regs[2].other_regs.rf_dffl.qout);
	       $display("reg[3] %x", dut.core.dp.rf.regs[3].other_regs.rf_dffl.qout);
	       $display("reg[4] %x", dut.core.dp.rf.regs[4].other_regs.rf_dffl.qout);
	       $display("reg[5] %x", dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout);
	       $display("reg[6] %x", dut.core.dp.rf.regs[6].other_regs.rf_dffl.qout);
	       $display("reg[7] %x", dut.core.dp.rf.regs[7].other_regs.rf_dffl.qout);
	       $display("reg[8] %x", dut.core.dp.rf.regs[8].other_regs.rf_dffl.qout);
	       $display("reg[9] %x", dut.core.dp.rf.regs[9].other_regs.rf_dffl.qout);
	       $display("mepc %x", dut.core.dp.csr.epc_dfflr.qout);
	       $display("dp.pcE %x", dut.core.dp.pcE);
	       $display("dp.core.excp_illinstr %x", dut.core.excp_illinstr);
	       //$display("reg[5] %x", dut.core.dp.rf.rf_r[5]);
	       // if (memwrite) begin
	       //     if (dataadr === 84 & writedata === 7) begin
	       //         $display("Simulation succeeded");
	       //         $stop;
	       //     end else if (dataadr !== 80) begin
	       //         $display("Simulation failed");
	       //         $stop;
	       //     end
	       // end     

	       if (32'h00000040 === dut.pc) 	
		  begin
		     if (32'h0000000e === dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   //$display("test17_read_write_mtime simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test17_read_write_mtime simulation FAILED");
			   $stop;
			end
		  end

	       if (32'h00000070 === dut.pc) 	
		  begin
		     if (32'h30303036 === dut.core.dp.rf.regs[5].other_regs.rf_dffl.qout)
			begin
			   $display("test17_read_write_mtime simulation SUCCESS");
			   $stop;
			end
		     else
			begin
			   $display("test17_read_write_mtime simulation FAILED");
			   $stop;
			end
		  end

	       //if (32'h00000024 === dut.pc) $stop; 	

	    end

      end
endmodule
