const std = @import("std");
const tokens = @import("./tokens.zig");

pub const StatementTypes = enum {
    LET,
    RETURN,
};

pub const Statement = union(StatementTypes) {
    LET: struct {
        token: tokens.Token,
        name: Identifier = undefined,
        value: Expression = Expression{},

        pub fn tokenLiteral(self: @This()) []const u8 {
            return self.token.literal;
        }

        pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{s} {s} = {!s}", .{ self.token.literal, self.name.value, self.value.string(allocator) });
        }
    },
    RETURN: struct {
        token: tokens.Token,
        return_value: Expression = Expression{},

        pub fn tokenLiteral(self: @This()) []const u8 {
            return self.token.literal;
        }
        pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{s} {!s}", .{ self.token.literal, self.return_value.string(allocator) });
        }
    },
    pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            .LET => |let_stmt| return let_stmt.string(allocator),
            .RETURN => |return_stmt| return return_stmt.string(allocator),
        }
    }
};

pub const Expression = struct {
    pub fn string(self: Expression, allocator: std.mem.Allocator) ![]const u8 {
        _ = self;
        return std.fmt.allocPrint(allocator, "{s}", .{"expression_pending"});
    }
};

// Identifier
pub const Identifier = struct {
    token: tokens.Token,
    value: []const u8,
};

// Program
pub const Program = struct {
    statements: []Statement,

    pub fn string(self: Program, allocator: std.mem.Allocator) ![]const u8 {
        var out = std.ArrayList(u8).init(allocator);
        for (self.statements) |stmt| {
            const str = try std.fmt.allocPrint(allocator, "{!s}\n", .{stmt.string(allocator)});
            try out.appendSlice(str);
        }
        return try out.toOwnedSlice();
    }
};
