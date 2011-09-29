module plotting;

import std.array, std.exception, std.path, std.process, std.file, std.string;

/*
 * Plotting wrapper for Python's matplotlib
 */
alias std.string.newline newline;

shared size_t count;

void plot(TS...)(TS ts)
{
    // declare variables
    foreach(i, T; TS)
    {
        curscript ~= std.string.format("data%s =", count + i);
        static if (is(T == string))
            curscript ~= std.string.format("'%s'", ts[i]);
        else static if (is(T U : U[]) && is(U : creal))
        {
            // python uses j instead of i for the imaginary part
            auto s = std.string.format("%s", ts[i]);
            curscript ~= replace(s, "i", "j");
        }
        else
            curscript ~= std.string.format("%s", ts[i]);
        curscript ~= newline;
    }

    curscript ~= "plot(";
    foreach(i; 0 .. TS.length)
    {
        if (i)
            curscript ~= ", ";
        curscript ~= std.string.format("data%s", count + i);
    }
    curscript ~= ")";
    curscript ~= newline;
    count += TS.length;
}

void figure()
{
    curscript ~= "figure()" ~ newline;
}

void show()
{
    curscript ~= "show()" ~ newline;
    auto path = std.path.buildPath(tmpdir, "script");
    std.file.write(path, curscript);
    enforce(!std.process.system("python " ~ path));
    curscript = null;
}

private:

string _tmpdir;

@property string tmpdir()
{
    if (!_tmpdir)
    {
        auto tmp = std.process.getenv("TEMP");
        version(Posix)
            tmp = "/tmp";
        else
            enforce(!tmp.empty, "No tmp dir found, env var TEMP unset.");

        _tmpdir = std.path.buildPath(tmp, "deleteme_aca");
        std.file.mkdir(_tmpdir);
    }
    return _tmpdir;
}

shared static ~this()
{
    if (_tmpdir)
        std.file.rmdirRecurse(_tmpdir);
}

string _curscript;

@property ref string curscript()
{
    if (_curscript.empty)
        _curscript =
            "from pylab import *" ~ newline;
    return _curscript;
}
