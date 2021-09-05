/* Used to test the packet file
 * Tests in this file include:
 *
 */

#include "packet.h"

int main() {
    Packet x = Packet();
    x.seqNum = 1;
    x.ackNum = 2;
    x.data = "hey!";
    x.calcChecksum();
    string y = x.toString();
    cout << "packet toString: ";
    cout << y << endl;
    Packet z = Packet();
    z.fromString( y );
    cout << "packet data: ";
    cout << z.data << endl;
    z.calcChecksum();
    printf("checksum value: %d\n", z.checksum);
    z.data = "hiy!";
    bool isTrue = z.verifyChecksum();
    printf("verifyChecksum, should be 0: %d\n", isTrue);
}