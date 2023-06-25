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
};

pub const Token = struct {
    type: TokenType,
    literal: ?[]const u8,

    pub fn New(token_type: TokenType, literal: []const u8) Token {
        return Token{
            .type = token_type,
            .literal = literal,
        };
    }
};

pub fn lookupIdentifierType(literal: []const u8) TokenType {
    // Since there is no switch on strings, we have to do this manually.
    // to-do: Look for a better method later.
    if (std.mem.eql(u8, literal, "fn")) {
        return TokenType.FUNCTION;
    } else if (std.mem.eql(u8, literal, "let")) {
        return TokenType.LET;
    } else {
        return TokenType.IDENT;
    }
}
