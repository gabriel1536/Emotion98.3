#ifndef __FILES_H__
#define __FILES_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>


//Datos de los archivos
#define TITLE_SIZE 16
#define BODY_SIZE 128

extern int lastFD;

/**
* Estructura que representa un archivo
**/
typedef struct FileStr_{
	char *name;
	char *contenido;
	int descriptor;
	int propietario;
} FileS;

FileS *createFile(char *name);


#endif
