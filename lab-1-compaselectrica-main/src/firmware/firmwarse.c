#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LOOP_WAIT_LIMIT 1000

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

void main() {
	uint32_t v1, v2;
	uint32_t counter;
  uint32_t siguiente =0;

	while (1) {
    v1 = 0;
    v2 = 1;
    siguiente = v1+v2;

    while(siguiente <=610){
      counter = 0;
      if(siguiente % 2 == 0){
        putuint(siguiente);
      }

      v1 = v2;
      v2 = siguiente;
      siguiente = v1 + v2;

      while (counter < LOOP_WAIT_LIMIT) {
  			counter++;
      }

		}
	}
}
