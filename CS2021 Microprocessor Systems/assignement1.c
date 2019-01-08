             
#include <LPC213x.H>                    /* LPC213x definitions                */
#include <stdio.h>

extern void start (void);
extern void init_serial (void);		    /* Initialize Serial Interface        */

void delay (void) {                     /* Delay function                     */
	unsigned int cnt;
	for (cnt = 0; cnt < 10000000; cnt++);
}

int main (void) {
	unsigned int mask;
	init_serial();
	
	//print welcome message
	printf("\n*********************************************************");
	printf("\n*  Make LEDs P1.16 to P1.19 flash on and off in sequence.");
	printf("\n*********************************************************");

	//Set P1.16 as an output

	IODIR1 = 0x000F0000;   // P1.16 to P1.19 are outputs
 	IOSET1 = 0x000F0000;   // Turn 'em off

	
		for (mask=0x00010000;mask<0x00100000;mask<<=1) {
			IO1CLR = mask;	// turn on the led by pulling output low
			delay();
			IO1SET = mask;	// turn off the led again...
		}  
	

// The following is commented out because it will never be executed.
//	return 0;
		
}
