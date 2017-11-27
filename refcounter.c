#include "refcounter.h"

const int get_ref_count(const char* _key) {
    return 1;
}

int is_garbage(const char* _key) {
    return 0;
}

int inc_ref_count(const char* _key) {
    return 0;
}

int dec_ref_count(const char* _key) {
    return 0;
}

