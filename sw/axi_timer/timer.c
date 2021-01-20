/*
* @Author: Ruige Lee
* @Date:   2020-10-12 14:27:54
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-12 17:16:04
*/


#include <stdint.h>
#include "timer.h"


#ifndef TIMER_BASE
#error Timer Base address not define!!!
#endif




volatile uint32_t *timer_tcsr0_reg = (uint32_t*)( TIMER_BASE + TIMER_TCSR0 );
volatile uint32_t *timer_tlr0_reg = (uint32_t*)( TIMER_BASE + TIMER_TLR0 );
volatile uint32_t *timer_tcr0_reg = (uint32_t*)( TIMER_BASE + TIMER_TCR0 );


volatile uint32_t *timer_tcsr1_reg = (uint32_t*)( TIMER_BASE + TIMER_TCSR1 );
volatile uint32_t *timer_tlr1_reg = (uint32_t*)( TIMER_BASE + TIMER_TLR1 );
volatile uint32_t *timer_tcr1_reg = (uint32_t*)( TIMER_BASE + TIMER_TCR1 );


int32_t timerIsINT(uint8_t timerNo)
{
	if ( ( ( (*timer_tcsr0_reg) & 0x00000100 ) && ( timerNo == 0 ) )
		||
		( ( (*timer_tcsr1_reg) & 0x00000100 ) && ( timerNo == 1 ) )
		)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

int32_t timerClearINT(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000100;	
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000100;			
	}

	return 0;
}

int32_t timerEnableRun(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000080;
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000080;		
	}

	return 0;
}

int32_t timerDisableRun(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000080);		
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000080);
	}

	return 0;
}

int32_t timerEnableINT(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{	
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000020);
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000040;
	}
	else
	{	
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000020);
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000040;
	}	


	return 0;
}

int32_t timerDisableINT(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{	
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000040);
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000040);		
	}
	return 0;
}

int32_t timerLoad(uint8_t timerNo, uint32_t count)
{
	if ( timerNo == 0 )
	{
		*timer_tlr0_reg = count;
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000020;
	}
	else
	{
		*timer_tlr1_reg = count;
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000020;		
	}

	return 0;
}


int32_t timerAutoReloadEnable(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000010;
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000010;		
	}

	return 0;
}

int32_t timerAutoReloadDisable(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000010);
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000010);
	}


	return 0;
}

int32_t timerUpCount(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000002);		
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000002);			
	}


	return 0;
}

int32_t timerDownCount(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{	
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000002;
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000002;	
	}

	return 0;
}

int32_t timerGenerate(uint8_t timerNo)
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) & (~0x00000001);
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) & (~0x00000001);
	}

	return 0;
}

int32_t timerCapture( uint8_t timerNo )
{
	if ( timerNo == 0 )
	{
		*timer_tcsr0_reg = (*timer_tcsr0_reg) | 0x00000001;
	}
	else
	{
		*timer_tcsr1_reg = (*timer_tcsr1_reg) | 0x00000001;		
	}

	return 0;
}

uint32_t timerCounterRead( uint8_t timerNo )
{
	if ( timerNo == 0 )
	{
		return *timer_tcr0_reg;
	}
	else
	{
		return *timer_tcr1_reg;
	}
}


