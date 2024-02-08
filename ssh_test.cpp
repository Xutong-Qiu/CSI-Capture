#include <libssh/libssh.h>
#include <iostream>
#include <cstdlib>
#include <chrono>
#include <thread>
#include <future>
#include <fstream>

int execute_command(ssh_channel channel, const char* command){
    return ssh_channel_request_exec(channel, command);
}

void init_session(ssh_session[] sessions, size_t size){
    for(int i = 0; i< size, ++i){
        sessions[i] = ssh_new();
        if (sessions[i] == nullptr) {
            std::cerr << "Error creating SSH session." << std::endl;
            exit(-1);
        }
    }
}

int main() {
    ssh_session sessions[2];
    int verbosity = SSH_LOG_PROTOCOL;
    int port = 22;
    int pi1_rc, pi2_rc;

    // Initialize session
    init_session(sessions, 2);

    // Set options
    ssh_options_set(sessions[0], SSH_OPTIONS_HOST, "192.168.51.98");
    ssh_options_set(sessions[0], SSH_OPTIONS_USER, "pi");
    ssh_options_set(sessions[0], SSH_OPTIONS_LOG_VERBOSITY, &verbosity);
    ssh_options_set(sessions[0], SSH_OPTIONS_PORT, &port);

    ssh_options_set(sessions[1], SSH_OPTIONS_HOST, "192.168.51.125");
    ssh_options_set(sessions[1], SSH_OPTIONS_USER, "pi");
    ssh_options_set(sessions[1], SSH_OPTIONS_LOG_VERBOSITY, &verbosity);
    ssh_options_set(sessions[1], SSH_OPTIONS_PORT, &port);

    // Connect to server
    pi1_rc = ssh_connect(sessions[0]);
    pi2_rc = ssh_connect(sessions[1]);
    if (pi1_rc != SSH_OK) {
        std::cerr << "Error connecting: " << ssh_get_error(sessions[0]) << std::endl;
        ssh_free(sessions[0]);
        exit(-1);
    }
    if (pi2_rc != SSH_OK) {
        std::cerr << "Error connecting: " << ssh_get_error(sessions[1]) << std::endl;
        ssh_free(sessions[1]);
        exit(-1);
    }

    // Authenticate
    pi1_rc = ssh_userauth_password(sessions[0], nullptr, "1234");
    if (pi1_rc != SSH_AUTH_SUCCESS) {
        std::cerr << "Authentication failed: " << ssh_get_error(sessions[0]) << std::endl;
        ssh_disconnect(sessions[0]);
        ssh_free(sessions[0]);
        exit(-1);
    }

    pi2_rc = ssh_userauth_password(sessions[1], nullptr, "neslrocks!");
    if (pi2_rc != SSH_AUTH_SUCCESS) {
        std::cerr << "Authentication failed: " << ssh_get_error(sessions[1]) << std::endl;
        ssh_disconnect(sessions[1]);
        ssh_free(sessions[1]);
        exit(-1);
    }
    // Execute a command
    ssh_channel pi1_channel = ssh_channel_new(sessions[0]);
    if (pi1_channel == nullptr) return SSH_ERROR;

    ssh_channel pi2_channel = ssh_channel_new(sessions[1]);
    if (pi2_channel == nullptr) return SSH_ERROR;

    pi1_rc = ssh_channel_open_session(pi1_channel);
    if (pi1_rc != SSH_OK) {
        ssh_channel_free(pi1_channel);
        return pi1_rc;
    }

    pi2_rc = ssh_channel_open_session(pi2_channel);
    if (pi2_rc != SSH_OK) {
        ssh_channel_free(pi2_channel);
        return pi2_rc;
    }

    auto start = std::chrono::high_resolution_clock::now();
    std::future<int> pi1_rc_future = std::async(execute_command, pi1_channel, "sudo ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3 > pi1_output.txt 2>&1 ");
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double, std::milli> latency = end - start;
    std::cout << "Command execution request latency: " << latency.count() << " ms" << std::endl;

    start = std::chrono::high_resolution_clock::now();
    std::future<int> pi2_rc_future = std::async(execute_command, pi2_channel, "sudo ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3 > pi2_output.txt 2>&1 ");
    //int rc = ssh_channel_request_exec(pi2_channel, "ls");//1.8-2.5ms
    end = std::chrono::high_resolution_clock::now();

    latency = end - start;
    std::cout << "Command execution request latency: " << latency.count() << " ms" << std::endl;

    pi1_rc = pi1_rc_future.get();
    if (pi1_rc != SSH_OK) {
        ssh_channel_close(pi1_channel);
        ssh_channel_free(pi1_channel);
        return pi1_rc;
    }

    // Cleanup
    ssh_channel_send_eof(pi1_channel);
    ssh_channel_close(pi1_channel);
    ssh_channel_free(pi1_channel);

    ssh_disconnect(sessions[0]);
    ssh_free(sessions[0]);

    ssh_channel_send_eof(pi2_channel);
    ssh_channel_close(pi2_channel);
    ssh_channel_free(pi2_channel);

    ssh_disconnect(sessions[1]);
    ssh_free(sessions[1]);
}
