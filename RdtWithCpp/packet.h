#include <iostream>
#include <string.h>

using namespace std;

class Packet {
    public:
        int seqNum;
        int ackNum;
        int checksum;
        string data;
        string packet;
    
    string toString() {

        /* Convert the packet data into a single string to be sent between client and server
         * Packet structure will appear as such:
         * 0000111122223333
         * Where:
         *  - 0's represent sequence number values
         *  - 1's represent ack number values
         *  - 2's represent checusm values
         *  - 3's represent the data of the packet
         */

        // Add the sequence number to the string
        string seqNumStr = to_string( seqNum );
        for ( int i = 0; i < 3-seqNumStr.length( ) ; i++ ) {
            packet += "0";
        }
        packet += seqNumStr;

        // Add the acknowledgement number to the string
        string ackNumStr = to_string( ackNum );
        for ( int i = 0; i < 3-ackNumStr.length( ) ; i++ ) {
            packet += "0";
        }
        packet += ackNumStr;

        // Add the checksum to the string
        string checksumStr = to_string(checksum);
        for ( int i = 0; i < 3-checksumStr.length( ) ; i++ ) {
            packet += "0";
        }
        packet += checksumStr;

        // Add the data to the string
        packet += data;

        return packet;
    }

    void fromString(string rawData) {
        string seqNumStr, ackNumStr, checksumStr;
        for ( int i = 0; i < rawData.length( ); i++ ) {
            if ( i < 3 )
                seqNumStr += rawData[i];
            else if ( i >= 3 && i < 6 )
                ackNumStr += rawData[i];
            else if ( i >= 6 && i < 9 )
                checksumStr += rawData[i];
            else
                data += rawData[i];
        }
        seqNum = stoi( seqNumStr );
        ackNum = stoi( ackNumStr );
        checksum = stoi( checksumStr );
    }

    void calcChecksum() {
        checksum = 0;
        for ( int i = 0; i < data.length( ); i++ ) {
            checksum += ( int ) data[i];
        }
    }

    bool verifyChecksum() {
        int newChecksum = 0;
        for ( int i = 0; i < data.length( ); i++ ) {
            newChecksum += (int)data[i];
        }
        if ( newChecksum != checksum )
            return false;
        else
            return true;
    }

    int dataLen() {
        return data.length( );
    }
};
