-module(lesson3_task4v1).
-export([decode/1]).

decode(Binary) -> decode(Binary,<<>>).

%io:format("Bin: ~p~n", [Bin]),
%io:format("Sep: ~p~n", [BinSep]),
%io:format("Word: ~p~n", [Word]),


decode_unquote(Binary, Word) ->
case Binary of
	<<"'", Rest/binary>> -> [Rest, Word];
	<<Char/utf8, Rest/binary>> -> decode_unquote(Rest, <<Word/binary, Char/utf8>>);
	<<>> -> [<<>>, Word]
end.

decode(Binary, Json) ->
io:format("Binary: ~p~n", [Binary]),
io:format("Json: ~p~n", [Json]),
case Binary of
	<<" " , Rest/binary>> -> decode(Rest, Json);
	<<"\n", Rest/binary>> -> decode(Rest, Json);
	<<"'",  Rest/binary>> ->
	[UnquoteRest, UnquoteWord] = decode_unquote(Rest, <<>>),
	decode(UnquoteRest, <<Json/binary, UnquoteWord/binary>>);
	<<Char/utf8, Rest/binary>> -> decode(Rest, <<Json/binary, Char/utf8>>);
	<<>> -> Json
end.
