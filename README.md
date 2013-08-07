# Hello
This is tiny unicode binary string manipulation lib for erlang. Since I didn't find any simple and efficient way to do this in erlang, I wrote this little lib.

It was optimized following [erlang efficiency guide](http://www.erlang.org/doc/efficiency_guide/binaryhandling.html) and seems to be very fast.

# len/1

	Str = <<"привет">>,
	6 = bin_utf:len(Str).

# substr/2

	Str = <<"привет">>,
	<<"вет">> = bin_utf:substr(Str, 3).

# substr/3

	Str = <<"привет">>,
	<<"ив">> = bin_utf:substr(Str, 2, 2).