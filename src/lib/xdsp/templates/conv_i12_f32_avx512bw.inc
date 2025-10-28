const __m512  scale = _mm512_set1_ps(CONV_SCALE);

#define CONVERT_I12_F32_BLOCK(reg, res0, res1) \
{   \
    __m512i result; \
    CONVERT_I12_I16_BLOCK(reg, result); \
    \
    __m512i d0 = _mm512_cvtepi16_epi32(_mm512_castsi512_si256(result)); \
    __m512i d1 = _mm512_cvtepi16_epi32(_mm512_extracti64x4_epi64(result, 1)); \
    \
    res0 = _mm512_cvtepi32_ps(d0); \
    res1 = _mm512_cvtepi32_ps(d1); \
    \
    res0 = _mm512_mul_ps(res0, scale); \
    res1 = _mm512_mul_ps(res1, scale); \
}
