#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "../include/riscv.h"

#define UART_BASE 0x20020000

#define UART_CFGR (UART_BASE + 0x00)
#define UART_TXDR (UART_BASE + 0x04)
#define UART_RXDR (UART_BASE + 0x08)
#define UART_SR (UART_BASE + 0x0C)

#define SET_CSR(csr, val) \
    asm volatile("csrs " #csr ", %0" ::"r"(val))

typedef struct uart
{
    volatile uint32_t CFGR; // Configuration register
    volatile uint32_t TXDR; // Transmit data register
    volatile uint32_t RXDR; // Receive data register
    volatile uint32_t SR;   // Status register
} UART_TypeDef;

#define UART ((UART_TypeDef *)UART_BASE)

void Unknown_Interrupt_Handler(void) __attribute__((interrupt));
void Exception_Handler(void) __attribute__((interrupt));
void UART_RXI_Handler(void) __attribute__((interrupt));

void uart_init(void);
void uart_send(char chr);
void uart_send_str(char *str);
void uart_receive(char *chr);
uint32_t lfsr32_next(int *lfsr);
int ftoa(float f, char *buf, int n);

int main(void)
{
    int lfsr = 0xACE1u;
    int a;
    int b;
    float result;

    char chr[64];

    // Do some float divisions
    for (int i = 0; i < 2; i++)
    {
        a = lfsr32_next(&lfsr);
        b = lfsr32_next(&lfsr);
        if ((float)b != 0)
        {
            result = (float)a / (float)b;
        }
        else
        {
            result = 0.0F;
        }

        int res = snprintf(chr, 64, "%d / %d = ", a, b);
        int n = 62 - res;
        if (n > 16)
        {
            n = 16; // Limit to 16 decimal places
        }
        ftoa(result, chr + res, n);
        chr[res + n] = '\n';
        chr[res + n + 1] = '\0';
        // uart_send_str(chr);
    }

    return 0;
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
    while (1)
    {
    }
}

void Exception_Handler()
{
    while (1)
    {
    }
}

void UART_RXI_Handler()
{
}