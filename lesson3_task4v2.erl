-module(lesson3_task4v3).
-export([decode/1]).
-export([decode_object/1]).

decode(Binary) -> decode(Binary,<<>>).

decode_unquote(Binary, Word) ->
case Binary of
	<<"'", Rest/binary>> -> [Rest, Word];
	<<Char/utf8, Rest/binary>> -> decode_unquote(Rest, <<Word/binary, Char/utf8>>);
	<<>> -> [<<>>, Word]
end.

decode_value(Binary, Value) ->
case Binary of
	<<" " , Rest/binary>> -> decode_value(Rest, Value);
	<<"\n", Rest/binary>> -> decode_value(Rest, Value);
	<<"'",  Rest/binary>> -> decode_unquote(Rest, <<>>)
end.

decode_object(Binary) -> decode_object(Binary, [], <<>>).

decode_object(Binary, Object, Key) ->

io:format("Binary: ~p~n", [Binary]),
io:format("Object: ~p~n", [Object]),
io:format("Key: ~p~n", [Key]),

case Binary of
	<<" " , Rest/binary>> -> decode_object(Rest, Object, Key);
	<<"\n", Rest/binary>> -> decode_object(Rest, Object, Key);
	<<"'",  Rest/binary>> ->
		[DecodeKeyRest, DecodeKeyKey] = decode_unquote(Rest, <<>>),
		decode_object(DecodeKeyRest, Object, DecodeKeyKey);
	<<":",  Rest/binary>> ->
		[DecodeValueRest, DecodeValueValue] = decode_value(Rest, <<>>),
		decode_object(DecodeValueRest, [{Key, DecodeValueValue} | Object], <<>>);
	<<",", Rest/binary>> -> decode_object(Rest, Object, <<>>);
	<<"}",  Rest/binary>> -> [Rest, Object];
	<<>> -> Object
end.

decode(Binary, Json) ->
case Binary of
	<<" " , Rest/binary>> -> decode(Rest, Json);
	<<"\n", Rest/binary>> -> decode(Rest, Json);
	<<"{" , Rest/binary>> -> decode_object(Rest, [], <<>>);
%    <<"[" , Rest/binary>> -> decode_list(Rest);
%    <<"]" , Rest/binary>> -> ;
%    <<Char/utf8, Rest/binary>> -> decode(Rest, <<New/binary, Char/utf8>>);
    <<>> -> Json
end.
