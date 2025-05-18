import subprocess
import sys
import os

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python compile.py <source_dir>")
        sys.exit(1)

    src_dir = sys.argv[1]
    c_files_in_dir = [x for x in os.listdir(src_dir) if x.endswith('.c')]
    c_files_out = [x + ".o" for x in c_files_in_dir]
    S_files_in_dir = [x for x in os.listdir(src_dir) if x.endswith('.S')]
    S_files_out = [x + ".o" for x in S_files_in_dir]

    # Empty the output directory
    build_files = [x for x in os.listdir("build")]
    for f in build_files:
        os.remove(f"build/{f}")

    # Generate object files from C source files
    for c_in, c_out in zip(c_files_in_dir, c_files_out):
        subprocess.run(f"wsl -e /opt/riscv/bin/riscv32-unknown-elf-gcc -march=rv32im_zicsr -mabi=ilp32 -fdata-sections -ffunction-sections -c -o build/{c_out} {src_dir}/{c_in}", shell=True)

    # Generate object files from ASM source files
    for S_in, S_out in zip(S_files_in_dir, S_files_out):
        subprocess.run(f"wsl -e /opt/riscv/bin/riscv32-unknown-elf-as -march=rv32im_zicsr -mabi=ilp32 -o build/{S_out} {src_dir}/{S_in}", shell=True)
    
    # Generate object files from startup files
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-as -march=rv32im_zicsr -mabi=ilp32 -o build/startup.o startup_emulator.S", shell=True)
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-gcc -fdata-sections -ffunction-sections -c -march=rv32im_zicsr -mabi=ilp32 -o build/syscalls.o syscalls.c", shell=True)

    subprocess.run(f"wsl -e /opt/riscv/bin/riscv32-unknown-elf-gcc -Wl,--print-memory-usage -Wl,--gc-sections -nostartfiles -T linkerscript_emulator.ld {" ".join(["build/" + x for x in c_files_out])} {" ".join(["build/" + x for x in S_files_out])} build/syscalls.o build/startup.o -o build/program.elf", shell=True)
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-size build/program.elf", shell=True)
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-objdump -D build/program.elf > build/program.S", shell=True)
    subprocess.run("wsl -e /opt/riscv/bin/riscv32-unknown-elf-objcopy -O ihex build/program.elf build/meminit.hex", shell=True)