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

class Client {
    public:
        int message_len, read_value, server, index;
        string message, packets[4];
        char buffer[13];
    
    void initClient() {
        cout << "Connecting to server..." << endl;
        // Connect to the server
        server = connectToServer();

        // Get the message length from the server
        read_value = read( server, buffer, 4);
        sscanf(buffer, "%d", &message_len);

        index = 0;
    }

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

        cout << "Connected to server..." << endl;

        return sock;
    }
    
    void sendMessage(int destination, const char* contents) {
        send(destination , contents , strlen(contents) , 0 );
        printf("Hello message sent\n");
    }

    void processComms() {
        while (index < message_len) {
            recvMessage( );
            processPackets( );
            cout << "Message: ";
            printMessage();
        }
    }

    void recvMessage() {
        int read_value;
        string message;
        char buffer[14] = {0};

        for (int i = 0; i < 4; i++) {
            if (index >= message_len) {
                packets[i] = "";
            }
            else {
                read_value = read( server , buffer, 13);
                printf("Received: %s\n", buffer );
                packets[i]= buffer;
                memset(buffer, 0, sizeof buffer);
                index += 4;
            }
        }
    }

    void processPackets() {
        Packet packet;
        bool checksumCheck;
        int i = 0;

        while (!packets[i].empty() && i < 4) {
            // get packet from string data
            packet.fromString(packets[i]);

            // Verify the checksum
            checksumCheck = packet.verifyChecksum();

            if (checksumCheck) {
                // Add data to the message and send an ACK message
                message += packet.data;

                // TODO: Send ack from seqNum
            }

            packet.resetPacket();
            i++;
        }
    }

    void printMessage() {
        cout << message << endl;
    }
};

int main(int argc, char const *argv[]) {
    Client client;
    client.initClient();

    client.processComms();

    cout << "Full message received:" << endl;
    client.printMessage();

    return 0;
}
