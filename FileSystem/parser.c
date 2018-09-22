#include "parser.h"

/**
* Retorna el indice de un comando
**/
int getCommand(char* str){
    if(!strcmp(str , "CON")){
        return CON;
    }
    else if(!strcmp(str , "LSD")){
        return LSD;
    }
    else if(!strcmp(str , "DEL")){
        return DEL;
    }
    else if(!strcmp(str , "CRE")){
        return CRE;
    }
    else if(!strcmp(str , "OPN")){
        return OPN;
    }
    else if(!strcmp(str , "WRT")){
        return WRT;
    }
    else if(!strcmp(str , "REA")){
        return REA;
    }
    else if(!strcmp(str , "CLO")){
        return CLO;
    }
    else if(!strcmp(str , "BYE")){
        return BYE;
    }
    return 0;
}

/**
* Parsea una cadena
**/
Parser_Package *clientRequestParser(char *estomellego){
    //Variable temporales para el struct
    int cmd = 0;
    int fd = 0;
    int size = 0;
    char* str = malloc(sizeof(char) * (MAX_MSG_CONTENT + 1));
    //Variables para la extraccion
    char* cacho ;
    char* stringAnalize;
    char* stopped;
    char* cajita [5] = {};

    Parser_Package *dat = (Parser_Package *)malloc(sizeof(Parser_Package));

    if(strlen(estomellego) == 0){
        dat -> com = cmd;
        dat -> fd      = fd;
        dat -> size    = size;
        dat -> str     = NULL;
        return dat;
    }

    //Corta si no puede trabajar
    else if((stringAnalize = (char *)malloc(sizeof(char) * strlen(estomellego) + 1)) == NULL) {
        dat -> com = cmd;
        dat -> fd      = fd;
        dat -> size    = size;
        dat -> str     = NULL;
        return dat;
    }
    strcpy(stringAnalize , estomellego);

    //Extrae el comando
    cajita[0] = strtok_r(stringAnalize, TOK, &cacho);
    cmd = getCommand(cajita[0]);

    //Procesa la informacion
    switch (cmd) {
        case 0:
            break;
        case DEL:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            if(cajita[0] == NULL)
                cmd = 0;
            else
                strcpy(str , cajita[0]);
            break;
        case CRE:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            if(cajita[0] == NULL)
                cmd = 0;
            else
                strcpy(str , cajita[0]);
            break;
        case OPN:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            if(cajita[0] == NULL)
                cmd = 0;
            else{
                strcpy(str , cajita[0]);
            }
            break;
        case WRT:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            cajita[1] = strtok_r(NULL, TOK, &cacho);
            cajita[2] = strtok_r(NULL, TOK, &cacho);
            cajita[3] = strtok_r(NULL, TOK, &cacho);
            cajita[4] = strtok_r(NULL, TOK, &cacho);

            //Si hay fallo de parseo
            if(cajita[0] == NULL || cajita[2] == NULL || cajita[4] == NULL){
                cmd = 0;
            }
            else if(!strcmp("FD" , cajita[0]) && !strcmp("SIZE",cajita[2])){
                fd = (int)strtol(cajita[1], &stopped, 10);
                if(strlen(stopped) != 0){
                    cmd = 0;
                    break;
                }
                size = (int)strtol(cajita[3], &stopped, 10);
                if(strlen(stopped) != 0){
                    cmd = 0;
                    break;
                }
                if((strlen(cajita[4]) < size)){
                    cmd = 0;
                    break;
                }
                strcpy(str , cajita[4]);
            }
            else
                cmd = 0;
            break;
        case REA:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            cajita[1] = strtok_r(NULL, TOK, &cacho);
            cajita[2] = strtok_r(NULL, TOK, &cacho);
            cajita[3] = strtok_r(NULL, TOK, &cacho);
            //Si hay fallo de parseo
            if(cajita[1] == NULL || cajita[3] == NULL){
                cmd = 0;
            }
            else if(!strcmp("FD" , cajita[0]) && !strcmp("SIZE",cajita[2])){
                fd = (int)strtol(cajita[1], &stopped, 10);
                if(strlen(stopped) != 0){
                    cmd = 0;
                    break;
                }
                size = (int)strtol(cajita[3], &stopped, 10);
                if(strlen(stopped) != 0){
                    cmd = 0;
                    break;
                }
            }
            else
                cmd = 0;
            break;
        case CLO:
            cajita[0] = strtok_r(NULL, TOK, &cacho);
            cajita[1] = strtok_r(NULL, TOK, &cacho);
            //Si hay fallo de parseo
            if(cajita[0] == NULL || cajita[1] == NULL){
                cmd = 0;
            }
            else if(!strcmp("FD" , cajita[0])){
                fd = (int)strtol(cajita[1], &stopped, 10);
                if(strlen(stopped) != 0){
                    cmd = 0;
                    break;
                }
            }
            else
                cmd = 0;
            break;
    }
    //revenue
    dat -> com = cmd;
    dat -> fd      = fd;
    dat -> size    = size;
    dat -> str     = str;
	return dat;
}

/**
* Imprime el contenido de un Parser_Package
**/
void printParser_Package(Parser_Package p){
    printf("COM: %d\n", p.com);
    printf("FD: %d\n", p.fd);
    printf("SIZE: %d\n", p.size);
    printf("STR: %s\n", p.str);
}

/**
* Librera un Parser_Package
**/
void freeParser_Package(Parser_Package *pack){
    if(pack != NULL){
        if(pack->str != NULL){
            free(pack->str);
        }
        free(pack);
    }
    return;
}
