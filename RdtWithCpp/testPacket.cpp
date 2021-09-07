/* Used to test the packet file
 * Tests in this file include:
 *  - create a basic packet
 *  - toString() functionality
 *  - fromString() functionality
 *  - verufyChecksum() functionality
 */

#include "packet.h"

int main() {
    // Create a basic packet
    Packet x = Packet();
    x.seqNum = 1;
    x.ackNum = 2;
    x.data = "hey!";
    x.calcChecksum();

    // Test toString()
    string y = x.toString();
    cout << "packet toString: ";
    cout << y << endl;

    // Test fromString()
    Packet z = Packet();
    z.fromString( y );
    cout << "packet data: ";
    cout << z.data << endl;

    // Test verifyChecksum
    z.calcChecksum();
    printf("checksum value: %d\n", z.checksum);
    z.data = "hiy!";
    bool isTrue = z.verifyChecksum();
    printf("verifyChecksum, should be 0: %d\n", isTrue);
}
