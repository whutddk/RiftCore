
#include <stdint.h>
#include "gpio.h"




#ifndef GPIO_BASE
#error GPIO Base address not define!!!
#endif


// for 8 bit gpio

volatile uint32_t *gpio_dat_reg = (uint32_t*)( GPIO_BASE + GPIO_DATA );
volatile uint32_t *gpio_tri_reg = (uint32_t*)( GPIO_BASE + GPIO_TRI );


uint8_t gpio_read()
{
	*gpio_tri_reg = 0xff;
	return (uint8_t)(*gpio_dat_reg);
}


uint32_t gpio_write( uint32_t data )
{
	*gpio_tri_reg = 0x00;
	(*gpio_dat_reg) = data;
	return 0;
}









