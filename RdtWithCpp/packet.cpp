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

        // Add the sequence number to the string
        string seqNumStr = to_string(seqNum);
        for (int i = 0; i < 3-seqNumStr.length() ; i++) {
            packet += "0";
        }
        packet += to_string(seqNum);

        // Add the acknowledgement number to the string
        string ackNumStr = to_string(ackNum);
        for (int i = 0; i < 3-ackNumStr.length() ; i++) {
            packet += "0";
        }
        packet += to_string(ackNum);

        // Add the data to the string
        packet += data;

        return packet;
    }

    void fromString(string rawData) {
        // TODO: Get fromString working
        string seqNumStr, ackNumStr;
        for (int i = 0; i < rawData.length(); i++) {
            if (i < 3)
                seqNumStr += rawData[i];
            else if (i >= 3 && i < 6)
                ackNumStr += rawData[i];
            else
                data += rawData[i];
        }
        seqNum = stoi( seqNumStr );
        ackNum = stoi( ackNumStr );
    }

    void calcChecksum() {
        // TODO: Calculate checksum of data
        for (int i = 0; i < data.length(); i++) {
            checksum += (int)data[i];
        }
    }

    int dataLen() {
        return data.length();
    }
};

int main() {
    Packet x = Packet();
    x.seqNum = 1;
    x.ackNum = 2;
    x.data = "hey!";
    string y = x.toString();
    cout << y << endl;
    Packet z = Packet();
    z.fromString( y );
    cout << z.data << endl;
    z.calcChecksum();
    printf("%d\n", z.checksum);
}
