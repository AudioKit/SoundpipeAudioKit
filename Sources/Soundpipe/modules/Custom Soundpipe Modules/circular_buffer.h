#ifndef circular_buffer_h
#define circular_buffer_h

#include <stdio.h>

typedef struct circular_buffer {
    void *buffer;     // data buffer
    void *buffer_end; // end of data buffer
    size_t capacity;  // maximum number of items in the buffer
    size_t count;     // number of items in the buffer
    size_t writePos;  // the write position
    size_t readPos;   // the read position
    size_t sz;        // size of each item in the buffer
    void *head;       // pointer to head
    void *tail;       // pointer to tail
} circular_buffer;

void cb_init(circular_buffer *cb, size_t capacity, size_t sz);
void cb_free(circular_buffer *cb);
void cb_push_back(circular_buffer *cb, const void *item);
void cb_read_at_index_behind_write(circular_buffer *cb, int idx, void **value);
void cb_pop_front(circular_buffer *cb, void *item);
void cb_pop_multiple(circular_buffer *cb, int16_t *itemArray, int count, int moveReadheadBy);

#endif /* circular_buffer_h */
