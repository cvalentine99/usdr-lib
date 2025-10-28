static inline
void TEMPLATE_FUNC_NAME(const void *__restrict indata_p,
                        unsigned indatabsz,
                        void *__restrict outdata_0_p,
                        void *__restrict outdata_1_p,
                        unsigned outdatabsz)
{
    unsigned i = indatabsz;
    /* 12 bits -> 32 bits  =>  3 -> 8   */
    if ((outdatabsz * 3 / 8) < i)
        i = (outdatabsz * 3 / 8);

    const uint64_t *in = (const uint64_t*)indata_p;
    float* outdata_0 = (float*)outdata_0_p;
    float* outdata_1 = (float*)outdata_1_p;

    //AVX512 block
    {
        #include "conv_i12_i16_avx512bw.inc"
        #include "conv_i12_f32_avx512bw.inc"

        __m512i y0, y1;
        __m512 res0, res1, res2, res3;

        const __m512i idx0 = _mm512_set_epi64(14,12,10,8,6,4,2,0);
        const __m512i idx1 = _mm512_set_epi64(15,13,11,9,7,5,3,1);

        for(; i >= 96; i -= 96)
        {
            y0 = _mm512_maskz_loadu_epi64(0b00111111, (const long long*)(in + 0));
            y1 = _mm512_maskz_loadu_epi64(0b00111111, (const long long*)(in + 6));
            in += 12;

            CONVERT_I12_F32_BLOCK(y0, res0, res1);
            CONVERT_I12_F32_BLOCK(y1, res2, res3);

            _mm512_storeu_pd(outdata_0 +  0, _mm512_permutex2var_pd(_mm512_castps_pd(res0), idx0, _mm512_castps_pd(res1)));
            _mm512_storeu_pd(outdata_1 +  0, _mm512_permutex2var_pd(_mm512_castps_pd(res0), idx1, _mm512_castps_pd(res1)));
            _mm512_storeu_pd(outdata_0 + 16, _mm512_permutex2var_pd(_mm512_castps_pd(res2), idx0, _mm512_castps_pd(res3)));
            _mm512_storeu_pd(outdata_1 + 16, _mm512_permutex2var_pd(_mm512_castps_pd(res2), idx1, _mm512_castps_pd(res3)));
            outdata_0 += 32;
            outdata_1 += 32;
        }

        #undef CONVERT_I12_F32_BLOCK
        #undef CONVERT_I12_I16_BLOCK
    }

    //AVX2 block
    {
        #include "conv_i12_i16_avx2.inc"
        #include "conv_i12_f32_avx2.inc"

        if(i >= 48)
        {
            __m256i y0 = _mm256_maskload_epi64((const long long*)(in + 0), load_mask);
            __m256i y1 = _mm256_maskload_epi64((const long long*)(in + 3), load_mask);
            in += 6;
            i -= 48;

            __m256 res0, res1, res2, res3;

            CONVERT_I12_F32_BLOCK(y0, res0, res1);
            CONVERT_I12_F32_BLOCK(y1, res2, res3);

            const __m256i idx0 = _mm256_set_epi64x(6,4,2,0);
            const __m256i idx1 = _mm256_set_epi64x(7,5,3,1);

            _mm256_storeu_pd((double*)(outdata_0 + 0), _mm256_permutex2var_pd(_mm256_castps_pd(res0), idx0, _mm256_castps_pd(res1)));
            _mm256_storeu_pd((double*)(outdata_1 + 0), _mm256_permutex2var_pd(_mm256_castps_pd(res0), idx1, _mm256_castps_pd(res1)));
            _mm256_storeu_pd((double*)(outdata_0 + 8), _mm256_permutex2var_pd(_mm256_castps_pd(res2), idx0, _mm256_castps_pd(res3)));
            _mm256_storeu_pd((double*)(outdata_1 + 8), _mm256_permutex2var_pd(_mm256_castps_pd(res2), idx1, _mm256_castps_pd(res3)));
            outdata_0 += 16;
            outdata_1 += 16;
        }

        #undef CONVERT_I12_F32_BLOCK
        #undef CONVERT_I12_F32_BLOCK_STORE1
        #undef CONVERT_I12_I16_BLOCK
    }

    //Generic block
    {
        const uint8_t *indata = (const uint8_t*)in;
        #include "conv_ci12_2cf32_generic.inc"
    }
}
#undef TEMPLATE_FUNC_NAME
