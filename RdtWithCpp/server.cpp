#include <unistd.h>
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <iostream>
#include <string>

#include "packet.h"

using namespace std;

#define PORT 8080


class Server {
    public:
        int index, client;
        char* message;
        char len[4];

    void initServer(char* text) {
        // Init public variables
        index = 0;
        message = text;
        sprintf(len, "%lu", strlen(message));

        // Connect to client
        client = connectToClient();

        // Send message length
        send(client, len, 4, 0);
    }

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

        cout << "Waiting for client connection..." << endl;
        
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

        cout << "Connected to client, sending data..." << endl;
        
        return client_connect;
    }

    void processComms() {
        while (index < strlen(message)) {
            send_message(client, message);
        }
    }

    void send_message(int destination, const char* contents) {
        char data[5] = {0};
        Packet packet;
        string str_packet;
        
        for (int i = 0; i < 4; i++) {
            if (index > strlen(message))
                return;
            
            // Collect packet data
            sprintf(data, "%.*s", 4, contents + index);
            packet.data = data;
            packet.seqNum = index/4;
            packet.ackNum = 0;
            packet.calcChecksum();
            str_packet = packet.toString();

            // Send the packet to the client
            cout << "Packet: " << str_packet << endl;
            send(destination , str_packet.c_str() , 13 , 0 );

            // Reset data for the next packet
            memset(data, 0, sizeof data);
            packet.packet = ""; // TODO: reset packet.packet somewhere else
            index += 4;
        }
    }

};

int main() {
    char *message;
    message = "Hello from server, I can't think today";
    Server server;

    server.initServer(message);

    server.processComms();

    return 0;
}
