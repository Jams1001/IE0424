#include <stdint.h>

#define REGISTER_MEMORY_ADD 0x10000000
#define ADDRESS 0x4000
#define LOOP_WAIT_LIMIT 100		// Para la simulación
//#define LOOP_WAIT_LIMIT 10000 // Para la FPGA
#define LIST_SIZE 6144 // Como cada ADDRESS es de 8 bytes, en 48kB caben 6144 direcciones. En total 3522



// Funcion que crea la lista
static void lista(uint32_t address, uint32_t data) {
	*((volatile uint32_t *)address) = (address + 8);
	*((volatile uint32_t *)address + 4) = data;
}

// Función para leer
uint32_t read(uint32_t address) {
	return *((volatile uint32_t *)ADDRESS);
}

// Función para escribir
static void write(uint32_t data) {
	*((volatile uint32_t *)REGISTER_MEMORY_ADD) = data;
}

uint32_t elemento = 0;
uint32_t contador8 = 0; 
uint32_t potpar = 0; 
int pares[8];
uint32_t contador = 0;
uint32_t counter_delay;
uint32_t address = ADDRESS;



void main() {

	for (elemento; elemento <= LIST_SIZE; elemento++ ){
        lista(address, elemento);
		address = address + 8; 
	}
	
	while (contador8 >= 8){
		potpar = read(elemento);

		if(potpar%2 == 0){
			pares[contador8] = potpar;
			contador8++;
			elemento--;
		}
		else {
			elemento--;
		}
	}


	while (1) {
		counter_delay = 0;
		write(pares[contador]);
		contador++;
		while (counter_delay < LOOP_WAIT_LIMIT) {
			counter_delay++;
		}
	}
}