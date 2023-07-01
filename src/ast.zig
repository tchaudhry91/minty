const std = @import("std");
const tokens = @import("./tokens.zig");

pub const StatementTypes = enum {
    LET,
    RETURN,
    EXPRESSION,
};

pub const Statement = union(StatementTypes) {
    LET: struct {
        token: tokens.Token,
        name: Identifier = undefined,
        value: Expression = undefined,

        pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{s} {s} = {!s}", .{ self.token.literal, self.name.value, self.value.string(allocator) });
        }
    },
    RETURN: struct {
        token: tokens.Token,
        return_value: Expression = undefined,

        pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{s} {!s}", .{ self.token.literal, self.return_value.string(allocator) });
        }
    },
    EXPRESSION: struct {
        token: tokens.Token,
        expression: Expression = undefined,

        pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
            return std.fmt.allocPrint(allocator, "{!s}", .{self.expression.string(allocator)});
        }
    },
    pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            .LET => |let_stmt| return let_stmt.string(allocator),
            .RETURN => |return_stmt| return return_stmt.string(allocator),
            .EXPRESSION => |expression_stmt| return expression_stmt.string(allocator),
        }
    }
};

pub const ExpressionTypes = enum { IDENTIFIER, INTEGERLITERAL, PREFIX };

pub const Expression = union(ExpressionTypes) {
    IDENTIFIER: Identifier,
    INTEGERLITERAL: IntegerLiteral,
    PREFIX: PrefixExpression,

    pub fn string(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            .IDENTIFIER => |ident| return ident.string(),
            .INTEGERLITERAL => |il| return il.string(allocator),
            .PREFIX => |p| return p.string(allocator),
        }
    }
};

pub const PrefixOperators = enum {
    BANG,
    MINUS,

    pub fn string(self: @This()) []const u8 {
        switch (self) {
            PrefixOperators.BANG => {
                return "!";
            },
            PrefixOperators.MINUS => {
                return "-";
            },
        }
    }
};

pub const prefixOperatorsMap = std.ComptimeStringMap(PrefixOperators, .{
    .{ "!", .BANG },
    .{ "-", .MINUS },
});

pub const PrefixExpression = struct {
    token: tokens.Token,
    operator: PrefixOperators,
    right: *Expression,

    pub fn string(self: PrefixExpression, allocator: std.mem.Allocator) ![]const u8 {
        return std.fmt.allocPrint(allocator, "({s}{!s})", .{ self.operator.string(), self.right.string(allocator) });
    }
};

// IntegerLiteral
pub const IntegerLiteral = struct {
    token: tokens.Token,
    value: ?u64,

    pub fn string(self: IntegerLiteral, allocator: std.mem.Allocator) ![]const u8 {
        return std.fmt.allocPrint(allocator, "{?d}", .{self.value});
    }
};

// Identifier
pub const Identifier = struct {
    token: tokens.Token,
    value: []const u8,
    pub fn string(self: Identifier) []const u8 {
        return self.value;
    }
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

// ExpressionOps are the precedence of the operators
pub const ExpressionOps = enum(u8) {
    LOWEST,
    EQUALS,
    LESSGREATER,
    SUM,
    PRODUCT,
    PREFIX,
    CALL,
};
