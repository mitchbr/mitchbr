#include <unistd.h>
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <iostream>
#include <string>

using namespace std;

#define PORT 8080

int connectToClient() {
    // REF: https://www.geeksforgeeks.org/socket-programming-cc/
    
    int server_socket, client_connect;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);

    // Create the server socket
    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0)
    {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Attach the server to the defined PORT
    if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)))
    {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    // Grab some address information
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons( PORT );

    printf("Waiting for client connection...\n");
       
    // Bind the server to the defined PORT
    if (bind(server_socket, (struct sockaddr *)&address, 
                                 sizeof(address))<0)
    {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }
    if (listen(server_socket, 3) < 0)
    {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    // Connect to the client
    if ((client_connect = accept(server_socket, (struct sockaddr *)&address, 
                       (socklen_t*)&addrlen))<0)
    {
        perror("accept");
        exit(EXIT_FAILURE);
    }

    return client_connect;
}

void send_message(int destination, int start_index, const char* contents) {
    char* packet = (char*) malloc(5);
    
    for (int i = 0; i < 4; i++) {
        sprintf(packet, "%.*s", 4, contents + start_index + 4*i);
        printf("Packet: %s\n", packet);
        send(destination , packet , strlen(packet) , 0 );
    }
    printf("Hello message sent\n");
}

int main() {
    int index = 0;
    const char *message = "Hello from server, I can't think today";
    char len[4] = {0};
    sprintf(len, "%lu", strlen(message));

    // Establish the connection with the client
    int client = connectToClient();

    // Begin communications with the client
    send(client, len, strlen(len), 0);

    while (index < strlen(message)) {
        send_message(client, index, message);
        index += 16;
    }

    return 0;
}
