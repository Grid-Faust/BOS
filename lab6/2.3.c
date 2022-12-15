#include <stdio.h>
#include <unistd.h>

int main(){
    int pid = fork();
    if(pid != 0) printf("create process %d\n", pid);
    for(int i = 0; i < 9; ++i) {
        if (pid == 0) {
            sleep(2);
        }
        else {
            pid = fork();
            if(pid != 0)
                printf("create process %d\n", pid);
        }
    }
    if(pid != 0) {
        printf("created 10 subprocesses\n");
        sleep(5);
    }
    return 0;
}
