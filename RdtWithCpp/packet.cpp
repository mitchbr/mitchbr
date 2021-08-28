#include <iostream>
#include <string>

using namespace std;

class Packet {
    public:
        int seqNum;
        int ackNum;
        int checksum;
        string data;
    
    string toString() {
        // TODO: Format data into a single string
        return data;
    }

    int verifyChecksum() {
        // TODO: Calculate checksum of data
        return 1;
    }

    int dataLen() {
        return data.length();
    }
};
