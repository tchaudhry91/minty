const tokens = @import("./tokens.zig");

pub const StatementTypes = enum {
    LET,
    RETURN,
};

pub const Statement = union(StatementTypes) { LET: struct {
    token: tokens.Token,
    name: Identifier = undefined,
    value: Expression = Expression{},

    pub fn tokenLiteral(self: @This()) []const u8 {
        return self.token.literal;
    }
}, RETURN: struct {
    token: tokens.Token,
    value: Expression,

    pub fn tokenLiteral(self: @This()) []const u8 {
        return self.token.literal;
    }
} };

pub const Expression = struct {};

// Identifier
pub const Identifier = struct {
    token: tokens.Token,
    value: []const u8,
};

// Program
pub const Program = struct {
    statements: []Statement,
};
