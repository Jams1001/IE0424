#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x11000000
#define IRQ_REGISTERS_MEMORY_ADD 0x10000008
#define LOOP_WAIT_LIMIT 100

uint32_t global_counter = 0;
uint32_t number_to_display = 0;
uint32_t delay = 0;

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void putuint2(uint32_t i) {
	*((volatile uint32_t *)IRQ_REGISTERS_MEMORY_ADD) = i;
}


uint32_t *irq(uint32_t *regs, uint32_t irqs) {
	delay = 0;
    putuint(global_counter);
	global_counter++;
	while (delay < LOOP_WAIT_LIMIT) {
			delay++;
	}
    return regs;
}


void main() {

	while (1) {
		putuint(global_counter);
	}
}