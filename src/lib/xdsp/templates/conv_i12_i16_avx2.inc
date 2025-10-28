const __m256i load_mask = _mm256_set_epi64x(0, -1, -1, -1);

const __m256i mask0 = _mm256_set1_epi64x(0xfff00000fff00000);
const __m256i mask1 = _mm256_set1_epi64x(0x0000fff00000fff0);

const __m256i permmask = _mm256_set_epi32(5, 4, 3, 7, 6, 2, 1, 0);
const __m256i shfl = _mm256_set_epi8(
    0x0f, 0x0e, 0x0d, 0x80, 0x0c, 0x0b, 0x0a, 0x80,
    0x09, 0x08, 0x07, 0x80, 0x06, 0x05, 0x04, 0x80,
    0x0b, 0x0a, 0x09, 0x80, 0x08, 0x07, 0x06, 0x80,
    0x05, 0x04, 0x03, 0x80, 0x02, 0x01, 0x00, 0x80);

#define CONVERT_I12_I16_BLOCK(reg, result) \
{   \
    __m256i v0 = _mm256_permutevar8x32_epi32(reg, permmask); \
    __m256i r  = _mm256_shuffle_epi8(v0, shfl); \
    \
    __m256i r0 = _mm256_and_si256(r, mask0); \
    __m256i r1 = _mm256_and_si256(_mm256_srli_epi64(r, 4), mask1); \
            result = _mm256_or_si256(r0, r1); \
}
