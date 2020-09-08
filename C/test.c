#include <stdio.h>
#include <stdlib.h>
#include <string.h>



int main(void) {
    /*int num;
    char singleLine[150];
    FILE *fptr;
    fptr = fopen("/home/lehalinuksoid/Python_rofli/C/file.txt", "r");
    if (fptr == NULL) {
        printf("ERROR\n");
        exit(1);
    } 
    while(feof(fptr) == 0) {
        fgets(singleLine, 150, fptr);
        printf("%s", singleLine);
    }
    fclose(fptr);
*/
    
    char mystr[] = "Nmy";
    char *p = mystr;
    p++;
    printf("1: %s\n", p);
    p[strlen(p)-1] = '\0';

    printf("2: %s\n", p);
    printf("3: %s\n", mystr);
    return 0;
}

