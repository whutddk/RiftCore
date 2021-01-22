

#include <stdint.h>
#include "uart.h"


#ifndef UART_BASE
#error UART Base address not define!!!
#endif


volatile uint32_t *uart_rfifo = (uint32_t*)( UART_BASE + RX_FIFO );
volatile uint32_t *uart_tfifo = (uint32_t*)( UART_BASE + TX_FIFO );
volatile uint32_t *uart_status = (uint32_t*)( UART_BASE + STAT_REG );
volatile uint32_t *uart_ctrl = (uint32_t*)( UART_BASE + CTRL_REG );


int32_t uart_init()
{
	//reset rx & tx fifo, disable interrupt
	(*uart_status) = 0x03;
	(*uart_status) = 0x00;

	return 0;
}



int32_t uart_sendByte( uint8_t data )
{
	//wait unitl tx fifo not full
	while( ((*uart_status) & 0x08) != 0);

	uint64_t sent = (uint64_t)data << 32;

	(*(volatile uint64_t*)(UART_BASE)) = sent;

	return 0;
}


uint8_t uart_recByte()
{
	//wait unitl rx fifo has data
	while( ((*uart_status) & 0x01) == 0);

	return (uint8_t)(*uart_rfifo);
}



int32_t print_uart(const char *str)
{
	const char *cur = &str[0];
	while (*cur != '\0')
	{
		uart_sendByte((uint8_t)*cur);
		cur++;
	}

	return 0;
}















