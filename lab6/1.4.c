#include <stdio.h>
#include <stdlib.h>

extern char **environ;
int main(int argc, char* argv[]){
    if(argc != 2) {
        printf("Usage: %s (max_num_of_vars)\n", argv[0]);
        return 1;
    }
    char **p;
    int i = 0;
    int max = atoi(argv[1]);
    if(max < 0) {
        printf("max number of vars mast be >= 0\n");
        return 1;
    }
    for (p = environ; *p != NULL; p++) {
        if(i == max) break;
        printf("%s\n", *p);
        i += 1;
    }
}
