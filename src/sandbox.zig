fn testFunc() *const u64 {
    const a: u64 = 4555;
    return &a;
}

const std = @import("std");

fn wow() *const u64 {
    const b: *const u64 = testFunc();
    return b;
}

test "lifetimes" {
    const c = wow();
    std.debug.print("\n{d}\n", .{c.*});
}
