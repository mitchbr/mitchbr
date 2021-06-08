#include "DynamicArray.h"
#include "LinkedList.h"

#include <stdlib.h>

#ifndef HASH_MAP_H
#define HASH_MAP_H

struct hashMap
{
    struct dynamicArray     buckets;
    size_t                  capacity;
    size_t                  size;
};

int hashFunction ( char *key);
void initHashMap ( size_t max_length, struct hashMap *newMap);
void addHashNode ( char *key, int value, struct hashMap *map);
int containsHashNode (char *key, struct hashMap *map);

#endif