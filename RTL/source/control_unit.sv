// Control Unit (instruction decode)

`include "control_unit_if.vh"
`include "common_types.vh"
import common_types_pkg::*;

module control_unit (
    control_unit_if.control_unit ctrlif
);

j_t j_inst;
u_t u_inst;
b_t b_inst;
s_t s_inst;
i_t i_inst;
r_t r_inst;

always_comb begin
    j_inst = 32'h0;
    u_inst = 32'h0;
    b_inst = 32'h0;
    s_inst = 32'h0;
    i_inst = 32'h0;
    r_inst = 32'h0;
    ctrlif.alu_op = ALU_ADD;
    ctrlif.rs1 = '0;
    ctrlif.rs2 = '0;
    ctrlif.rd = '0;
    ctrlif.halt = 1'b0;
    ctrlif.dread = 1'b0;
    ctrlif.dwrite = 4'b0;
    ctrlif.immediate = 32'd0;
    ctrlif.alu_src1 = 1'b0;
    ctrlif.alu_src2 = 1'b0;
    ctrlif.reg_wr_src = 2'd0;
    ctrlif.pc_ctrl = 2'd0;
    ctrlif.branch_pol = 1'b0;

    casez(ctrlif.inst[OP_W-1:0])
        RTYPE:
        begin
            // R-type instruction
            r_inst = r_t'(ctrlif.inst);
            ctrlif.rs1 = r_inst.rs1;
            ctrlif.rs2 = r_inst.rs2;
            ctrlif.rd = r_inst.rd;

            casez({r_inst.funct3, r_inst.funct7})
                {ADD_SUB, ADD}: ctrlif.alu_op = ALU_ADD;    // ADD
                {ADD_SUB, SUB}: ctrlif.alu_op = ALU_SUB;    // SUB
                {SLL, 7'd0}:    ctrlif.alu_op = ALU_SLL;    // SLL
                {SRL_SRA, SRA}: ctrlif.alu_op = ALU_SRA;    // SRA
                {SRL_SRA, SRL}: ctrlif.alu_op = ALU_SRL;    // SRL
                {AND, 7'd0}:    ctrlif.alu_op = ALU_AND;    // AND
                {OR, 7'd0}:     ctrlif.alu_op = ALU_OR;     // OR
                {XOR, 7'd0}:    ctrlif.alu_op = ALU_XOR;    // XOR
                {SLT, 7'd0}:    ctrlif.alu_op = ALU_SLT;    // SLT
                {SLTU, 7'd0}:   ctrlif.alu_op = ALU_SLTU;   // SLTU
            endcase
        end
        ITYPE:
        begin
            // I-type instruction
            i_inst = i_t'(ctrlif.inst);
            ctrlif.rs1 = i_inst.rs1;
            ctrlif.rd = i_inst.rd;

            casez(i_inst.funct3)
                ADDI:           ctrlif.alu_op = ALU_ADD;    // ADD
                XORI:           ctrlif.alu_op = ALU_XOR;    // XOR
                ORI:            ctrlif.alu_op = ALU_OR;     // OR
                ANDI:           ctrlif.alu_op = ALU_AND;    // AND
                SLLI:           ctrlif.alu_op = ALU_SLL;    // SLL
                SRLI_SRAI: begin
                    if(i_inst.imm[10] == 1'b1) begin
                                ctrlif.alu_op = ALU_SRA;    // SRA
                    end else begin
                                ctrlif.alu_op = ALU_SRL;    // SRL
                    end
                end
                SLTI:           ctrlif.alu_op = ALU_SLT;    // SLT
                SLTIU:          ctrlif.alu_op = ALU_SLTU;   // SLTU
            endcase
            // I-type uses a sign-extended 12-bit immediate
            ctrlif.immediate = {{20{i_inst.imm[11]}}, i_inst.imm};
            ctrlif.alu_src2 = 1'b1;  // Second operand comes from immediate
        end
        ITYPE_LW:
        begin
            // I-type instruction
            i_inst = i_t'(ctrlif.inst);
            ctrlif.rs1 = i_inst.rs1;
            ctrlif.rd = i_inst.rd;

            // Only handle LW, not other types

            ctrlif.alu_op = ALU_ADD;    // Add the offset

            // I-type uses a sign-extended 12-bit immediate
            ctrlif.immediate = {{20{i_inst.imm[11]}}, i_inst.imm};
            ctrlif.alu_src2 = 1'b1;  // Second operand comes from immediate

            // Tell memory to read data
            ctrlif.dread = 1'b1;

            // A load should write back from the memory
            ctrlif.reg_wr_src = 2'd1;
        end
        JALR: begin
            // I-type instruction
            i_inst = i_t'(ctrlif.inst);
            ctrlif.pc_ctrl = 2'd3;
            ctrlif.rs1 = i_inst.rs1;
            ctrlif.rd = i_inst.rd;

            ctrlif.alu_op = ALU_ADD;    // Add base to offset

            // I-type uses a sign-extended 12-bit immediate
            ctrlif.immediate = {{20{i_inst.imm[11]}}, i_inst.imm};
            ctrlif.alu_src2 = 1'b1;  // Second operand comes from immediate

            // Write PC + 4 back to Reg File
            ctrlif.reg_wr_src = 2'd2;
        end
        STYPE:
        begin
            // S-type instruction
            s_inst = s_t'(ctrlif.inst);
            ctrlif.rs1 = s_inst.rs1;
            ctrlif.rs2 = s_inst.rs2;
                        
            // Only handle SW, not other types

            ctrlif.alu_op = ALU_ADD;    // Add the offset

            // S-type uses a sign-extended 12-bit immediate (split in two)
            ctrlif.immediate = {{20{s_inst.imm2[6]}}, s_inst.imm2, s_inst.imm1};
            ctrlif.alu_src2 = 1'b1;  // Second operand comes from immediate

            // Tell memory to write data
            casez(s_inst.funct3)
                SW: ctrlif.dwrite = 2'b11;
                SH: ctrlif.dwrite = 2'b10;
                SB: ctrlif.dwrite = 2'b01;
                default: ctrlif.dwrite = 2'b0;
            endcase
        end
        LUI:
        begin
            // U-type instruction
            u_inst = u_t'(ctrlif.inst);
            ctrlif.rd = u_inst.rd;

            ctrlif.alu_op = ALU_ADD;    // Will add the immediate with x0 and place in rd

            // U-type uses a 20-bit immediate
            ctrlif.immediate = {u_inst.imm, 12'b0};
            ctrlif.alu_src2 = 1'b1;  // Second operand comes from immediate
        end
        AUIPC:
        begin
            // U-type instruction
            u_inst = u_t'(ctrlif.inst);
            ctrlif.rd = u_inst.rd;

            ctrlif.alu_op = ALU_ADD;    // Will add the immediate with PC and place in rd

            // U-type uses a 20-bit immediate
            ctrlif.immediate = {u_inst.imm, 12'b0};
            ctrlif.alu_src1 = 1'b1; // First operand comes from PC
            ctrlif.alu_src2 = 1'b1; // Second operand comes from immediate
        end
        BTYPE:
        begin
            // SB-type instruction
            b_inst = b_t'(ctrlif.inst);
            ctrlif.pc_ctrl = 2'd1;
            ctrlif.rs1 = b_inst.rs1;
            ctrlif.rs2 = b_inst.rs2;

            casez({b_inst.funct3})
                BEQ: begin
                    // If rs1 - rs2 -> zero = 1, branch
                    ctrlif.alu_op = ALU_SUB;   
                    ctrlif.branch_pol = 1'b0;
                end
                BNE: begin
                    // If rs1 - rs2 -> zero = 0, branch
                    ctrlif.alu_op = ALU_SUB;
                    ctrlif.branch_pol = 1'b1;
                end
                BLT: begin
                    // If rs1 < rs2 -> zero = 0, branch
                    ctrlif.alu_op = ALU_SLT;
                    ctrlif.branch_pol = 1'b1;
                end
                BGE: begin
                    // If rs1 < rs2 -> zero = 1, branch
                    ctrlif.alu_op = ALU_SLT;
                    ctrlif.branch_pol = 1'b0;
                end
                BLTU: begin
                    // If unsigned rs1 < rs2 -> zero = 0, branch
                    ctrlif.alu_op = ALU_SLTU;
                    ctrlif.branch_pol = 1'b1;
                end
                BGEU: begin
                    // If unsigned rs1 < rs2 -> zero = 1, branch
                    ctrlif.alu_op = ALU_SLTU;
                    ctrlif.branch_pol = 1'b0;
                end
            endcase

            // B-type uses a sign-extended weird 12-bit immediate that is split in two
            ctrlif.immediate = {{19{b_inst.imm2[6]}}, b_inst.imm2[6], b_inst.imm1[0], b_inst.imm2[5:0], b_inst.imm1[4:1], 1'b0};
        end
        JAL:
        begin
            // UJ-type instruction
            j_inst = j_t'(ctrlif.inst);
            ctrlif.pc_ctrl = 2'd2;
            ctrlif.rd = j_inst.rd;

            // UJ-type uses a sign-extended weird 20-bit immediate
            ctrlif.immediate = {{11{j_inst.imm[19]}}, j_inst.imm[19], j_inst.imm[7:0], j_inst.imm[8], j_inst.imm[18:9], 1'b0};

            // Write PC + 4 back to the destination register
            ctrlif.reg_wr_src = 2'd2;
        end
        HALT:
        begin
            // HALT instruction
            ctrlif.halt = 1'b1;
        end
        default:
        begin
            // Illegal instruction
            ctrlif.halt = 1'b1;
        end
    endcase
end

endmodule
