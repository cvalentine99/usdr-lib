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

    //AVX512 block
    {
        #include "conv_i12_i16_avx512bw.inc"
        #include "conv_i12_f32_avx512bw.inc"

        __m512i y0, y1;
        __m512 res0, res1, res2, res3;

        const __m512i idx0 = _mm512_set_epi64(13, 9,12, 8,5,1,4,0);
        const __m512i idx1 = _mm512_set_epi64(15,11,14,10,7,3,6,2);

        for(; i >= 96; i -= 96)
        {
            y0 = _mm512_maskz_loadu_epi64(0b00111111, (const long long*)(in + 0));
            y1 = _mm512_maskz_loadu_epi64(0b00111111, (const long long*)(in + 6));
            in += 12;

            CONVERT_I12_F32_BLOCK(y0, res0, res1);
            CONVERT_I12_F32_BLOCK(y1, res2, res3);

            __m512d d0 = _mm512_shuffle_pd(_mm512_castps_pd(res0), _mm512_castps_pd(res1), 0b00000000);
            __m512d d1 = _mm512_shuffle_pd(_mm512_castps_pd(res0), _mm512_castps_pd(res1), 0b11111111);
            __m512d d2 = _mm512_shuffle_pd(_mm512_castps_pd(res2), _mm512_castps_pd(res3), 0b00000000);
            __m512d d3 = _mm512_shuffle_pd(_mm512_castps_pd(res2), _mm512_castps_pd(res3), 0b11111111);

            _mm512_storeu_pd(outdata_0, _mm512_permutex2var_pd(d0, idx0, d2));
            _mm512_storeu_pd(outdata_1, _mm512_permutex2var_pd(d1, idx0, d3));
            _mm512_storeu_pd(outdata_2, _mm512_permutex2var_pd(d0, idx1, d2));
            _mm512_storeu_pd(outdata_3, _mm512_permutex2var_pd(d1, idx1, d3));

            outdata_0 += 16;
            outdata_1 += 16;
            outdata_2 += 16;
            outdata_3 += 16;
        }

        #undef CONVERT_I12_F32_BLOCK
        #undef CONVERT_I12_I16_BLOCK
    }

    //AVX2 block
    {
        #include "conv_ci12_4cf32_avx2.inc"

        if(i >= 48)
        {
            __m256i r0 = _mm256_maskload_epi64((const long long*)(in + 0), load_mask);
            __m256i r1 = _mm256_maskload_epi64((const long long*)(in + 3), load_mask);
            in += 6;
            i -= 48;

            CONVERT_CI12_4F32_BLOCK(r0, r1);
        }

        #undef CONVERT_CI12_4F32_BLOCK
    }

    //Generic block
    {
        const uint8_t *indata = (const uint8_t*)in;
        #include "conv_ci12_4cf32_generic.inc"
    }
}

#undef TEMPLATE_FUNC_NAME
