#include <libssh/libssh.h>
const int num_host = 6;
const char* addrs[] = {"192.168.51.91", "192.168.51.195", "192.168.51.196", "192.168.51.148", "192.168.51.167", "192.168.51.161"};
const char* usernames[] = {"pi", "pi", "pi", "pi", "pi", "pi"};
const char* keys[] = {"12345678", "12345678", "12345678", "12345678", "12345678", "12345678"};
const char* socat_dst_ports[] = {"1231", "1232", "1233", "1234", "1235", "1236"};
const char* socat_dst_ip = "192.168.51.200";
const char* capture_time = "6"; // seconds
const char* output_dir = "/Users/gaofengdong/Desktop/JCAS/Testbed_Setup/MacBook/outputs";

