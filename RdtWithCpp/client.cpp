#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <string>

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

int main(int argc, char const *argv[]) {
    int read_value, message_len, index = 0;
    char buffer[5] = {0};
    char message[16] = {0};

    int server = connectToServer();

    // Begin communications with the server
    read_value = read( server, buffer, 4);
    sscanf(buffer, "%d", &message_len);
    printf("%d\n", message_len);

    while (index < message_len) {
        for (int i = 0; i < 4; i++) {
            read_value = read( server , buffer, 4);
            printf("Received: %s\n",buffer );
            sprintf(message, "%s%s", message, buffer);
            memset(buffer, 0, sizeof buffer);
            index += 4;
            if (index >= message_len) {
                break;
                // Break is smelly
            }
        }
        
    }
    printf("%s\n", message);

    return 0;
}
