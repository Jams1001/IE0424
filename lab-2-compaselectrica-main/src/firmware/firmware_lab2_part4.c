#include <stdint.h>
#define LED_REGISTERS_MEMORY_1 0x1000000C
#define LED_REGISTERS_MEMORY_2 0x10000010
#define LOOP_WAIT_LIMIT 100

static void putuint_1(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_1) = i;
}

static void putuint_2(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_2) = i;
}


void main() {
	uint32_t counter = 0;

	putuint_1(120);
	putuint_2(5);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
	counter = 0;

	putuint_1(47);
	putuint_2(725);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}
	counter = 0;

	putuint_1(7628900);
	putuint_2(611);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}

	counter = 0;

	putuint_1(39916800);
	putuint_2(1023);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}


	counter = 0;

	putuint_2(9628800);
	while (counter < LOOP_WAIT_LIMIT) {
		counter++;
	}


}
