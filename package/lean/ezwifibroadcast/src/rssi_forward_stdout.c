// rssi_forward_stdout by Rodizio.
// Modified by @libc0607
//
// Function:
//		reads rssi from shared memory and writes it to stdout
// Usage: 
//		rssi_forward_stdout /wifibroadcast_rx_status_0 
// Output Format: 
//		#best_dbm,lostpackets\n
// Example: 
//		#-114,5141919\n
// Note:
// 		lostpacket use 4 bytes - means 1145141919810 (>2^32) will overflow

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <resolv.h>
#include <string.h>
#include <utime.h>
#include <unistd.h>
#include <getopt.h>
#include <pcap.h>
#include <endian.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/resource.h>

#include "lib.h"


wifibroadcast_rx_status_t *status_memory_open(char* shm_file) 
{
	int fd;
	for(;;) {
		fd = shm_open(shm_file, O_RDWR, S_IRUSR | S_IWUSR);
		if(fd > 0) 
			break;
		printf("Waiting for rx to be started ...\n");
		usleep(1e6);
	}

	if (ftruncate(fd, sizeof(wifibroadcast_rx_status_t)) == -1) {
		perror("ftruncate");
		exit(1);
	}

	void *retval = mmap(NULL, sizeof(wifibroadcast_rx_status_t), 
						PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (retval == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	
	return (wifibroadcast_rx_status_t*)retval;
}

int main(int argc, char *argv[]) 
{
	wifibroadcast_rx_status_t *t = status_memory_open(argv[1]);
	int best_dbm = -128;
	int lostpackets = 0;
	int cardcounter = 0;
	int number_cards = t->wifi_adapter_cnt;

	for(;;) {
		best_dbm = t->adapter[cardcounter].current_signal_dbm;
		lostpackets = t->lost_packet_cnt;
		fprintf(stdout, "#%d,%d\n", best_dbm, lostpackets);
		usleep(100000);
	}
	return 0;
}