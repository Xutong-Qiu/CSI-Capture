#include <libssh/libssh.h>
const int verbosity = SSH_LOG_PROTOCOL;
const int port = 22;
const int num_host = 2;
const char* addrs[] = {"192.168.51.98", "192.168.51.125"};
const char* usernames[] = {"pi", "pi"};
const char* keys[] = {"12345678", "12345678"};
