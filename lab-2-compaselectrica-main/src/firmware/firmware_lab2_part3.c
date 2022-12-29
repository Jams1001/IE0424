#include <stdint.h>
#define LED_REGISTERS_MEMORY_1 0x10000004
#define LED_REGISTERS_MEMORY_2 0x10000008
#define LOOP_WAIT_LIMIT 100

static void putuint_1(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_1) = i;
}

static void putuint_2(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_2) = i;
}

void main() {
	uint32_t counter = 0;

	putuint_1(1);
	putuint_2(7);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
	counter = 0;

	putuint_1(2);
	putuint_2(15);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
	counter = 0;

	putuint_1(6);
	putuint_2(10);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}


}
