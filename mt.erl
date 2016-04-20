-module(mt).
-compile([export_all]).

create() ->
    mnesia:create_table(test, [{attributes, [a,b,c,e]}]).


create_disk() ->
    mnesia:create_table(test, [{disc_copies, [node()]}, {attributes, [a,b,c,e]}]).


write_over_2g(0,_) ->
    ok;
write_over_2g(N,Item) ->
    mnesia:sync_transaction(fun() ->
                                    mnesia:write({test,N,Item,a,a})
                            end),
    write_over_2g(N-1).

write_over_2g(N) ->
    Item = lists:duplicate(10000,"abc"),
    write_over_2g(N,Item).

test_insert() ->
    [mnesia:dirty_write(test, {test,Key,a,a,a})||Key  <- lists:seq(1,200000)].

test_read() ->
    [mnesia:dirty_read(test, Key)||Key  <- lists:seq(1,200000)].

report() ->
    {Time1, _} = timer:tc(?MODULE, test_insert,[]),
    {Time2, _} = timer:tc(?MODULE, test_read,[]),
    io:format("insert ~p\n read ~p\n", [Time2,Time1]),
    ok.

%% 尝试写入超过2G.
dets() ->
    {ok, F} = dets:open_file(test,[{type,set},{auto_save,10}]),
    Item = lists:duplicate(10000,"abc"),
    [dets:insert(F,{{seq,A},Item}) || A <- lists:seq(1,100000)],
    ol.
