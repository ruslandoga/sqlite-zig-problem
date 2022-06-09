const c = @cImport(@cInclude("../deps/exqlite/c_src/sqlite3ext.h"));
const std = @import("std");

var sqlite3: *c.sqlite3_api_routines = undefined;

const TotalError = error{NoTotal};

fn getTotal(ctx: ?*c.sqlite3_context) TotalError!*c_longlong {
    const totalCtx = sqlite3.aggregate_context.?(ctx, @sizeOf(c_longlong));
    std.debug.print("ctx={}\n", .{totalCtx});
    // std.debug.print("TypeOf={}, isAligned4={}, isAligned8={}, totalCtx={}\n", .{
    //     @TypeOf(totalCtx),
    //     std.mem.isAligned(@ptrToInt(totalCtx.?), 4),
    //     std.mem.isAligned(@ptrToInt(totalCtx.?), 8),
    //     totalCtx,
    // });

    // const p = @ptrCast([*]u8, totalCtx.?);
    // std.debug.print("deref: {} ", .{@ptrCast(*u8, p).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 1).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 2).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 3).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 4).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 5).*});
    // std.debug.print("{} ", .{@ptrCast(*u8, p + 6).*});
    // std.debug.print("{}\n", .{@ptrCast(*u8, p + 7).*});

    const totalCtxAligned = @alignCast(@alignOf(c_longlong), totalCtx);
    // std.debug.print("{}, {}\n", .{ @TypeOf(totalCtxAligned), totalCtxAligned });

    const total = @ptrCast(?*c_longlong, totalCtxAligned);

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
