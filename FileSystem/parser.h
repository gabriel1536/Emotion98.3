#ifndef __PARSER_H__
#define __PARSER_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOK " "
#define MAX_MSG_CONTENT 56

/**
* Indices de comando
**/
#define CON 1
#define LSD 2
#define DEL 3
#define CRE 4
#define OPN 5
#define WRT 6
#define REA 7
#define CLO 8
#define BYE 9

/**
* Estructura con la informacion de un comando
**/
typedef struct Parser_Package_{
	unsigned int com; //Comando
	int fd; //File descriptor
	int size; //Size
	char *str; //Other info
} Parser_Package;

/**
* Funciones incluidas
**/

/**
* Retorna el indice de un comando
**/
int getCommand(char* str);

/**
* Parsea una cadena
**/
Parser_Package *clientRequestParser(char *estomellego);

/**
* Imprime el contenido de un Parser_Package
**/
void printParser_Package(Parser_Package p);

/**
* Librera un Parser_Package
**/
void freeParser_Package(Parser_Package *pack);

#endif
