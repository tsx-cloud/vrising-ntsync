#include <stdio.h>
#include <sys/utsname.h> // uname

int main() {
    printf("Hello world I am x86_64.\n");

    struct utsname buffer;
    if (uname(&buffer) == 0) {
        printf("Arch: %s\n", buffer.machine);
    } else {
        perror("uname");
    }

    return 0;
}
