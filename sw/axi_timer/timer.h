

#ifndef _TIMER_H_
#define _TIMER_H_


#include <stdint.h>



#define TIMER_BASE 0x20000800U


#define TIMER_TCSR0 0x00U
#define TIMER_TLR0 0x04
#define TIMER_TCR0 0x08

// #define TIMER_RSVD 

#define TIMER_TCSR1 0x10U
#define TIMER_TLR1 0x14U
#define TIMER_TCR1 0x18U


extern int32_t timerIsINT( uint8_t timerNo );
extern int32_t timerClearINT( uint8_t timerNo );
extern int32_t timerEnableRun( uint8_t timerNo );
extern int32_t timerDisableRun( uint8_t timerNo );
extern int32_t timerEnableINT( uint8_t timerNo );
extern int32_t timerDisableINT( uint8_t timerNo );
extern int32_t timerLoad( uint8_t timerNo, uint32_t count );
extern int32_t timerAutoReloadEnable( uint8_t timerNo );
extern int32_t timerAutoReloadDisable( uint8_t timerNo );
extern int32_t timerUpCount( uint8_t timerNo );
extern int32_t timerDownCount( uint8_t timerNo );
extern int32_t timerGenerate( uint8_t timerNo );
extern int32_t timerCapture( uint8_t timerNo );
extern uint32_t timerCounterRead( uint8_t timerNo );








#endif



