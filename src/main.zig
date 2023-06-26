const std = @import("std");

const repl = @import("./repl.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    try repl.Start(allocator);
}
