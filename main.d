import std.range, std.stdio;
import fft, plotting;

void main()
{
    cdouble[1024] data = 0 + 0i;
    data[0] = 1 + 0i;
    FFT(data);

    double[128] pdata = 2;
    plot(pdata);
    show();
}
