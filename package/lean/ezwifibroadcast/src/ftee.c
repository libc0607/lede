/* ftee - clone stdin to stdout and to a named pipe 
(c) racic@stackoverflow
WTFPL Licence */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    int readfd, writefd;
    struct stat status;
    char *fifonam;
    char buffer[BUFSIZ];
    ssize_t bytes;

    signal(SIGPIPE, SIG_IGN);

    if(2!=argc)
    {
        printf("Usage:\n someprog 2>&1 | %s FIFO\n FIFO - path to a"
            " named pipe, required argument\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    fifonam = argv[1];

    readfd = open(fifonam, O_RDONLY | O_NONBLOCK);
    if(-1==readfd)
    {
        perror("ftee: readfd: open()");
        exit(EXIT_FAILURE);
    }

    if(-1==fstat(readfd, &status))
    {
        perror("ftee: fstat");
        close(readfd);
        exit(EXIT_FAILURE);
    }

    if(!S_ISFIFO(status.st_mode))
    {
        printf("ftee: %s in not a fifo!\n", fifonam);
        close(readfd);
        exit(EXIT_FAILURE);
    }

    writefd = open(fifonam, O_WRONLY | O_NONBLOCK);
    if(-1==writefd)
    {
        perror("ftee: writefd: open()");
        close(readfd);
        exit(EXIT_FAILURE);
    }

    close(readfd);

    while(1)
    {
        bytes = read(STDIN_FILENO, buffer, sizeof(buffer));
        if (bytes < 0 && errno == EINTR)
            continue;
        if (bytes <= 0)
            break;

        bytes = write(STDOUT_FILENO, buffer, bytes);
        if(-1==bytes)
            perror("ftee: writing to stdout");
        bytes = write(writefd, buffer, bytes);
        if(-1==bytes);//Ignoring the errors
    }
    close(writefd); 
    return(0);
}