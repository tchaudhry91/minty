const std = @import("std");
pub const TokenType = enum {
    ILLEGAL,
    EOF,

    // Identifier + Literals
    IDENT,
    INT,

    // Operators
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    GT,
    EQ,
    NOT_EQ,

    // Delims
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    RBRACE,
    LBRACE,

    // Keywords
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,

    pub fn New(token_type: TokenType, literal: []const u8) Token {
        return Token{
            .type = token_type,
            .literal = literal,
        };
    }
};

const keywordMap = std.ComptimeStringMap(TokenType, .{
    .{ "fn", .FUNCTION },
    .{ "let", .LET },
    .{ "true", .TRUE },
    .{ "false", .FALSE },
    .{ "if", .IF },
    .{ "else", .ELSE },
    .{ "return", .RETURN },
});

pub fn lookupIdentifierType(literal: []const u8) TokenType {
    return (keywordMap.get(literal) orelse TokenType.IDENT);
}
