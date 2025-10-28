static
void TEMPLATE_FUNC_NAME(const void *__restrict indata_p,
                        unsigned indatabsz,
                        void *__restrict outdata_0_p,
                        void *__restrict outdata_1_p,
                        void *__restrict outdata_2_p,
                        void *__restrict outdata_3_p,
                        void *__restrict outdata_4_p,
                        void *__restrict outdata_5_p,
                        unsigned outdatabsz)
{
    unsigned i = indatabsz;
    if ((outdatabsz) < i)
        i = (outdatabsz);

    const uint32_t* indata = (uint32_t*)indata_p;

    uint32_t* outdata_0 = (uint32_t*)outdata_0_p;
    uint32_t* outdata_1 = (uint32_t*)outdata_1_p;
    uint32_t* outdata_2 = (uint32_t*)outdata_2_p;
    uint32_t* outdata_3 = (uint32_t*)outdata_3_p;
    uint32_t* outdata_4 = (uint32_t*)outdata_4_p;
    uint32_t* outdata_5 = (uint32_t*)outdata_5_p;

    for (; i >= 24; i -= 24)
    {
        *outdata_0++ = *indata++;
        *outdata_1++ = *indata++;
        *outdata_2++ = *indata++;
        *outdata_3++ = *indata++;
        *outdata_4++ = *indata++;
        *outdata_5++ = *indata++;
    }

    // do nothing with leftover
}

#undef TEMPLATE_FUNC_NAME
