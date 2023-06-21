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

    pub fn New(token_type: TokenType, ch: u8) Token {
        return Token{
            .type = token_type,
            .literal = &[_]u8{ch},
        };
    }
};
