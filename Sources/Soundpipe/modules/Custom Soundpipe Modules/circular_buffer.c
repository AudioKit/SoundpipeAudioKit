#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "circular_buffer.h"

void cb_init(circular_buffer *cb, size_t capacity, size_t sz) {
    cb->buffer = malloc(capacity * sz);
    if(cb->buffer == NULL)
        // handle error
    cb->buffer_end = (char *)cb->buffer + capacity * sz;
    cb->capacity = capacity;
    cb->count = 0;
    cb->readPos = 0;
    cb->writePos = 0;
    cb->sz = sz;
    cb->head = cb->buffer;
    cb->tail = cb->buffer;
}

void cb_free(circular_buffer *cb) {
    free(cb->buffer);
    // clear out other fields too, just to be safe
}

void cb_push_back(circular_buffer *cb, const void *item) {
    if(cb->count == cb->capacity){
        // handle error
    }
    memcpy((char*)cb->buffer + (cb->sz * cb->writePos), item, cb->sz);
    cb->writePos++;
    if (cb->writePos >= cb->capacity) {
        cb->writePos = 0;
    }

    if (cb->count < cb->capacity) {
        cb->count++;
    }
}

/// idx should be negative, indicates number of samples behind write position.
void cb_read_at_index_behind_write(circular_buffer *cb, int idx, void **value) {
    int wrappedIdx = cb->writePos - 1 + idx;
    if (wrappedIdx < 0) {
        wrappedIdx += cb->capacity;
    }

//    memcpy(value, (char*)cb->buffer + (cb->sz * (size_t)wrappedIdx), cb->sz);
    *value = cb->buffer + (cb->sz * wrappedIdx);
}

void cb_pop_front(circular_buffer *cb, void *item) {
    if(cb->count == 0){
        // handle error
    }
    memcpy(item, (char*)cb->buffer + (cb->sz * cb->readPos), cb->sz);
    cb->readPos++;
    if (cb->readPos >= cb->capacity) {
        cb->readPos = 0;
    }
    cb->count--;
}

void cb_pop_multiple(circular_buffer *cb, int16_t *itemArray, int count, int moveReadheadBy) {
    if (cb->count == 0) {
        return;
    }

    int j = 0;
    for (int i = -1 * count + 1; i <= 0; i++) {
        int16_t *item;
        cb_read_at_index_behind_write(cb, i, &item);
        itemArray[j] = *item;
        j += 1;
    }
    cb->count -= moveReadheadBy;
}
