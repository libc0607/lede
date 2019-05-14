/* ftees - clone stdin to many named pipe 
(c) racic@stackoverflow
modified by libc0607@github
WTFPL Licence */

/*
*	Usage:
*		yourprogram | ftees n FIFO1 (... FIFOn) 
*		(n up to 16
*	e.g. echo 233 | ftees 3 FIFO1 FIFO2 FIFO3
*/
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
	int readfd;
	int writefd[16] = {0};
	int n = 0;
	int j = 0;
	struct stat status;
	char *fifonam[16];
	char buffer[BUFSIZ];
	ssize_t bytes_r, bytes_w[16];

	signal(SIGPIPE, SIG_IGN);

	if (argc < 2 || argc > 17) {
		printf("Usage:\n\tsomeprog 2>&1 | %s n FIFO1 FIFO2 ... FIFOn \n\tFIFOn - path to a"
			" named pipe, required argument\n\tn up to 16\n", argv[0]);
		exit(EXIT_FAILURE);
	}
	
	n = atoi(argv[1]);
	if (n > 16) {
		printf("Error: n should less than 16!\n");
		exit(EXIT_FAILURE);
	}
	for (j=0; j<n; j++) {
		fifonam[j] = argv[j+2];	// fifonam[0] = argv[2] and so on...
		readfd = open(fifonam[j], O_RDONLY | O_NONBLOCK);
		if (-1 == readfd) {
			perror("ftee: readfd: open()");
			exit(EXIT_FAILURE);
		}

		if (-1 == fstat(readfd, &status)) {
			perror("ftee: fstat");
			close(readfd);
			exit(EXIT_FAILURE);
		}

		if(!S_ISFIFO(status.st_mode)) {
			printf("ftee: %s in not a fifo!\n", fifonam[j]);
			close(readfd);
			exit(EXIT_FAILURE);
		}
		writefd[j] = open(fifonam[j], O_WRONLY | O_NONBLOCK);
		if (-1 == writefd[j]) {
			perror("ftee: writefd: open()");
			close(readfd);
			exit(EXIT_FAILURE);
		}
		close(readfd);
	}
	
	while (1) {
		bytes_r = read(STDIN_FILENO, buffer, sizeof(buffer));
		if (bytes_r < 0 && errno == EINTR)
			continue;
		// Do not close output even if read returns 0
		// but we should sleep a little bit
		// Assume that: ~16Mbit/s(~2,097,152 bytes/s) input, Bufsize 8k bytes
		// (16Mbit/s ~ very good quality @1920x1080 H.264)
		// it will fill 256 bufs per second, ~3.9ms/buf
		// so... maybe a smaller value like 500us, 1ms should work better? 
		// (but higher copy & syscall cost)
		if (bytes_r == 0)	
			usleep(1000);	// +1ms, excited!
		//	break;
		for (j=0; j<n; j++) {
			bytes_w[j] = write(writefd[j], buffer, bytes_r);
			if (-1 == bytes_w[j])
				perror("ftee: writing to fifo");
		}
	}
	for (j=0; j<n; j++) {
		close(writefd[j]); 
	}
	return(0);
}