#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 1000


static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}
uint32_t factorial(uint32_t num);


void main() {
	uint32_t  num;
	uint32_t number_to_display;
	uint32_t counter = 0;


		counter = 0;
		num = factorial(5);
		putuint(num);

			while (counter < LOOP_WAIT_LIMIT) {
				counter++;
		}
		counter = 0;
		num = factorial(7);
		putuint(num);

			while (counter < LOOP_WAIT_LIMIT) {
				counter++;
		}
		counter = 0;
		num = factorial(10);
		putuint(num);

			while (counter < LOOP_WAIT_LIMIT) {
				counter++;
		}
		counter = 0;
		num = factorial(12);
		putuint(num);

			while (counter < LOOP_WAIT_LIMIT) {
				counter++;
		}
}
uint32_t factorial(uint32_t num){
	uint32_t tmp = num;
	uint32_t fact = 1;
	for(uint32_t i = 1; i <= tmp; i++){
		fact= fact*i;
	}
	return fact;
}