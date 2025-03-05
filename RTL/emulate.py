# Script to run the RARS emulator

import subprocess
import sys
import os

def run_emulator(asm_file):
    subprocess.run("java -jar \"RISC-V Emulator/rars.jar\" {asm_file} mc Custom smc dump .text HEX ramsim.hex eeb ic".format(asm_file=asm_file), shell=True)

if __name__ == "__main__":
    if(len(sys.argv) < 2):
        print("Usage: python emulate.py <asm_file>")
        sys.exit(1)
    
    if not os.path.exists(sys.argv[1]):
        print("Assembly file \"{}\" does not exist".format(sys.argv[1]))
        sys.exit(1)

    run_emulator(sys.argv[1])
    print("Emulation complete.")