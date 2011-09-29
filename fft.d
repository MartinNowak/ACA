module fft;

import core.bitop, std.algorithm, std.exception, std.math, std.range;

bool isPow2(size_t v)
{
    return v != 0 && !(v & (v - 1));
}

/**
Calculate a Fast Fourier Transform (FFT),

Params:
    data    =  - the data to be transformed
    inverse =  - if true, calculate the inverse FFT, else calculate the direct FFT.

Returns:
    FFT of the data.
Note:
    The number of points must be a power of two.
*/

void FFT(cdouble[] data, bool inverse=false)
{
    enforce(!data.empty, "Input data must not be empty.");
    enforce(isPow2(data.length), "Input data length must be a power of 2.");
    enforce(data.length <= uint.max, "Input data length must be less than uint.max.");

    const msb = core.bitop.bsr(data.length);
    foreach(ii; 0 .. cast(uint)data.length) {
        // rewrite jj as the bit-reversed ii, mirrored on msb
        auto jj = core.bitop.bitswap(ii) >> (32 - msb);
        if(jj > ii) // only swap in one direction
            swap(data[ii], data[jj]);
    }

    size_t sub = 1; // number of butterflys per block
    size_t nb = data.length / 2;  // number of blocks
    while(nb > 0) {
        const theta = inverse ? 1.0 * PI / sub : -1.0 * PI / sub;
        const Wp = cos(theta) + sin(theta) * 1i;
        auto W = 1.0 + 0i;

        foreach(jj; 0 .. sub) {
            foreach(ii; 0 .. nb) { // iterate on the blocks

                auto i0 = 2 * ii * sub + jj;
                auto i1 = i0 + sub;
                // apply bufferfly between nodes {i0, i1}
                auto temp = W * data[i1];
                data[i1] = data[i0] - temp;
                data[i0] = data[i0] + temp;
            }
            W *= Wp;
        }
        sub *= 2;
        nb  /= 2;
    }

    if(inverse)  // normalize the output data
        data[] /= cast(cdouble)data.length;

    // clean almost zero real/imaginary parts
    foreach(ref d; data) {
        if(fabs(d.re) < 1e-10)
            d -= d.re;
        if(fabs(d.im) < 1e-10)
            d -= d.im;
    }
}
