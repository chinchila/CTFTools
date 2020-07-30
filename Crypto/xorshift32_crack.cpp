#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint32_t xorshift(uint64_t *m_seed, int a, int b, int c) {
    uint64_t result = *m_seed * 0xd989bcacc137dcd5ull;
    *m_seed ^= *m_seed >> a;
    *m_seed ^= *m_seed << b;
    *m_seed ^= *m_seed >> c;
    return (uint32_t)(result >> 32ull);
}

int main() {
    uint32_t output1 = 1;
    uint32_t output2 = 2;
    for (uint64_t low = 0; low <= 0xFFFFFFFF; low++) {
        uint64_t fullmult = low + ((uint64_t)output1 << 32);
        uint64_t reversedstate = 0x95c11c128eba7c7d * fullmult;
        uint64_t pristine = reversedstate;
        if (xorshift(&reversedstate, 11, 31, 18) != output1) printf("bug");
        if (xorshift(&reversedstate, 11, 31, 18) == output2) {
            printf("found it! Starting state: %llx \n", pristine); 
            printf("outputs:\n");
            for(int k = 0; k < 5; k++) {
                printf(" %u \n",xorshift(&pristine, 11, 31, 18)); 
            }
            return EXIT_SUCCESS;
        }
  }
  return EXIT_FAILURE;
}