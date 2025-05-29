#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "../include/riscv.h"

#define UART_BASE 0x20020000

#define UART_CFGR (UART_BASE + 0x00)
#define UART_TXDR (UART_BASE + 0x04)
#define UART_RXDR (UART_BASE + 0x08)
#define UART_SR (UART_BASE + 0x0C)

#define GNSS_SEARCH_BASE 0x20040100

#define GNSS_SEARCH_SR (GNSS_BASE + 0x00)
#define GNSS_SEARCH_CFGR (GNSS_BASE + 0x04)
#define GNSS_SEARCH_DOP (GNSS_BASE + 0x08)
#define GNSS_SEARCH_CODE (GNSS_BASE + 0x0C)
#define GNSS_SEARCH_CORR (GNSS_BASE + 0x10)

#define SET_CSR(csr, val) \
    asm volatile("csrs " #csr ", %0" ::"r"(val))

typedef struct uart
{
    volatile uint32_t CFGR; // Configuration register
    volatile uint32_t TXDR; // Transmit data register
    volatile uint32_t RXDR; // Receive data register
    volatile uint32_t SR;   // Status register
} UART_TypeDef;

typedef struct gnss_search
{
    volatile uint32_t SR;   // Status register
    volatile uint32_t CFGR; // Configuration register
    volatile uint32_t DOP;  // DOP value
    volatile uint32_t CODE; // Code value
    volatile uint32_t CORR; // Correlation value
} GNSS_Search_TypeDef;

#define UART ((UART_TypeDef *)UART_BASE)
#define GNSS_SEARCH ((GNSS_Search_TypeDef *)GNSS_SEARCH_BASE)

void Unknown_Interrupt_Handler(void) __attribute__((interrupt));
void Exception_Handler(void) __attribute__((interrupt));
void UART_RXI_Handler(void) __attribute__((interrupt));

void uart_init(void);
void uart_send(char chr);
void uart_send_str(char *str);
void uart_receive(char *chr);
void gnss_search_set_sv(int sv);
void gnss_search_start(void);
void gnss_search_wait(void);
int gnss_search_get_dop(void);
int gnss_search_get_code(void);
int gnss_search_get_corr(void);
uint32_t lfsr32_next(int *lfsr);
int ftoa(float f, char *buf, int n);

char str_out[256];

int main(void)
{
    // Initialize UART
    uart_init();
    uart_send_str("Starting acquistion...\n");

    // Search each satellite from 1 to 32 (0-31)
    for (int sv = 1; sv <= 32; sv++)
    {
        gnss_search_set_sv(sv - 1); // Set the SV in the GNSS search configuration register
        gnss_search_start();        // Start the GNSS search
        gnss_search_wait();         // Wait for the search to complete

        // Get results
        int dop = gnss_search_get_dop();
        int code = gnss_search_get_code();
        int corr = gnss_search_get_corr();

        snprintf(str_out, sizeof(str_out), "SV %2d: Doppler: %5d, Code: %4d.%02d, Correlation: %10d\n", sv, dop * 500 - 5000, code / 4, (code % 4) * 25, corr);
        uart_send_str(str_out);
    }
}

// From GPT
uint32_t lfsr32_next(int *lfsr)
{
    uint32_t lsb = *lfsr & 1; // Get LSB (output bit)
    *lfsr >>= 1;              // Shift register
    if (lsb)
    {
        *lfsr ^= 0x80000057u; // Apply feedback polynomial
    }
    return *lfsr;
}

void uart_init(void)
{
    // Initialize UART configuration register
    UART->CFGR = 434; // Set baud rate: 50M / 115200 = 434

    // Enable UART interrupt
    IRQ_ENABLE(UART_RXI); // Set interupt enable bit for UART RXI
}

void gnss_search_set_sv(int sv)
{
    // Set the SV in the GNSS search configuration register
    GNSS_SEARCH->CFGR = sv;
}

void gnss_search_start(void)
{
    // Start the GNSS search by setting the start bit in the status register
    GNSS_SEARCH->SR |= 0x1; // Set the start bit (bit 0)
}

void gnss_search_wait(void)
{
    // Wait for the GNSS search to complete
    while (!(GNSS_SEARCH->SR & 0x2)) // Check if done (bit 1) is set
        ;
}

int gnss_search_get_dop(void)
{
    // Return the DOP value from the GNSS search
    return GNSS_SEARCH->DOP;
}

int gnss_search_get_code(void)
{
    // Return the code value from the GNSS search
    return GNSS_SEARCH->CODE;
}

int gnss_search_get_corr(void)
{
    // Return the correlation value from the GNSS search
    return GNSS_SEARCH->CORR;
}

void uart_send(char chr)
{
    // Wait for the UART to be ready
    while (UART->SR & 0x1) // Check if tx_busy (bit 0) is set
        ;

    // Send the character
    UART->TXDR = chr;

    // Wait for the UART to be busy
    while (!(UART->SR & 0x1)) // Check if tx_busy (bit 0) is set
        ;
}

void uart_send_str(char *str)
{
    while (*str != '\0')
    {
        uart_send(*str); // Send each character in the string
        str++;           // Move to the next character
    }
}

void uart_receive(char *chr)
{
    // Wait for the UART to receive data
    while (!(UART->SR & 0x8)) // Check if rx_done (bit 3) is set
        ;

    // Receive the character
    *chr = UART->RXDR;

    // Clear the rx_done flag
    UART->SR = 0x8; // Clear rx_done (bit 3)
}

int ftoa(float f, char *buf, int n)
{
    // Buffer must be longer than 1
    if (n < 2)
    {
        return -1;
    }

    int pos = 0;
    int neg = 0;
    if (f < 0)
    {
        neg = 1;
        buf[pos++] = '-';
        f = -f;
    }

    unsigned int int_part = (unsigned int)f;
    int num_digits = 0;

    // If int part is zero, just put a 0
    if (int_part == 0)
    {
        if (pos + 2 >= n)
        {
            return -1;
        }
        buf[pos++] = '0';
        num_digits++;
    }
    else
    {
        // Otherwise, we need to add the integer part digit by digit, making sure to
        // stop if we exceed the buffer.
        while (int_part > 0)
        {
            // Check limit
            if (pos + 2 >= n)
            {
                return -1;
            }
            buf[pos++] = '0' + (int_part % 10);
            int_part /= 10;
            num_digits++;
        }

        // Swap order of digits
        int swap_start = neg;
        int swap_end = pos - 1;
        while (swap_start < swap_end)
        {
            char tmp = buf[swap_start];
            buf[swap_start] = buf[swap_end];
            buf[swap_end] = tmp;
            swap_start++;
            swap_end--;
        }
    }

    // Figure out decimal places
    int decimal_places = n - pos - 1;

    // If < 1, no room
    if (decimal_places < 1)
    {
        return 0;
    }

    // Add decimal point
    buf[pos++] = '.';

    // Add decimal places
    f -= (int)f;
    for (int i = 0; i < decimal_places; i++)
    {
        f *= 10;
        int digit = (int)f;
        buf[pos++] = '0' + digit;
        f -= digit;
    }

    // Done
    return 0;
}

void Unknown_Interrupt_Handler()
{
    uart_send_str("Unknown Interrupt!\n");
    while (1)
    {
    }
}

void Exception_Handler()
{
    uart_send_str("Exception!\n");
    while (1)
    {
    }
}

void UART_RXI_Handler()
{
    // Acknowledge the interrupt
    // Clear the rx_done flag
    UART->SR = 0x8; // Clear rx_done (bit 3)

    IRQ_ENTRY(); // Save interrupt context

    // Receive the character and echo it back
    char chr = UART->RXDR; // Read the received character
    uart_send(chr);

    IRQ_EXIT(); // Restore interrupt context
}