
#include <stdint.h>
#include "uart.h"
#include "gpio.h"
#include "timer.h"

int main()
{
	uart_init();


	print_uart("Hello World, RiftCore is now Waking Up!\r\n");



	gpio_write( 0xfffffffa );


	while(1)
	{
		;
	}
	return 0;

}

void handle_trap(void)
{

}