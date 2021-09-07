#include <unistd.h>
#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <time.h>
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
        string message, strPacket[4];
        char len[4];

    void initServer(string text) {
        // Init public variables
        index = 0;
        message = text;
        sprintf(len, "%lu", message.length());

        // Seed random vars
        srand( time( NULL ) );

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
        while (index < message.length()) {
            sendMessage(client, message);
            recvAck();
        }
    }

    void sendMessage(int destination, string contents) {
        char data[5] = {0};
        Packet packet;
        
        // Create packet strings
        for (int i = 0; i < 4; i++) {
            if (index > message.length()) {
                strPacket[i] = "";
            } else {
                
                // Collect packet data
                sprintf(data, "%.*s", 4, contents.c_str() + index);
                packet.data = data;
                packet.seqNum = index/4;
                packet.ackNum = 0;
                packet.calcChecksum();
                strPacket[i] = packet.toString();

                // Reset data for the next packet
                memset(data, 0, sizeof data);
                packet.resetPacket();
                index += 4;
            }
        }
        
        // Make the data unreliable
        scrambleData();

        // Once the data has been tampered, send packets
        for (int i = 0; i < 4; i++) {
            if (!strPacket[i].empty()) {
                // Send the packet to the client
                cout << "Packet: " << strPacket[i] << endl;
                send(destination , strPacket[i].c_str() , 13 , 0 );
            }
        }
    }

    void recvAck() {
        int readValue;
        char buffer[13];

        for (int i = 0; i < 4; i++) {
            // TODO: Somehow time this out if there are less than 4 ACKs
            readValue = read( client, buffer, 12 );
            cout << "ACK received: " << buffer << endl;
        }
    }

    void scrambleData() {
        // Data scramble part 1: sending packets out of order
        // Randomly decide which packets to swap
        int swap1 = rand() % 4;
        int swap2 = rand() % 4;

        // Swap packets
        string temp = strPacket[swap1];
        strPacket[swap1] = strPacket[swap2];
        strPacket[swap2] = temp;

        // Data scramble part 2: drop packets
        // TODO: implement

        // Data scramble part 2: devalidate data
        int scramble = rand() % 4;
        strPacket[scramble].at(10) = 'x';

    }
};

int main() {
    string message = "Hello from server, I can't think today";
    Server server;

    server.initServer(message);

    server.processComms();

    return 0;
}
