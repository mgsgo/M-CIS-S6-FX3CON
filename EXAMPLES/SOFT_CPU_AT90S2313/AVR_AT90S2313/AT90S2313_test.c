//////////////////////////////////////////////////////////////////////////////////
// Company:        MGSG
// Engineer:       jhyoo, mgsg.opensource@gmail.com
// 
// Create Date:    2019
// Design Name:    SOFT_CPU_AT90S2313
// Module Name:    AT90S2313.c
// Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
// Target Devices: AT90S2313
// Tool versions:  AVRSTUDIO 4.19 build 730
// Description:    SOFT CPU core example AT90S2313 using opencores AX8
// License:        BSD 2-Clause
//
// Dependencies:   
//
// Revision:       
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


#define F_CPU                (50000000)                        //Main clock
#define UART0_BAUD_RATE        115200                            //
#define UART0_BAUD_SELECT    (F_CPU/(UART0_BAUD_RATE*16l)-1)    //

#include <avr/io.h>
#include <avr/signal.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>

#include <stdio.h>



unsigned char pdata; //variable for received packet

/* initialize UART */
void InitUART( unsigned char baudrate )
{
    UCR = ( (1<<RXEN) | (1<<TXEN) ); /* enable UART receiver and transmitter */
    UBRR = baudrate; /* set the baud rate */
}


/* Read and write functions */
unsigned char ReceiveByte( void )
{
    while ( !(USR & (1<<RXC)) ){ /* wait for incomming data */
    }

    /* return the data */
    return UDR;
}

void TransmitLength(unsigned char *string, int length)
{
    for(int i=0; i<length; i++){
        TransmitByte(string[i]);
    }
}

void TransmitString(unsigned char *string)
{
    while(*string != '\0')
    {
        TransmitByte(*string);
        if(*string == '\n') TransmitByte('\r');
        string++;
    }
}

void TransmitByte( unsigned char data )
{
    while ( !(USR & (1<<UDRE)) ){ /* wait for empty transmit buffer */
    }
    UDR = data; /* start transmittion */
}


int main(void){
    unsigned char temp;


    DDRD  = 0xFF;           //output to 1
    PORTD = 0xFF;

    InitUART(UART0_BAUD_SELECT);


    TransmitLength("MGSG \n", 6);
    TransmitString("AT90S2313 soft core test\0");


    while(1){
        temp = ReceiveByte();
        if     (temp == '8'){
            PORTD    |= (1<<5);        //LED8 ON
        }
        else if(temp == '9'){
            PORTD    |= (1<<6);        //LED9 ON
        }
        else if(temp == '0'){
            PORTD    &= ~(1<<5);        //LED8 OFF
            PORTD    &= ~(1<<6);        //LED9 OFF
        }
        else{
        }
    }

    return 0;
}



