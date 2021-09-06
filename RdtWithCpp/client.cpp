#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <string>

#include "packet.h"

using namespace std;

#define PORT 8080

int connectToServer() {
    // REF: https://www.geeksforgeeks.org/socket-programming-cc/

    int sock = 0;
    struct sockaddr_in server_address;

    // Create the client socket
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        printf("\n Socket creation error \n");
        return -1;
    }
   
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
       
    // Convert IPv4 and IPv6 addresses from text to binary form
    if(inet_pton(AF_INET, "127.0.0.1", &server_address.sin_addr)<=0) 
    {
        printf("\nInvalid address/ Address not supported \n");
        return -1;
    }
   
   // Connnect to the server
    if (connect(sock, (struct sockaddr *)&server_address, sizeof(server_address)) < 0)
    {
        printf("\nConnection Failed \n");
        return -1;
    }

    return sock;
}
   
void send_message(int destination, const char* contents) {
    send(destination , contents , strlen(contents) , 0 );
    printf("Hello message sent\n");
}

string recv_message(int source, int message_len) {
    int read_value, index = 0;
    string message;
    char buffer[5] = {0};

    while (index < message_len) {
        for (int i = 0; i < 4; i++) {
            read_value = read( source , buffer, 4);
            printf("Received: %s\n", buffer );
            message += buffer;
            memset(buffer, 0, sizeof buffer);
            index += 4;
            if (index >= message_len) {
                return message;
            }
        } 
    }
    return message;
}

int main(int argc, char const *argv[]) {
    int message_len, read_value;
    string message;
    char buffer[5];

    // Connect to the server
    int server = connectToServer();

    // Get the message length from the server
    read_value = read( server, buffer, 4);
    sscanf(buffer, "%d", &message_len);

    // Begin communications with the server
    message += recv_message( server, message_len );


    cout << message << endl;

    return 0;
}
