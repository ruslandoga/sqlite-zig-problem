const c = @cImport(@cInclude("../deps/exqlite/c_src/sqlite3ext.h"));
const std = @import("std");

var sqlite3: *c.sqlite3_api_routines = undefined;

const TotalError = error{NoTotal};

fn getTotal(ctx: ?*c.sqlite3_context) TotalError!*c_longlong {
    const size = @sizeOf(c_longlong);
    const alignment = @alignOf(c_longlong);
    const unaligned_ptr = sqlite3.aggregate_context.?(ctx, size + alignment);
    const total = @intToPtr(?*c_longlong, std.mem.alignForward(@ptrToInt(unaligned_ptr), alignment));

    if (total == null) {
        sqlite3.result_error_nomem.?(ctx);
        return TotalError.NoTotal;
    }

    return total.?;
}

fn sumStep(ctx: ?*c.sqlite3_context, _: c_int, argv: [*c]?*c.sqlite3_value) callconv(.C) void {
    const total = getTotal(ctx) catch return;
    total.* += sqlite3.value_int64.?(argv[0]);
}

fn sumFinal(ctx: ?*c.sqlite3_context) callconv(.C) void {
    const total = getTotal(ctx) catch return;
    sqlite3.result_int64.?(ctx, total.*);
}

pub export fn sqlite3_extzig_init(db: ?*c.sqlite3, _: [*c][*c]u8, pApi: [*c]c.sqlite3_api_routines) c_int {
    sqlite3 = pApi.?;
    return sqlite3.create_function.?(db, "sumzig", 1, c.SQLITE_UTF8, null, null, sumStep, sumFinal);
}
