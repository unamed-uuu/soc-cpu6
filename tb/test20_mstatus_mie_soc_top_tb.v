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
	 dut.u_uart.urx.rx_data_fresh <= 0; #800; dut.u_uart.urx.rx_data_fresh <= 1;
      end

   // generate clock to sequence tests
   always
      begin
	 clk <= 1; #5 ;clk <= 0; #5;
	 //dut.u_uart.urx.rx_data_fresh <= 1; #20; dut.u_uart.urx.rx_data_fresh <= 0; #20;
      end

   // check results
   always @(posedge clk)
      begin
	 if (1'b1 === dut.cpu_clk)
		begin
	    	$display("+");
	      // $display("lic.mtime %d", dut.u_lic.mtime_dfflr.qout);
	      // $display("lic.mtimecmp %d", dut.u_lic.mtimecmp_dfflr.qout);
	      // $display("csr.mie %x", dut.core.dp.csr.csr_mie);
	      // $display("csr.mtie_r %x", dut.core.dp.csr.csr_mtie_r);
	      // $display("lic.lic_timer_interrupt %x", dut.u_lic.lic_timer_interrupt);
	      // $display("excp.excp_flush_pc_ena %x", dut.core.excp.excp_flush_pc_ena);
	      // $display("excp.excp_flush_pc %x", dut.core.excp.excp_flush_pc);
	      // $display("core.pcnextF %x", dut.core.pcnextF);
	      // $display("core.pcreg %x", dut.core.pcreg.qout);
	      // $display("core.stallF %x", dut.core.stallF);
		end
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
	       $display("lic.mtime %d", dut.u_lic.mtime_dfflr.qout);
	       $display("lic.mtimecmp %d", dut.u_lic.mtimecmp_dfflr.qout);
	       $display("csr.mie %x", dut.core.dp.csr.csr_mie);
	       $display("csr.mtie_r %x", dut.core.dp.csr.csr_mtie_r);
	       $display("lic.lic_tmr_irq_r %x", dut.u_lic.lic_tmr_irq_r);
	       $display("excp.excp_flush_pc_ena %x", dut.core.excp.excp_flush_pc_ena);
	       $display("excp.excp_flush_pc %x", dut.core.excp.excp_flush_pc);
	       $display("core.pcnextF %x", dut.core.pcnextF);
	       $display("core.pcF %x", dut.core.pcF);
	       $display("core.stallF %x", dut.core.stallF);
	       $display("csr.mstatus.mie %x", dut.core.dp.csr.csr_mstatus_mie_r);
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

		// according to this test setting,
		// at 0xa0, the interrupt ext_irq_r is signaled 
		if (32'h00000a0 == dut.pc)  
		  begin
		     if (1'b1 == dut.core.dp.csr.csr_mstatus_mie_r)
			begin
			   //$display("test20_mstatus_mie simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("00000000000000");
			   $display("test20_mstatus_mie simulation FAILED");
			   $stop;
			end
		  end



		if (32'h00000158 == dut.pc) // trap entry
		  begin
		     if (1'b0 == dut.core.dp.csr.csr_mstatus_mie_r)
			begin
			   //$display("test20_mstatus_mie simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test20_mstatus_mie simulation FAILED");
			   $stop;
			end
		  end

		if (32'h0000019c == dut.pc) // no key pressed exit mret
		  begin             // there will be three 19c in the pipeline
		     if (//1'b0 == dut.core.dp.csr.csr_mstatus_mie_r &&
			 32'h000000a0 == dut.core.dp.csr.epc_dfflr.qout
			  )
			begin
			   //$display("test19_timer simulation SUCCESS");
			   //$stop;
			end
		     else
			begin
			   $display("test20_mstatus_mie simulation FAILED");
			   $stop;
			end
		  end



		// the interrupt should resume at 0xa0
		// if the interrupt resume at the faulting pc a0
		// meaning re-execute the fautling instruction twice
		// uty: debug
		// need to check if the faulting instruction is executed twice
		//if (32'h00000a0 == dut.pc)  
		//  begin
		//     if (32'h000000a0 == dut.core.dp.csr.epc_dfflr.qout)
		//	begin
		//	end
		//     else
		//	begin
		//	   $display("test20_mstatus_mie simulation FAILED");
		//	   $stop;
		//	end
		//  end


		// after interrupt handler mret, resume the previous execution
		if (32'h00000a0 == dut.pc &&
		    32'h000000a0 == dut.core.dp.csr.epc_dfflr.qout)  
		  begin
		     if (1'b1 == dut.core.dp.csr.csr_mstatus_mie_r)
			begin
			   $display("test20_mstatus_mie simulation SUCCESS");
			   $stop;
			end
		     else
			begin
			   $display("test20_mstatus_mie simulation FAILED");
			   $stop;
			end
		  end




//		if (267 === dut.u_lic.mtime_dfflr.qout)
//		  begin
//		     if (32'h0000009c === dut.pc)
//			begin
//			   $display("test19_timer simulation SUCCESS");
//			   $stop;
//			end
//		     else
//			begin
//			   $display("test19_timer simulation FAILED");
//			   $stop;
//			end
//		  end

	       //if (32'h00000024 === dut.pc) $stop; 	

	    end

      end
endmodule
