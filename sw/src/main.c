
#include <stdint.h>
#include "uart.h"
#include "gpio.h"
#include "timer.h"

int main()
{
	uart_init();


	print_uart("Hello World, RiftCore is now Waking Up!\r\n");

	gpio_write( 0xfffffffa );

	uint8_t i = 0;
	uint32_t data = 0;
	volatile uint32_t* reg = (uint32_t*)(0x80002000);

	for ( i = 0; i < 255; i++ )
	{
		*(reg+i) = data;
		data ++;
	}



	while(1)
	{
		;
	}
	return 0;

}

void handle_trap(void)
{

}