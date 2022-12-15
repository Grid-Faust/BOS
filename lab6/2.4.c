#include <stdio.h>
#include <unistd.h>

int main(void) {
    int pid = fork();
    
    for (int i = 0; i < 100; i++) {
        if (pid > 0) {
            fork();
        }
    }
    
    sleep(3);
    return 0;
}
