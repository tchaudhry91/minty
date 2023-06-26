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

pub fn lookupIdentifierType(literal: []const u8) TokenType {
    // Since there is no switch on strings, we have to do this manually.
    // to-do: Look for a better method later.
    if (std.mem.eql(u8, literal, "fn")) {
        return TokenType.FUNCTION;
    } else if (std.mem.eql(u8, literal, "let")) {
        return TokenType.LET;
    } else if (std.mem.eql(u8, literal, "true")) {
        return TokenType.TRUE;
    } else if (std.mem.eql(u8, literal, "false")) {
        return TokenType.FALSE;
    } else if (std.mem.eql(u8, literal, "if")) {
        return TokenType.IF;
    } else if (std.mem.eql(u8, literal, "else")) {
        return TokenType.ELSE;
    } else if (std.mem.eql(u8, literal, "return")) {
        return TokenType.RETURN;
    } else {
        return TokenType.IDENT;
    }
}
