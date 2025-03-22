riscv-none-elf-gcc -march=rv32im_zicsr -mabi=ilp32 -nostdlib -ffreestanding -c -o main.o main.c
riscv-none-elf-as -march=rv32im_zicsr -mabi=ilp32 -o startup.o startup.S
riscv-none-elf-ld -T linkerscript.ld --check-sections -o main.elf main.o startup.o 
riscv-none-elf-objdump -D main.elf > main.S
riscv-none-elf-objcopy -O ihex main.elf main.hex