#include <stdio.h>
#include <unistd.h>

int main(){
    int pid = fork();
    
    if (pid == 0) {
        printf("Это сообщение из дочернего процесса\n"
        "PID: %d, PPID: %d\n", getpid(), getppid());
    }
    else {
        printf("Это сообщение из родительского процесса.\n"
        "Идентификатор дочернего процесса:  %d\n", pid);
    }
    
    return 0;
}
