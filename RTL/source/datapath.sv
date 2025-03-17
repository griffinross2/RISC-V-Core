`timescale 1ns/1ns

`include "common_types.vh"
import common_types_pkg::*;
`include "cpu_ram_if.vh"

// interfaces (module)
`include "control_unit_if.vh"
`include "alu_if.vh"
`include "multiplier_if.vh"
`include "register_file_if.vh"
`include "hazard_unit_if.vh"
`include "forward_unit_if.vh"
`include "branch_unit_if.vh"

// interface (pipeline)
`include "fetch_to_decode_if.vh"
`include "decode_to_execute_if.vh"
`include "execute_to_memory_if.vh"
`include "memory_to_writeback_if.vh"

module datapath #(
  parameter PC_INIT = 0
)(
  input logic clk, nrst,
  output logic halt,
  cpu_ram_if.cpu cpu_ram_if
);
  parameter NOP = 32'h00000013;

  word_t pc;
  word_t pc_n;
  word_t forwarded_rdat1;
  word_t forwarded_rdat2;

  // Interface instantiation
  control_unit_if ctrlif();
  alu_if aluif();
  multiplier_if mulif();
  register_file_if rfif();
  hazard_unit_if hazif();
  forward_unit_if fuif();
  branch_unit_if buif();

  // Module instantiation
  (* keep_hierarchy = "yes" *) control_unit ctrl0(ctrlif);
  (* keep_hierarchy = "yes" *) alu alu0(aluif);
  (* keep_hierarchy = "yes" *) multiplier mul0(clk, nrst, mulif);
  (* keep_hierarchy = "yes" *) register_file rf0(clk, nrst, rfif);
  (* keep_hierarchy = "yes" *) hazard_unit haz0(hazif);
  (* keep_hierarchy = "yes" *) forward_unit for0(fuif);
  (* keep_hierarchy = "yes" *) branch_unit bu0(clk, nrst, buif);

  fetch_to_decode_if      f2dif();
  decode_to_execute_if    d2eif();
  execute_to_memory_if    e2mif();
  memory_to_writeback_if  m2wif();

  // Hazard Unit to Pipeline
  always_comb begin
    // Enable signals
    // If any following stage is stalled, the preceeding ones will be stalled.
    // Otherwise, the stages could crash into eachother.
    f2dif.en = hazif.f2dif_en;
    d2eif.en = hazif.d2eif_en;
    e2mif.en = hazif.e2mif_en;
    m2wif.en = hazif.m2wif_en;

    // Flush signals
    f2dif.flush = hazif.f2dif_flush;
    d2eif.flush = hazif.d2eif_flush;
    e2mif.flush = hazif.e2mif_flush;
    m2wif.flush = hazif.m2wif_flush;
    
    // Signals from other modules to the hazard unit
    hazif.halt = m2wif.halt;
    hazif.dread = e2mif.dread;
    hazif.dwrite = |e2mif.dwrite;
    hazif.dhit = ~cpu_ram_if.dwait;
    hazif.ihit = ~cpu_ram_if.iwait;
    hazif.d2eif_dread = d2eif.dread;
    hazif.f2dif_rs1 = ctrlif.rs1;
    hazif.f2dif_rs2 = ctrlif.rs2;
    hazif.d2eif_rd = d2eif.rd;
    hazif.d2eif_mult = d2eif.mult;
    hazif.mult_ready = mulif.ready;
    hazif.branch_flush = buif.mem_flush;
  end

  // Forwarding Unit to Pipeline
  always_comb begin
    fuif.id_rsel1 = d2eif.rs1;
    fuif.id_rsel2 = d2eif.rs2;
    fuif.mem_rd = e2mif.rd;
    fuif.wb_rd = m2wif.rd;
  end

  // PC
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      pc <= PC_INIT;
    end else begin
      pc <= pc_n;
    end
  end

  // STAGE 1: FETCH
  always_comb begin
    cpu_ram_if.iren = 1'b1;
    // If branch is predicted, fetch from the predicted target address
    buif.fetch_pc = pc;
    cpu_ram_if.iaddr = buif.fetch_predict ? buif.fetch_target : pc;
  end

  // STAGE 1 => STAGE 2: FETCH => DECODE
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      f2dif.pc <= PC_INIT;
      f2dif.inst <= NOP;
      f2dif.branch_predict <= 0;
      f2dif.branch_target <= 0;
    end else if (f2dif.en & f2dif.flush) begin
      f2dif.pc <= f2dif.pc;
      f2dif.inst <= NOP;
      f2dif.branch_predict <= 0;
      f2dif.branch_target <= 0;
    end else if (f2dif.en) begin
      f2dif.pc <= buif.fetch_predict ? buif.fetch_target : pc;
      f2dif.inst <= cpu_ram_if.iload;
      f2dif.branch_predict <= buif.fetch_predict;
      f2dif.branch_target <= buif.fetch_target;
    end
  end

  // STAGE 2: DECODE
  always_comb begin
    ctrlif.inst = f2dif.inst;
    rfif.rsel1 = ctrlif.rs1;
    rfif.rsel2 = ctrlif.rs2;
  end

  // STAGE 2 => STAGE 3: DECODE => EXECUTE
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      d2eif.pc <= PC_INIT;
      d2eif.halt <= '0;
      d2eif.alu_op <= ALU_ADD;
      d2eif.rd <= '0;
      d2eif.rs1 <= '0;
      d2eif.rs2 <= '0;
      d2eif.dwrite <= '0;
      d2eif.dread <= '0;
      d2eif.immediate <= '0;
      d2eif.alu_src1 <= '0;
      d2eif.alu_src2 <= '0;
      d2eif.reg_wr_src <= '0;
      d2eif.branch_pol <= '0;
      d2eif.pc_ctrl <= '0;
      d2eif.rdat1 <= '0;
      d2eif.rdat2 <= '0;
      d2eif.mult <= '0;
      d2eif.mult_half <= '0;
      d2eif.mult_signed_a <= '0;
      d2eif.mult_signed_b <= '0;
      d2eif.branch_predict <= 0;
      d2eif.branch_target <= 0;
    end else if (d2eif.en & d2eif.flush) begin
      d2eif.pc <= d2eif.pc;
      d2eif.halt <= '0;
      d2eif.alu_op <= ALU_ADD;
      d2eif.rd <= '0;
      d2eif.rs1 <= '0;
      d2eif.rs2 <= '0;
      d2eif.dwrite <= '0;
      d2eif.dread <= '0;
      d2eif.immediate <= '0;
      d2eif.alu_src1 <= '0;
      d2eif.alu_src2 <= '0;
      d2eif.reg_wr_src <= '0;
      d2eif.branch_pol <= '0;
      d2eif.pc_ctrl <= '0;
      d2eif.rdat1 <= '0;
      d2eif.rdat2 <= '0;
      d2eif.mult <= '0;
      d2eif.mult_half <= '0;
      d2eif.mult_signed_a <= '0;
      d2eif.mult_signed_b <= '0;
      d2eif.branch_predict <= 0;
      d2eif.branch_target <= 0;
    end else if (d2eif.en) begin
      d2eif.pc <= f2dif.pc;
      d2eif.halt <= ctrlif.halt;
      d2eif.alu_op <= ctrlif.alu_op;
      d2eif.rd <= ctrlif.rd;
      d2eif.rs1 <= ctrlif.rs1;
      d2eif.rs2 <= ctrlif.rs2;
      d2eif.dwrite <= ctrlif.dwrite;
      d2eif.dread <= ctrlif.dread;
      d2eif.immediate <= ctrlif.immediate;
      d2eif.alu_src1 <= ctrlif.alu_src1;
      d2eif.alu_src2 <= ctrlif.alu_src2;
      d2eif.reg_wr_src <= ctrlif.reg_wr_src;
      d2eif.branch_pol <= ctrlif.branch_pol;
      d2eif.pc_ctrl <= ctrlif.pc_ctrl;
      d2eif.rdat1 <= rfif.rdat1;
      d2eif.rdat2 <= rfif.rdat2;
      d2eif.mult <= ctrlif.mult;
      d2eif.mult_half <= ctrlif.mult_half;
      d2eif.mult_signed_a <= ctrlif.mult_signed_a;
      d2eif.mult_signed_b <= ctrlif.mult_signed_b;
      d2eif.branch_predict <= f2dif.branch_predict;
      d2eif.branch_target <= f2dif.branch_target;
    end
  end

  // STAGE 3: EXECUTE
  always_comb begin

    // forwarding unit a (0 - rdat1, 1 - e2m alu_out, 2 - m2w alu_out)
    casez (fuif.forward_a)
      2'd0: forwarded_rdat1 = d2eif.rdat1;
      2'd1: begin
        casez(e2mif.reg_wr_src)
          2'd2: forwarded_rdat1 = e2mif.pc + 32'd4;
          default: forwarded_rdat1 = e2mif.alu_out;
        endcase
      end
      2'd2: begin
        casez(m2wif.reg_wr_src)
          2'd1: forwarded_rdat1 = m2wif.dload;
          2'd2: forwarded_rdat1 = m2wif.pc + 32'd4;
          default: forwarded_rdat1 = m2wif.alu_out;
        endcase
      end
      default: forwarded_rdat1 = d2eif.rdat1;
    endcase
    // forwarding unit b (0 - rdat2, 1 - e2m alu_out, 2 - m2w alu_out)
    casez (fuif.forward_b)
      2'd0: forwarded_rdat2 = d2eif.rdat2;
      2'd1: begin
        casez(e2mif.reg_wr_src)
          2'd2: forwarded_rdat2 = e2mif.pc + 32'd4;
          default: forwarded_rdat2 = e2mif.alu_out;
        endcase
      end
      2'd2: begin
        casez(m2wif.reg_wr_src)
          2'd1: forwarded_rdat2 = m2wif.dload;
          2'd2: forwarded_rdat2 = m2wif.pc + 32'd4;
          default: forwarded_rdat2 = m2wif.alu_out;
        endcase
      end
      default: forwarded_rdat2 = d2eif.rdat2;
    endcase

    // ALU source 1 mux (0 - rs1, 1 - pc)
    aluif.a = d2eif.alu_src1 ? d2eif.pc : forwarded_rdat1;
    // ALU source 2 mux (0 - rs2, 1 - immediate)
    aluif.b = d2eif.alu_src2 ? d2eif.immediate : forwarded_rdat2;
    // ALU control
    aluif.op = d2eif.alu_op;

    // Multiplier Unit
    mulif.a = forwarded_rdat1;
    mulif.b = forwarded_rdat2;
    mulif.en = d2eif.mult;
    mulif.is_signed_a = d2eif.mult_signed_a;
    mulif.is_signed_b = d2eif.mult_signed_b;
  end

  // STAGE 3 => STAGE 4: EXECUTE => MEMORY
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      e2mif.pc <= PC_INIT;
      e2mif.halt <= '0;
      e2mif.rd <= '0;
      e2mif.dwrite <= '0;
      e2mif.dread <= '0;
      e2mif.reg_wr_src <= '0;
      e2mif.branch_pol <= '0;
      e2mif.pc_ctrl <= '0;
      e2mif.rdat2 <= '0;
      e2mif.pc_plus_imm <= '0;
      e2mif.alu_out <= '0;
      e2mif.alu_zero <= '0;
      e2mif.branch_predict <= 0;
      e2mif.branch_target <= 0;
    end else if (e2mif.en & e2mif.flush) begin
      e2mif.pc <= d2eif.pc;
      e2mif.halt <= '0;
      e2mif.rd <= '0;
      e2mif.dwrite <= '0;
      e2mif.dread <= '0;
      e2mif.reg_wr_src <= '0;
      e2mif.branch_pol <= '0;
      e2mif.pc_ctrl <= '0;
      e2mif.rdat2 <= '0;
      e2mif.pc_plus_imm <= '0;
      e2mif.alu_out <= '0;
      e2mif.alu_zero <= '0;
      e2mif.branch_predict <= 0;
      e2mif.branch_target <= 0;
    end else if (e2mif.en) begin
      e2mif.pc <= d2eif.pc;
      e2mif.halt <= d2eif.halt;
      e2mif.rd <= d2eif.rd;
      e2mif.dwrite <= d2eif.dwrite;
      e2mif.dread <= d2eif.dread;
      e2mif.reg_wr_src <= d2eif.reg_wr_src;
      e2mif.branch_pol <= d2eif.branch_pol;
      e2mif.pc_ctrl <= d2eif.pc_ctrl;
      e2mif.rdat2 <= forwarded_rdat2;
      e2mif.pc_plus_imm <= (d2eif.pc + {d2eif.immediate[31:1], 1'b0});
      e2mif.alu_out <= d2eif.mult ? (d2eif.mult_half ? mulif.out[63:32] : mulif.out[31:0]) : aluif.out;
      e2mif.alu_zero <= aluif.zero;
      e2mif.branch_predict <= d2eif.branch_predict;
      e2mif.branch_target <= d2eif.branch_target;
    end
  end

  // STAGE 4: MEMORY
  always_comb begin
    // Memory address for ld/st is the sum from ALU
    cpu_ram_if.daddr = e2mif.alu_out;
    
    // Memory data to store is from rs2:
    // Align the data to the proper part of the word
    // Memory control:
    // Map the store width to the enable signals
    casez(e2mif.dwrite)
      // No store
      2'b00: begin
        cpu_ram_if.dwen = 4'b0000;
        cpu_ram_if.dstore = e2mif.rdat2;
      end
      // Byte store
      2'b01: begin
        // Alignment
        casez(cpu_ram_if.daddr[1:0])
          2'b00: begin
            cpu_ram_if.dwen = 4'b0001;
            cpu_ram_if.dstore = {24'd0, e2mif.rdat2[7:0]};
          end
          2'b01: begin
            cpu_ram_if.dwen = 4'b0010;
            cpu_ram_if.dstore = {16'd0, e2mif.rdat2[7:0], 8'd0};
          end
          2'b10: begin
            cpu_ram_if.dwen = 4'b0100;
            cpu_ram_if.dstore = {8'd0, e2mif.rdat2[7:0], 16'd0};
          end
          2'b11: begin
            cpu_ram_if.dwen = 4'b1000;
            cpu_ram_if.dstore = {e2mif.rdat2[7:0], 24'd0};
          end
        endcase
      end
      // Halfword store
      2'b10: begin
        // Alignment
        casez(cpu_ram_if.daddr[1:0])
          2'b00, 2'b01: begin
            cpu_ram_if.dwen = 4'b0011;
            cpu_ram_if.dstore = {16'd0, e2mif.rdat2[15:0]};
          end
          2'b10, 2'b11: begin
            cpu_ram_if.dwen = 4'b1100;
            cpu_ram_if.dstore = {e2mif.rdat2[15:0], 16'd0};
          end
        endcase
      end
      // Word store
      2'b11: begin
        cpu_ram_if.dwen = 4'b1111;
        cpu_ram_if.dstore = e2mif.rdat2;
      end
      default: begin
        cpu_ram_if.dwen = 4'b0000;
        cpu_ram_if.dstore = e2mif.rdat2;
      end
    endcase

    cpu_ram_if.dren = e2mif.dread;
  end

  // STAGE 4 => STAGE 5: MEMORY => WRITEBACK
  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      m2wif.pc <= PC_INIT;
      m2wif.halt <= '0;
      m2wif.rd <= '0;
      m2wif.reg_wr_src <= '0;
      m2wif.alu_out <= '0;
      m2wif.dload <= '0;
    end else if (m2wif.en & m2wif.flush) begin
        m2wif.pc <= e2mif.pc;
        m2wif.halt <= '0;
        m2wif.rd <= '0;
        m2wif.reg_wr_src <= '0;
        m2wif.alu_out <= '0;
        m2wif.dload <= '0;
    end else if (m2wif.en) begin
        m2wif.pc <= e2mif.pc;
        m2wif.halt <= e2mif.halt;
        m2wif.rd <= e2mif.rd;
        m2wif.reg_wr_src <= e2mif.reg_wr_src;
        m2wif.alu_out <= e2mif.alu_out;
        m2wif.dload <= cpu_ram_if.dload;
    end
  end

  // STAGE 5: WRITEBACK
  always_comb begin
    rfif.wsel = m2wif.rd;
    rfif.wen = 1; // If not writing, rd will be 0 anyway
    // Writeback source mux (0 - alu, 1 - memory, 2 - pc + 4)
    casez(m2wif.reg_wr_src)
      2'd0: rfif.wdat = m2wif.alu_out;
      2'd1: rfif.wdat = m2wif.dload;
      2'd2: rfif.wdat = m2wif.pc + 32'd4;
      default: rfif.wdat = m2wif.alu_out;
    endcase
  end

  // Program Counter Control
  always_comb begin
    pc_n = pc;

    // Give prior assumptions to branch unit
    buif.mem_predict = e2mif.branch_predict;
    buif.mem_target = e2mif.branch_target;
    buif.mem_pc = e2mif.pc;

    // Default to telling BU no branch
    buif.mem_branch = 1'b0;
    buif.mem_taken = 1'b0;
    buif.mem_target_res = e2mif.pc + 32'd4;

    // Signal to handle this branch instruction
    if(e2mif.en & |e2mif.pc_ctrl) begin
      buif.mem_branch = 1'b1;
    end
    
    // Branch resolution
    casez(e2mif.pc_ctrl)
      2'b01: begin
        buif.mem_target_res = e2mif.pc_plus_imm;
        if(e2mif.branch_pol ^ e2mif.alu_zero) begin
          // Resolve to taken
          buif.mem_taken = 1'b1;
        end
      end
      2'b10: begin
        // Unconditional
        buif.mem_taken = 1'b1;
        buif.mem_target_res = e2mif.pc_plus_imm;
      end
      2'b11: begin
        // Unconditional
        buif.mem_taken = 1'b1;
        buif.mem_target_res = e2mif.alu_out;
      end
      default: begin
        // Default to telling BU no branch
        buif.mem_taken = 1'b0;
        buif.mem_target_res = e2mif.pc + 32'd4;
      end
    endcase

    // Create the next PC state when the fetch stage is ready to proceed
    if (f2dif.en) begin
      // The branch predictor thought we shouldn't branch but we need to
      if (~e2mif.branch_predict & buif.mem_branch_miss) begin
        // We may have to jump to the resolved target address
        casez(e2mif.pc_ctrl)
          2'b01: begin
            pc_n = e2mif.pc_plus_imm;
          end
          2'b10: begin
            pc_n = e2mif.pc_plus_imm;
          end
          2'b11: begin
            pc_n = e2mif.alu_out;
          end
          default: begin
            pc_n = pc + 32'd4;
          end
        endcase
      end else if (e2mif.branch_predict & buif.mem_branch_miss) begin
        // The branch predictor either predicted a false branch, or the wrong destination
        casez(e2mif.pc_ctrl)
          2'b01: begin
            pc_n = e2mif.pc_plus_imm;
          end
          2'b10: begin
            pc_n = e2mif.pc_plus_imm;
          end
          2'b11: begin
            pc_n = e2mif.alu_out;
          end
          default: begin
            // False branch: go to the next instruction after the original branch
            pc_n = e2mif.pc + 32'd4;
          end
        endcase
      end else if (buif.fetch_predict) begin
        // If a flush isn't occuring, but we are making a prediction, we have to
        // update the PC to the predicted target address
        pc_n = buif.fetch_target + 32'd4;
      end else begin
        // The branch predictor was correct, just continue execution
        pc_n = pc + 32'd4;
      end
    end
  end

  always_ff @(posedge clk, negedge nrst) begin
    if(~nrst) begin
      halt <= '0;
    end else begin
      halt <= m2wif.halt | halt;
    end
  end
endmodule
