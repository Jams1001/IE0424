#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD_n 0x10000000
#define LED_REGISTERS_MEMORY_ADD_y 0x20000000
#define LED_REGISTERS_MEMORY_ADD_z 0x30000000

//#define LOOP_WAIT_LIMIT 100 // Activar para simulaciones
#define LOOP_WAIT_LIMIT 100000 // Activar para ejecución en la FPGA

uint32_t global_counter = 3;
uint32_t number_to_display = 0;
uint32_t y;
uint32_t z;
uint32_t y_2;
uint32_t z_2;
uint32_t delay = 0;

static void putuint_n(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_n) = i;
}

static uint32_t getuint_y() {
	return *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_y);
}

static uint32_t getuint_z() {
	return *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_z);
}



uint32_t *irq(uint32_t *regs, uint32_t irqs) {
	delay = 0;
    putuint_n(number_to_display);
	while (delay < LOOP_WAIT_LIMIT) {
			delay++;
	}
    return regs;
}


void main() {

	while (1) {
        y = getuint_y();
        z = getuint_z();
		z_2 = z << 16;
		y_2 = y & 0x00FF;
        putuint_n(z_2 | y_2);
	}
}

