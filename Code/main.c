void main(void) {
    int a = 2;
    int b = 3;
    int c = a * b;
    *((int *)0x4000) = c;

    // Illegal instruction
    // asm(".word 0x00000000");

    // Halt
    asm("ebreak");
}

void Exception_Handler() {
    while(1) {
    }
}