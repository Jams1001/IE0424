#include <stdint.h>
#include <stdio.h>
#define LED_REGISTERS_MEMORY_1 0x0FFFFFF0
#define LED_REGISTERS_MEMORY_2 0x0FFFFFF4
#define LED_REGISTERS_MEMORY_3 0x0FFFFFF8
#define OUT_FACT_ADDR 0x10000000
#define LOOP_WAIT_LIMIT 100

static void putuint_1(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_1) = i;
}

static void putuint_2(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_2) = i;
}

static void putuint_3(uint32_t i) {
	*((volatile uint32_t *)OUT_FACT_ADDR) = i;
}

static uint32_t readuint(void) {
	return *((volatile uint32_t *)LED_REGISTERS_MEMORY_3);
}

void main(){
	uint32_t contador = 0;
	uint32_t x;

	for (int i = 0; i <= 15; i++) {
		putuint_1(i);
		for(int j = 0; j <= 15; j++) {
			putuint_2(j);
			x = readuint();
			putuint_3(x);
			while (contador < LOOP_WAIT_LIMIT) {
				contador++;
			}
			contador = 0;
		}

	}

}
