#include <stdlib.h>

#ifndef LINKED_LIST_H
#define LINKED_LIST_H

/* Structure to set up linked list nodes */
struct linkedList
{
    char                *key;
    int                 value;
    struct linkedList   *next;
};

struct linkedList *addNode (char *key, int value, struct linkedList *head);
struct linkedList *traverseList (struct linkedList *currNode);
void removeNode (struct linkedList *head, char *key);
int containsNode (struct linkedList *head, char *key);
int listLength (struct linkedList *head);
void freeList (struct linkedList *head);

#endif
