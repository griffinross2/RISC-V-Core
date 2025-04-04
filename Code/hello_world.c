#include <stdint.h>

#define UART_BASE 0x00020000

#define UART_CFGR (UART_BASE + 0x00)
#define UART_TXDR (UART_BASE + 0x04)
#define UART_RXDR (UART_BASE + 0x08)
#define UART_SR (UART_BASE + 0x0C)

typedef struct uart
{
    volatile uint32_t CFGR; // Configuration register
    volatile uint32_t TXDR; // Transmit data register
    volatile uint32_t RXDR; // Receive data register
    volatile uint32_t SR;   // Status register
} UART_TypeDef;

#define UART ((UART_TypeDef *)UART_BASE)

void uart_init(void);
void uart_send(char *str);

void main(void)
{
    // Initialize UART
    uart_init();

    // Transmit "Hello, World!" string
    const char *str = "Hello, World!\n";
    uart_send((char *)str);

    // Halt
    asm("ebreak");
}

void uart_init(void)
{
    // Initialize UART configuration register
    UART->CFGR = 5208; // Set baud rate: 50M / 9600 = 5208
}

void uart_send(char *str)
{
    while (*str != '\0')
    {
        // Wait for the UART to be ready
        while (UART->SR & 0x1) // Check if tx_busy (bit 0) is set
            ;

        // Send the character
        UART->TXDR = *str++;

        // Wait for the transmission to complete
        while (!(UART->SR & 0x2)) // Check if tx_done (bit 1) is set
            ;

        // Clear the tx_done flag
        UART->SR = 0x2; // Clear tx_done (bit 1)
    }
}

void Exception_Handler()
{
    while (1)
    {
    }
}