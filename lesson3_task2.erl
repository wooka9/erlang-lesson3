-module(lesson3_task2).
-export([words/1]).

words(Bin) ->
	words(Bin, <<>>).

words(<<" ",Rest/binary>>, Word) ->
	[Word|words(Rest,<<>>)];
words(<<Char/utf8, Rest/binary>>, Word) ->
	words(Rest, <<Word/binary, Char/utf8>>);
words(<<>>, Word) ->
	[Word].
