#ifndef __PARS_H__
#define __PARS_H__

#include <sys/stat.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <mqueue.h>
#include <semaphore.h>
#include <pthread.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

#include "parser.h"
#include "files.h"

typedef struct mq_attr mq_at;

#define MAX_FILES 50
#define NUM_WORKERS 5
#define BUFF_SIZE 2048
#define PORT 8001
#define MAX_CLIENTS 32



#define WORKER_ID(n) (n==0 ? "/work1" : (n==1 ? "/work2" : (n==2 ? "/work3" : (n==3 ? "/work4" : "/work5"))))

#define PRIOREWORK 4
#define PRIOWORKER 3
#define PRIORECLIE 2
#define PRIOCLIENT 1

#define TENES_ARCHIVO 1
#define TENGO_ARCHIVO 2
#define DAME_ARCHIVO 3
#define TOMA_ARCHIVO 4
#define ABRIR_ARCHIVO 5
#define HECHO_ABRIR 6
#define CERRAR_ARCHIVO 7
#define HECHO_CERRAR 8
#define BORRAR_ARCHIVO 9
#define HECHO_BORRAR 10
#define ESCRIBIR_ARCHIVO 11
#define HECHO_ESCRIBIR 12
#define LEER_ARCHIVO 13
#define HECHO_LEER 14

/**
* Metodos del archivo
**/

/**
* Recibe las conexiones de los clientes y lanza hilos para atenderlos
*/
void dispatcher();

/**
* Atiende las solicitudes de los clientes
**/
void* client(void* arg);

/**
* WORKER
**/
void *worker(void *arg);

/**
* Dado un string extrae el numero que está al principio y retorna el resto
*
* number: Numero al principio del string
* rest: resto del string (ignirando el espacio intermedio)
* originalString: Cadena a analizar
*
* El String debe tener la forma "number rest"
**/
void splitNS(int *number, char *rest, char *originalString);

/*
* Splitea una cadena de la forma (a b c rest)
*
* a: Primer numero de la cadena
* b: sengundo numero de la cadena
* c: tercer numero de la cadena
* rest: resto del string
* originalString: Cadena a analizar
*/
void splitNNNS(int *a, int *b, int *c, char *rest, char *originalString);

/**
* Limpia la información basura de un worker para poder procesar una nueva solicitud
*
* msgcounter: contador de mensaje
* parsedInfo: Paquete de parseo
* safe: varaible de seguridad
* salida: buffer de salida
* cache: Caché interna del worker
**/
void clearVar(int *msgcounter, Parser_Package** parsedInfo , int* safe , char* salida , char* cache);

/**
* Dado el identificador de un worker indica si tiene mensajes
*
* workerId: Identificador de worker
**/
int availableMessages(workerId);

/**
* Recibe un mensaje de un Cliente, Retorna @see NULL en caso de no haber ninguno
*
* workId: Identificador del worker
**/
char* getClientMessage(int workId);

/**
* Recibe un mensaje de un Worker, Retorna @see NULL en caso de no haber ninguno
*
* workId: Identificador del worker
**/
char* getWorkerMessage(int workId);

/**
* Retorna el indice de un worker al azar
**/
int getWorker();

/**
* Retorna el siguiente indice de worker para emviar el mensaje
* Este método es utilizado para simular una ronda
*
* ownId: Id del worker que invoca el método
* counter: contador de la ronda (ownId - 1 - 2 - 3 - 4)
**/
int nextWorkerToSend(int ownId, int counter);

/**
* Retorna 1 si el archivo existe
*
* filelist: Lista de archivos
* name: Nombre del archivo
* cantFiles: cantidad de archivos de la lista
**/
int hasTheFile(FileS *filelist, char *name, int cantFiles);

/**
* Dada una lista de archivos y una cadena escribe en el String los nombres de los archivos
*
* buf: cadema de uso temporal para almacenar los nombres ya procesados
* files: arreglo de estructuras de archivos
* cantFiles: camtidad de archivos del arreglo a procesar
**/
void filelistToString(char *buf, FileS *files, int cantFiles);


#endif
