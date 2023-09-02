-module(lesson3_task4v5).
-export([decode/1]).

decode_unquote(Binary, Word) ->
case Binary of
	<<"'", Rest/binary>> -> [Rest, Word];
	<<Char/utf8, Rest/binary>> -> decode_unquote(Rest, <<Word/binary, Char/utf8>>);
	<<>> -> [<<>>, Word]
end.

decode_value_simple(Binary, Word) ->
case Binary of
	<<" ", Rest/binary>> -> [Rest, Word];
	<<",", Rest/binary>> -> [<<",", Rest/binary>>, Word];
	<<"}", Rest/binary>> -> [<<"}", Rest/binary>>, Word];
	<<"]", Rest/binary>> -> [<<"]", Rest/binary>>, Word];
	<<Char/utf8, Rest/binary>> -> decode_value_simple(Rest, <<Word/binary, Char/utf8>>);
	<<>> -> [<<>>, Word]
end.

%decode_value_simple(Rest, , ) ->
%	(),


decode_value(Binary, Value) ->
%io:format("Binary: ~p~n", [Binary]),
%io:format("value: ~p~n", [Value]),
case Binary of
	<<" ",  Rest/binary>> -> decode_value(Rest, Value);
	<<"\n", Rest/binary>> -> decode_value(Rest, Value);
	<<"'",  Rest/binary>> -> decode_unquote(Rest, <<>>);
	<<"{",  Rest/binary>> -> decode_object(Rest, [], <<>>);
	<<"[",  Rest/binary>> -> decode_list(Rest, []);
	<<>> -> [<<>>, Value];
	<<Rest/binary>> ->
		[DecodeVSRest, DecodeVSValue] = decode_value_simple(Rest, <<>>),
		[DecodeVSRest, binary:bin_to_list(DecodeVSValue)]
end.

decode_list(Binary, List) ->
io:format("Binary: ~p~n", [Binary]),
io:format("List: ~p~n", [List]),
case Binary of
	<<" ",  Rest/binary>> -> decode_list(Rest, List);
	<<"\n", Rest/binary>> -> decode_list(Rest, List);
	<<",",  Rest/binary>> -> decode_list(Rest, List);
	<<"{",  Rest/binary>> -> decode_object(Rest, [], <<>>);
	<<"[",  Rest/binary>> -> decode_list(Rest, []);
	<<"]",  Rest/binary>> -> [Rest, List];
%	<<>> -> [<<>>, Value];
	<<"'",  Rest/binary>> ->
		[DecodeListRest, DecodeListValue] = decode_unquote(Rest, <<>>),
		decode_list(DecodeListRest, [DecodeListValue|List]);
	<<Rest/binary>> ->
		[DecodeVSRest, DecodeVSValue] = decode_value_simple(Rest, <<>>),
		decode_list(DecodeVSRest, [DecodeVSValue|List])
end.

decode_object(Binary, Object, Key) ->
%io:format("Binary: ~p~n", [Binary]),
%io:format("Object: ~p~n", [Object]),
%io:format("Key: ~p~n", [Key]),
case Binary of
	<<" ",  Rest/binary>> -> decode_object(Rest, Object, Key);
	<<"\n", Rest/binary>> -> decode_object(Rest, Object, Key);
	<<"'",  Rest/binary>> ->
		[DecodeKeyRest, DecodeKeyKey] = decode_unquote(Rest, <<>>),
		decode_object(DecodeKeyRest, Object, DecodeKeyKey);
	<<":",  Rest/binary>> ->
		[DecodeValueRest, DecodeValueValue] = decode_value(Rest, <<>>),
		decode_object(DecodeValueRest, [{Key, DecodeValueValue} | Object], <<>>);
	<<",",  Rest/binary>> -> decode_object(Rest, Object, <<>>);
	<<"}",  Rest/binary>> -> [Rest, Object]
%	<<>> -> Object
end.

decode(Binary) ->
case Binary of
	<<"{",  Rest/binary>> ->
		[_, DecodeObjectObject] = decode_object(Rest, [], <<>>),
%		[DecodeObjectObject, decode(DecodeObjectRest)];
		DecodeObjectObject;
	<<_/utf8, Rest/binary>> -> decode(Rest);
	<<>> -> {}
end.
