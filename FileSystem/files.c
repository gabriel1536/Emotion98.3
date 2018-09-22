#include "files.h"

//Indica cual fue el ultimo descriptor de archivo usado
// 0 Representa el descriptor nulo
lastFD = 0;

//Lock para archivos
pthread_mutex_t file_mutex = PTHREAD_MUTEX_INITIALIZER;

/**
* Crea un archivo en base al nombre del mismo
*
* name: Nombre del archivo
*/
FileS *createFile(char *name){
    //Crea la estructura
    FileS *temp = malloc(sizeof(FileS));
    temp->name = malloc((TITLE_SIZE + 1) * sizeof(char));
    temp->contenido = malloc((BODY_SIZE + 1) * sizeof(char));
    //Limpia valores basura
    memset(temp->name, '\0', TITLE_SIZE + 1);
    memset(temp->contenido, '\0', BODY_SIZE + 1);
    //Inicializa la estructura
    sprintf(temp->name, "%s", name);
    sprintf(temp->contenido, "%s", "");
    return temp;
}

/**
* Intenta abrir un archivo
*
* fileList: Lista de archivos
* name: Nombre del archivo a abrir
* user: usuario que está abriendo el archivo
* cantFiles: cantidad de archivos de la lista
*
* 1 -> Error: el archivo ya está abierto
* 0 -> Se abrió correctamente el archivo
* -1 -> Error: El archivo no está en la lista
*/
int openFile(FileS *fileList, char *name, int user, int cantFiles){
    int i;
    for (i = 0; i < cantFiles; i++){
        if (fileList[i].name != NULL){
            if (!strcmp(fileList[i].name, name)){
                if (fileList[i].descriptor != 0){
                    //Error el archivo ya está abierto
                    return 1;
                }
                else{
                    pthread_mutex_lock(&file_mutex);
                    printf("Usuario del archivo: %d\n", user);
                    fileList[i].propietario = user;
                    lastFD = lastFD + 1;
                    fileList[i].descriptor = lastFD;
                    pthread_mutex_unlock(&file_mutex);
                    //Ok
                    return 0;
                }
            }
        }
    }
    //Error: El archivo no existe en la lista
    return -1;
}



/**
* Intenta cerrar un archivo
*
* filelist: lista de archivos a analizar
* fd: Descriptor de archivo
* user: Identificador de Usuario
* cantFiles: cantidad de archivos en la lista
*
* 1 -> Cierre exitoso
* 2 -> Cierre no autorizado
* -1 -> El archivo no se encuentra en la lista
**/
int closeFile(FileS *fileList, int fd, int user, int cantFiles){
    int i;
    for (i = 0; i < cantFiles; i++){
        if (fileList[i].name != NULL){
            printf("Descriptor de la caja: %d --- fd: %d\n", fileList[i].descriptor, fd);
            if ((fileList[i].descriptor == fd) && (fileList[i].propietario == user)){
                    fileList[i].propietario = -1;
                    fileList[i].descriptor = 0;
                    //Cierre exitoso
                    return 1;
            }
            else if ((fileList[i].descriptor == fd) && (fileList[i].propietario != user)){
                //Cierre no autorizado
                return 2;
            }
        }
    }
    return -1;
}

/**
* Intenta eliminar un archivo
*
* filelist: lista de archivos a analizar
* name: Nombre del archivo a borrar
* cantFiles: cantidad de archivos en la lista
*
* 1 -> Eliminado con exito
* 2 -> Error: El archivo está abierto
* -1 -> Error: El archivo no está en la lista
**/
int deleteFile(FileS *fileList, char *name, int cantFiles){
    int i;
    for (i = 0; i < cantFiles; i++){
        if (fileList[i].name != NULL){
            if(!strcmp(fileList[i].name, name)){
                if (fileList[i].descriptor == 0){
                        fileList[i].propietario = -1;
                        fileList[i].descriptor = -1;
                        free(fileList[i].name);
                        free(fileList[i].contenido);
                        fileList[i].name = NULL;
                        //Eliminado con exito
                        return 1;
                }
                else {
                    //error: archivo abierto
                    return 2;
                }
            }
        }
    }
    return -1;
}

/**
* Intenta escribir en un archivo
*
* filelist: lista de archivos a analizar
* fd: Descriptor de archivo
* usrId: Identificador de Usuario
* cantFiles: cantidad de archivos en la lista
* bufSize: Tamaño del buffer a escribir
* buf: Buffer a escribir
*
* 1 -> Escritura correcta
* 2 -> Error: espacio insuficiente
* 3 -> Error: acceso denegado
* -1 -> Error: El archivo no está en la lista
**/
int writeFile(FileS* fileList, int fd, int usrId, int cantFiles, int bufSize, char* buf){
    int i;
    for (i = 0; i < cantFiles; i++){
        if (fileList[i].name != NULL){
            if(fileList[i].descriptor == fd){
                if(fileList[i].propietario == usrId){
                    if (strlen(buf) != bufSize)
                        return 2;
                    int availableBuffer = TITLE_SIZE - strlen(fileList[i].name);
                    if(bufSize <= availableBuffer){
                        strncpy(fileList[i].contenido + strlen(fileList[i].contenido), buf, bufSize);
                        //copiado exitoso
                        printf("Escribi esto: .%s.\n", fileList[i].contenido);
                        return 1;
                    }
                    else{
                        //Espacio insuficiente, acceso denegado
                        return 2;
                    }
                }
                else{
                    //No se puede escribir, permiso denegado
                    return 3;
                }
            }
        }
    }
    //Archivo no en lista
    return -1;
}

/**
* Intenta leer un archivo
*
* filelist: lista de archivos a analizar
* fd: Descriptor de archivo
* usrId: Identificador de Usuario
* cantFiles: cantidad de archivos en la lista
* bufSize: Tamaño del buffer a escribir
* buf: Buffer a escribir
*
* 1 -> Lectura correcta
* 2 -> Error: espacio insuficiente
* 3 -> Error: acceso denegado
* -1 -> Error: El archivo no está en la lista
**/
int readFile(FileS* fileList, int fd, int usrId, int cantFiles, int bufSize, char *buf){
    int i;
    for (i = 0; i < cantFiles; i++){
        if (fileList[i].name != NULL){
            if(fileList[i].descriptor == fd){
                if(fileList[i].propietario == usrId){
                    int availableBuffer = strlen(fileList[i].contenido);
                    if(bufSize <= availableBuffer){
                        strncpy(buf, fileList[i].contenido, bufSize);//caja[i].contenido + strlen(caja[i].contenido), buf, bufSize);
                        //copiado exitoso
                        printf("Leo %d de esto: .%s.\n", bufSize, fileList[i].contenido);
                        return 1;
                    }
                    else{
                        //Espacio insuficiente, acceso denegado
                        return 2;
                    }
                }
                else{
                    //No se puede escribir, permiso denegado
                    return 3;
                }
            }
        }
    }
    return -1;
}
