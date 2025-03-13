# Script to run the RARS emulator

import subprocess
import sys
import os

def run_emulator(asm_file):
    # subprocess.run("java -jar \"RISC-V Emulator/rars.jar\" {asm_file} mc Custom smc dump .text HEX ramsim.hex eeb ic".format(asm_file=asm_file), shell=True)
    # Link to start at 0x80000000
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-ld -T /mnt/d/github_repos/RISC-V-Core/RTL/linkerscript_spike.ld {asm_file_start}.o -o {asm_file_start}.l".format(asm_file_start='.'.join(asm_file.split('.')[:-1])), shell=True)
    subprocess.run("wsl -e /opt/riscv/bin/spike --isa=RV32IMA /opt/riscv/riscv32-unknown-elf/bin/pk {asm_file_start}.l".format(asm_file_start='.'.join(asm_file.split('.')[:-1])), shell=True)

if __name__ == "__main__":
    if(len(sys.argv) < 2):
        print("Usage: python emulate.py <asm_file>")
        sys.exit(1)
    
    if not os.path.exists(sys.argv[1]):
        print("Assembly file \"{}\" does not exist".format(sys.argv[1]))
        sys.exit(1)

    run_emulator(sys.argv[1])
    print("Emulation complete.")