
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <time.h>

#define DEFAULT_IF "mon0"

unsigned char frame[] = { /* beacon frame */
	// radiotap header
	0x00, /* version */
	0x00, /* pad */
	0x0c, 0x00, /* header size (12 bytes) */
	0x04, 0x80, 0x00, 0x00, /* present flags (rate and txflags) */
	0x02, /* rate = 2 x 500kHz = 1 MHz*/
	0x00, /* 16-bit alignment padding for the following txflags */
	0x18, 0x00, /* txflags (noack and noseqno) */

	// ieee80211 frame
	0x80, 0x00, /* Frame Control */
	0x00, 0x00, /* Duration */
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, /* DA */
	0x00, 0x00, 0x00, 0x11, 0x22, 0x33, /* SA */
	0x00, 0x00, 0x00, 0x11, 0x22, 0x33, /* BSS ID */
	0x00, 0x00, /* Seq Ctl */
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* Timestamp */
	0x64, 0x00, /* Beacon Interval */
	0x00, 0x00, /* Compat Info */
	0x00, 0x04, 'D', 'E', 'M', 'O', /* SSID */
	0x01, 0x01, 0x82, /* Supported Rates */
	0xac, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
};

int main(int argc, char *argv[])
{
	int sockfd;
	struct ifreq if_idx;
	char ifName[IFNAMSIZ];
	struct sockaddr_ll sll;
	int loop = 0;
	int delay_ms = 0;
	int c;

	strncpy(ifName, DEFAULT_IF, IFNAMSIZ-1);

	while((c = getopt(argc, argv, "i:d:l")) != -1) {
		switch(c) {
		case 'i':
			strncpy(ifName, optarg, IFNAMSIZ-1);
			break;
		case 'd':
			delay_ms = strtol(optarg, 0, 10);
			break;
		case 'l':
			loop = 1;
			break;
		}
	}

	/* Open RAW socket to send on */
	if ((sockfd = socket(AF_PACKET, SOCK_RAW /* | SOCK_NONBLOCK */, htons(ETH_P_ALL))) == -1) {
		perror("socket");
	}

	/* Get the index of the interface to send on */
	memset(&if_idx, 0, sizeof(struct ifreq));
	strncpy(if_idx.ifr_name, ifName, IFNAMSIZ-1);
	if (ioctl(sockfd, SIOCGIFINDEX, &if_idx) < 0)
		perror("SIOCGIFINDEX");

	/* Bind socket to interface */
	memset(&sll, 0, sizeof(sll));
	sll.sll_family = AF_PACKET;
	sll.sll_ifindex = if_idx.ifr_ifindex;
	sll.sll_protocol = htons(ETH_P_ALL);
	if(bind(sockfd, (struct sockaddr*)&sll, sizeof(sll)) < 0) {
		perror("Bind failed");
	}

        do {
		/* Send packet */
		if (send(sockfd, frame, sizeof(frame), 0) < 0)
			perror("Send failed");

		if(delay_ms) {
			struct timespec ts;
			int sec = delay_ms / 1000;
			int msec = delay_ms % 1000;
			ts.tv_sec = sec;
			ts.tv_nsec = 1000000*msec;
			clock_nanosleep(CLOCK_REALTIME, 0, &ts, NULL);
		}
	} while(loop);

	return 0;
}
