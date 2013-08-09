%%
%% bin_utf
%% Tiny unicode binary string manipulation lib for erlang
%% Copyright 2013 by Yuriy Bogdanov <chinsay@gmail.com>
%%
%% (MIT LICENSE)
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%% 
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%% 
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.

-module(bin_utf).

-export([len/1, substr/2, substr/3, is_unicode_valid/1]).

-spec len(String :: iolist()) -> non_neg_integer().

len(String) when is_list(String) ->
  len(iolist_to_binary(String));
len(String) ->
  len(String, 0).

len(<<>>, N) -> N;
% OPTIMIZED: creation of sub binary delayed
len(<<_/utf8, Rest/binary>>, N) ->
  len(Rest, N + 1).

-spec substr(String :: iolist(), Start :: non_neg_integer()) -> binary().

substr(String, Start) when is_list(String) ->
  substr(iolist_to_binary(String), Start);
substr(String, Start) ->
  substr(String, Start, infinity).

-spec substr(String :: iolist(), Start :: non_neg_integer(), Len :: non_neg_integer()) -> binary().

substr(String, Start, Len) when is_list(String) ->
  substr(iolist_to_binary(String), Start, Len);
substr(<<>>, _Start, _Len) -> <<>>;
substr(String, Start, Len) ->
  substr(String, Start, Len, 0, <<>>, 0).

substr(<<>>, _Start, _Len, _I, Acc, _L) -> Acc;
% NOT OPTIMIZED: sub binary is used or returned
substr(<<Rest/binary>>, I, infinity, I, _, _) -> Rest;
% OPTIMIZED: creation of sub binary delayed
substr(<<C/utf8, Rest/binary>>, Start, Len, I, Acc, L) when I >= Start andalso L < Len ->
  substr(Rest, Start, Len, I + 1, <<Acc/binary, C/utf8>>, L + 1);
substr(<<_/utf8, Rest/binary>>, Start, Len, I, Acc, 0) ->
  substr(Rest, Start, Len, I + 1, Acc, 0);
substr(_String, _Start, L, _I, Acc, L) -> Acc.

-spec is_unicode_valid(Str :: iolist()) -> true | false.

is_unicode_valid(Str) ->
  is_binary(unicode:characters_to_binary(Str)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

len_test() ->
  ?assertEqual(5, len(<<"hello">>)),
  ?assertEqual(6, len(<<"привет">>)),
  ?assertEqual(12, len(<<"hello привет">>)),
  ?assertEqual(12, len([<<"привет">>, " ", ["hello"]])),
  ?assertEqual(0, len(<<>>)),
  ?assertEqual(0, len("")),
  ok.

substr2_test() ->
  ?assertEqual(<<"hello">>, substr(<<"hello">>, 0)),
  ?assertEqual(<<"llo">>, substr(<<"hello">>, 2)),
  ?assertEqual(<<>>, substr(<<"hello">>, 5)),
  ?assertEqual(<<>>, substr(<<"hello">>, 6)),

  ?assertEqual(<<"привет">>, substr(<<"привет">>, 0)),
  ?assertEqual(<<"ивет">>, substr(<<"привет">>, 2)),
  ?assertEqual(<<>>, substr(<<"привет">>, 6)),
  ?assertEqual(<<>>, substr(<<"привет">>, 7)),

  ?assertEqual(<<"hello">>, substr([<<"привет">>, " ", ["hello"]], 7)),
  ok.

substr3_test() ->
  ?assertEqual(<<"hello">>, substr(<<"hello">>, 0, 5)),
  ?assertEqual(<<"hell">>, substr(<<"hello">>, 0, 4)),
  ?assertEqual(<<"ell">>, substr(<<"hello">>, 1, 3)),
  ?assertEqual(<<"ello">>, substr(<<"hello">>, 1, 10)),
  ?assertEqual(<<>>, substr(<<"hello">>, 5, 10)),

  ?assertEqual(<<"привет">>, substr(<<"привет">>, 0, 6)),
  ?assertEqual(<<"приве">>, substr(<<"привет">>, 0, 5)),
  ?assertEqual(<<"рив">>, substr(<<"привет">>, 1, 3)),
  ?assertEqual(<<"ривет">>, substr(<<"привет">>, 1, 10)),
  ?assertEqual(<<>>, substr(<<"привет">>, 6, 10)),

  ?assertEqual(<<"вет hel">>, substr([<<"привет">>, " ", ["hello"]], 3, 7)),
  ok.

-endif.
