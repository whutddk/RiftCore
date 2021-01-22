#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>

#define UART_BASE 0x20600000U



#define RX_FIFO		0x0000
#define TX_FIFO 	0x0004
#define STAT_REG	0x0008
#define CTRL_REG	0x000c


extern int32_t uart_init();
extern int32_t uart_sendByte( uint8_t data );
extern uint8_t uart_recByte();
extern int32_t print_uart(const char *str);




#endif


