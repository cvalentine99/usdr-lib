static
void TEMPLATE_FUNC_NAME(const void *__restrict indata,
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
    if ((outdatabsz / 2) < i)
        i = (outdatabsz / 2);

    const int16_t *in = (const int16_t *)indata;

    float* outdata_0 = (float*)outdata_0_p;
    float* outdata_1 = (float*)outdata_1_p;
    float* outdata_2 = (float*)outdata_2_p;
    float* outdata_3 = (float*)outdata_3_p;
    float* outdata_4 = (float*)outdata_4_p;
    float* outdata_5 = (float*)outdata_5_p;

    for (; i >= 24; i -= 24)
    {
        const float i0 = *in++;
        const float q0 = *in++;
        const float i1 = *in++;
        const float q1 = *in++;
        const float i2 = *in++;
        const float q2 = *in++;
        const float i3 = *in++;
        const float q3 = *in++;
        const float i4 = *in++;
        const float q4 = *in++;
        const float i5 = *in++;
        const float q5 = *in++;

        *(outdata_0++) = i0 * CONV_SCALE;
        *(outdata_0++) = q0 * CONV_SCALE;
        *(outdata_1++) = i1 * CONV_SCALE;
        *(outdata_1++) = q1 * CONV_SCALE;
        *(outdata_2++) = i2 * CONV_SCALE;
        *(outdata_2++) = q2 * CONV_SCALE;
        *(outdata_3++) = i3 * CONV_SCALE;
        *(outdata_3++) = q3 * CONV_SCALE;
        *(outdata_4++) = i4 * CONV_SCALE;
        *(outdata_4++) = q4 * CONV_SCALE;
        *(outdata_5++) = i5 * CONV_SCALE;
        *(outdata_5++) = q5 * CONV_SCALE;
    }

    // do nothing with leftover
}

#undef TEMPLATE_FUNC_NAME
