/*
 ============================================================================
 Name        : main.c
 Author      : Tommaso Calzolari and Alessandro Pirini
 Version     : final
 Copyright   : Hello!
 Description : UART-CPU-MODULE transactions
 ============================================================================
 */

#include "platform.h"
#include "init.h"
#include "bsp/hbird-e200/drivers/bitmap/bitmap.h"

#define STRBUF_SIZE			256	// String buffer size
#define UART_RECEIVE_OFFS   0x004  //OFFSET of the UART module. The base address is defined in platform.h
								   // and is 0x10013000. 


int main(void)
{

	uint32_t reg_value = 0x80000000;  //in this variable we store data coming from UART rdata port. We have to find its 
						 //address 
	uint32_t MSB; 		 //this is to see if the FIFO buffer of the UART is empty or not. if MSB==1, then it
					     //it is empty
	uint16_t i; 
	uint16_t bitmap_row; 
	uint8_t uart_data; 
	uint32_t lsbits; 
	uint32_t msbits; 
	uint32_t final;
	uint32_t positionx = 8; 		//for character positioning
	uint32_t positiony = 20; 


	uint32_t flag_MSB = 0x80000000;  //

	int ennesima_flag = 0;
	int flag_canc = 0;
	int final_flag = 0;
	uint32_t flag_delete = 0x40000000; 	// for delete key
	int flag_127 = 0;
	uint32_t flag_enter = 0x20000000;   // for enter key
	uint32_t flag_char_pos = 0x10000000; //for character positioning 
	uint32_t char_pos;
	uint32_t flag_terminal = 0x08000000;  //for terminal operation

	uint32_t cleanArray[23];
	for(int k = 0; k < 23; k++) cleanArray[k] = 32;

	uint32_t asciiArray[ ] = {80, 114, 101, 115, 115, 32, 97, 110, 121, 32, 107, 101, 121, 32, 116, 111, 32, 115, 
							116, 97, 114, 116}; //line at start_up says: "Press any key to start:"

	_init();

	while(1)
	{  		
	
		if((flag_canc == 0) && (final_flag == 0)){ // final_flag needs to be added in order not to repeat the startup text
		//character positioning 
			char_pos= (uint32_t) (positionx +40*positiony);
			MY_PERIPH_REG(MY_PERIPH_REG_IO) = flag_char_pos | char_pos;

			for(int u = 0; u < 23; u++){ //startup_text operation
				reg_value = asciiArray[u];
				uart_data = (uint8_t)reg_value; 

				for (i = 0; i < 16; i++){
					bitmap_row = bitmap[uart_data-32][i]; 
					lsbits = (uint32_t)bitmap_row; 
					msbits = ((uint32_t)i) << 16;
					final = msbits | lsbits; 

					MY_PERIPH_REG(MY_PERIPH_REG_IO) = final; 
				}
			}
			final_flag = 1;
		}

		reg_value = UART0_REG(UART_RECEIVE_OFFS);   //UART receiving data
		MSB = reg_value >> 31; 

		if(MSB == 0){
			if(flag_canc == 0){ //cancel startup_text operation 
								//the first time a letter is typed, MSB goes to 0 and we give the order to cancel the startup_text
								//after it has been done flag_canc will go to 1 so we will never enter this section again
				for(int u = 0; u < 23; u++){
				reg_value = cleanArray[u];
				uart_data = (uint8_t)reg_value; 

					for (i = 0; i < 16; i++){
						bitmap_row = bitmap[uart_data-32][i]; 
						lsbits = (uint32_t)bitmap_row; 
						msbits = ((uint32_t)i) << 16;
						final = msbits | lsbits;

						if((i == 0) && (u == 0)){					//when we want to delete the startup_text the first final element that is sent to 
													//addree_gen will contain a flag in its MSB that whill tell the module to reset the adrdresses of the DPRAM
							final = flag_MSB | final;
						} 

						MY_PERIPH_REG(MY_PERIPH_REG_IO) = final; 
					}
				}
				flag_canc = 1;
				ennesima_flag = 1;
			}
			else {	
					uart_data = (uint8_t)reg_value; 

					if(uart_data == 13){ //enter key 
						final = flag_enter | 0x00000000;

						MY_PERIPH_REG(MY_PERIPH_REG_IO) = final; 
					}
					else {
						flag_127 = 0; 
						for (i = 0; i < 16; i++){ //standard UART read and write operation
						bitmap_row = bitmap[uart_data-32][i]; 
						lsbits = (uint32_t)bitmap_row; 
						msbits = ((uint32_t)i) << 16;
						final = msbits | lsbits; 
						
						if(ennesima_flag == 1){
							final = flag_terminal | final;   //we go back to the first matrix on the display
							ennesima_flag = 0;
						}

						if((uart_data == 127) && (flag_127 == 0)){
							final = flag_delete | final;
							flag_127 = 1;
						}

						MY_PERIPH_REG(MY_PERIPH_REG_IO) = final; 
					}
					}
					
			}
		}  

		
	}


	return 0;
}