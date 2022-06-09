```console
> make compile-mac

make compile-c-mac
gcc -fPIC -dynamiclib -I src src/ext.c -o dist/extc.dylib
make compile-zig-mac
zig build-lib -O ReleaseSafe -fPIC -Isrc -dynamic src/ext.zig
mv libext.dylib dist/extzig.dylib
```

```console
> ll dist

total 336
-rwxr-xr-x  1 q  staff    17K  9 Jun 08:51 extc.dylib*
-rwxr-xr-x  1 q  staff   144K  9 Jun 08:52 extzig.dylib*
```

```console
> sqlite3

SQLite version 3.38.5 2022-05-06 15:25:27
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
```

```sql
sqlite> .load dist/extzig
sqlite> .load dist/extc
sqlite> with recursive ten(x) as (select 1 union all select x+100 from ten where x<1000) select sumc(x) from ten;
5511.0
sqlite> with recursive ten(x) as (select 1 union all select x+100 from ten where x<1000) select sumzig(x) from ten;
-- ctx=anyopaque@1080164b0 -- note that this pointer is 8-byte aligned
-- ...
5511
```

```console
> mix deps.get

> iex -S mix
Erlang/OTP 25 [erts-13.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]
```

```elixir
iex(1)> E.sumc
[5511.0]

iex(2)> E.sumzig
# ctx=anyopaque@1425cb21c -- note that this pointer is 4-byte aligned
# thread 8760720 panic: incorrect alignment
```

---

Workaround: https://github.com/ruslandoga/sqlite-zig-problem/pull/1
