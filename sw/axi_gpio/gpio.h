#ifndef _GPIO_H_
#define _GPIO_H_

#include <stdint.h>

#define GPIO_BASE 0x20000000U



#define GPIO_DATA 0x0000
#define GPIO_TRI 0x0004
#define GPIO2_DATA 0x0008
#define GPIO2_TRI 0x000C
#define GIER 0x011C
#define IP_IER 0x0128
#define IP_ISR 0x0120


extern uint8_t gpio_read();
extern uint32_t gpio_write( uint32_t data );

void gpio_test();

#endif
