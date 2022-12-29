#include <stdint.h>
#include <stdio.h>

#define REGISTERS_MEMORY 0x10000000
#define ADDRESS 0x1000000C
#define LIST_SIZE  6144  // 48KB/8B
//#define LOOP_WAIT_LIMIT 10 //Para simulaciones
#define LOOP_WAIT_LIMIT 100000 //Para FPGA




// Creación de lista
static void lista(uint32_t i, uint32_t address) {
	*((volatile uint32_t *)address) = (address + 8);
	*((volatile uint32_t *)(address + 4)) = i;
}

// Función para lectura
uint32_t leer(uint32_t address) {
	return *((volatile uint32_t *)address);
}

// Función para guardar números pares
static void write(uint32_t i) {
	*((volatile uint32_t *)REGISTERS_MEMORY) = i;
}

// Función para guardar la dirección actual
static void actual_address(uint32_t i) {
	*((volatile uint32_t *)ADDRESS) = i;
}

void main() {
    int pares[8];
    int pares_i;             
    int pares_cnt = 0;            
    uint32_t num = 0;
    uint32_t cont = 0;
    uint32_t address = 0x4000;
    uint32_t dir;
    uint32_t datos;

    for (int i = 0; i < LIST_SIZE; i++){
		lista(i, address);
		address = address + 8;
    }

    dir = 0x4000; // Se reinicia a la primera dirección
    for (int i = 0; i < LIST_SIZE; i++){
        datos = leer(dir+4); 
        pares_i = (pares_cnt % 8);
        if (i%2 == 0){
            pares[pares_i] = datos;
            pares_cnt++;
        }
        dir = leer(dir);    
    }
    int x = 0;
    while(1){
        for (int i = 0; i < 8; i++){
            cont = 0;
            write(pares[i]);
            while (cont < LOOP_WAIT_LIMIT) {
			    cont++;
		    }
        }
        x++;
    }
}
