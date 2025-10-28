static
void TEMPLATE_FUNC_NAME(const void *__restrict indata_p,
                        unsigned indatabsz,
                        void *__restrict outdata_0_p,
                        void *__restrict outdata_1_p,
                        void *__restrict outdata_2_p,
                        void *__restrict outdata_3_p,
                        unsigned outdatabsz)
{
    unsigned i = indatabsz;
    /* 12 bits -> 32 bits  =>  3 -> 8   */
    if ((outdatabsz * 3 / 8) < i)
        i = (outdatabsz * 3 / 8);

    float* outdata_0 = (float*)outdata_0_p;
    float* outdata_1 = (float*)outdata_1_p;
    float* outdata_2 = (float*)outdata_2_p;
    float* outdata_3 = (float*)outdata_3_p;

    const uint64_t *in = (const uint64_t*)indata_p;

    #include "conv_ci12_4cf32_avx2.inc"

    __m256i r0, r1;

    while(i >= 48)
    {
        r0 = _mm256_maskload_epi64((const long long*)(in + 0), load_mask);
        r1 = _mm256_maskload_epi64((const long long*)(in + 3), load_mask);
        in += 6;

        CONVERT_CI12_4F32_BLOCK(r0, r1);

        i -= 48;
    }

    #undef CONVERT_CI12_4F32_BLOCK

    const uint8_t *indata = (const uint8_t*)in;
    #include "conv_ci12_4cf32_generic.inc"
}

#undef TEMPLATE_FUNC_NAME
