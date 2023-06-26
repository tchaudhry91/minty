const std = @import("std");
const tokens = @import("./tokens.zig");
const Types = tokens.TokenType;

pub const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    read_position: usize = 0,
    ch: u8 = undefined,

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn peekChar(self: *Lexer) u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }

    pub fn nextToken(self: *Lexer) tokens.Token {
        self.skipWhitespace();
        var token_type: Types = switch (self.ch) {
            '-' => Types.MINUS,
            '/' => Types.SLASH,
            '<' => Types.LT,
            '>' => Types.GT,
            '*' => Types.ASTERISK,
            ';' => Types.SEMICOLON,
            '(' => Types.LPAREN,
            ')' => Types.RPAREN,
            ',' => Types.COMMA,
            '+' => Types.PLUS,
            '{' => Types.LBRACE,
            '}' => Types.RBRACE,
            '=' => {
                if (self.peekChar() == '=') {
                    // Double read because we return the token here
                    self.readChar();
                    self.readChar();
                    return tokens.Token.New(Types.EQ, "==");
                } else {
                    self.readChar();
                    return tokens.Token.New(Types.ASSIGN, "=");
                }
            },
            '!' => {
                if (self.peekChar() == '=') {
                    // Double read because we return the token here
                    self.readChar();
                    self.readChar();
                    return tokens.Token.New(Types.NOT_EQ, "!=");
                } else {
                    self.readChar();
                    return tokens.Token.New(Types.BANG, "!");
                }
            },
            0 => Types.EOF,
            else => {
                if (self.isAllowedLetter()) {
                    const literal = self.readIdentifier();
                    return tokens.Token.New(tokens.lookupIdentifierType(literal), literal);
                }
                if (self.isNumber()) {
                    const literal = self.readNumber();
                    return tokens.Token.New(Types.INT, literal);
                } else {
                    defer self.readChar();
                    return tokens.Token.New(Types.ILLEGAL, &[1]u8{self.ch});
                }
            },
        };
        // Reach here on single char tokens
        defer self.readChar();
        return tokens.Token.New(token_type, &[1]u8{self.ch});
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (self.isAllowedLetter() and self.ch != 0) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn isAllowedLetter(self: *Lexer) bool {
        return ('a' <= self.ch and self.ch <= 'z') or
            ('A' <= self.ch and self.ch <= 'Z') or
            self.ch == '_';
    }

    fn isNumber(self: *Lexer) bool {
        return '0' <= self.ch and self.ch <= '9';
    }

    fn readNumber(self: *Lexer) []const u8 {
        const position = self.position;
        while (self.isNumber()) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    pub fn init(input: []const u8) Lexer {
        var lex: Lexer = Lexer{
            .input = input,
        };
        lex.readChar();
        return lex;
    }
};

// Tests

test "token_parse" {
    const input: []const u8 = "=+()   \n {==},;%";
    const expected_tokens = [_]Types{
        Types.ASSIGN,
        Types.PLUS,
        Types.LPAREN,
        Types.RPAREN,
        Types.LBRACE,
        Types.EQ,
        Types.RBRACE,
        Types.COMMA,
        Types.SEMICOLON,
        Types.ILLEGAL,
        Types.EOF,
    };
    const literals = [_][]const u8{
        "=",
        "+",
        "(",
        ")",
        "{",
        "==",
        "}",
        ",",
        ";",
        "%",
        &[1]u8{0},
    };
    var lex = Lexer.init(input);

    var tok: tokens.Token = undefined;
    for (expected_tokens, 0..) |expected_token, i| {
        tok = lex.nextToken();
        try std.testing.expectEqual(expected_token, tok.type);
        try std.testing.expectEqualSlices(u8, literals[i], tok.literal);
    }
}

test "src_parse" {
    const input: []const u8 =
        \\ 5;
        \\ let five = 5!
        \\ let ten = 10 < 5;
        \\ let add = fn(x, y) {
        \\     x + y;
        \\ };
        \\ let result = add(five, ten);
        \\ x < y;
        \\ !-/*5;
        \\ if(x < y) {
        \\    return true;
        \\ } else {
        \\    return false;
        \\ }
        \\ 10 == 10;
        \\ 1 != 9;
    ;

    const expected_tokens = [_]Types{
        Types.INT,
        Types.SEMICOLON,
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.INT,
        Types.BANG,
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.INT,
        Types.LT,
        Types.INT,
        Types.SEMICOLON,
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.FUNCTION,
        Types.LPAREN,
        Types.IDENT,
        Types.COMMA,
        Types.IDENT,
        Types.RPAREN,
        Types.LBRACE,
        Types.IDENT,
        Types.PLUS,
        Types.IDENT,
        Types.SEMICOLON,
        Types.RBRACE,
        Types.SEMICOLON,
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.IDENT,
        Types.LPAREN,
        Types.IDENT,
        Types.COMMA,
        Types.IDENT,
        Types.RPAREN,
        Types.SEMICOLON,
        Types.IDENT,
        Types.LT,
        Types.IDENT,
        Types.SEMICOLON,
        Types.BANG,
        Types.MINUS,
        Types.SLASH,
        Types.ASTERISK,
        Types.INT,
        Types.SEMICOLON,
        Types.IF,
        Types.LPAREN,
        Types.IDENT,
        Types.LT,
        Types.IDENT,
        Types.RPAREN,
        Types.LBRACE,
        Types.RETURN,
        Types.TRUE,
        Types.SEMICOLON,
        Types.RBRACE,
        Types.ELSE,
        Types.LBRACE,
        Types.RETURN,
        Types.FALSE,
        Types.SEMICOLON,
        Types.RBRACE,
        Types.INT,
        Types.EQ,
        Types.INT,
        Types.SEMICOLON,
        Types.INT,
        Types.NOT_EQ,
        Types.INT,
        Types.SEMICOLON,
        Types.EOF,
    };
    const literals = [_][]const u8{
        "5",
        ";",
        "let",
        "five",
        "=",
        "5",
        "!",
        "let",
        "ten",
        "=",
        "10",
        "<",
        "5",
        ";",
        "let",
        "add",
        "=",
        "fn",
        "(",
        "x",
        ",",
        "y",
        ")",
        "{",
        "x",
        "+",
        "y",
        ";",
        "}",
        ";",
        "let",
        "result",
        "=",
        "add",
        "(",
        "five",
        ",",
        "ten",
        ")",
        ";",
        "x",
        "<",
        "y",
        ";",
        "!",
        "-",
        "/",
        "*",
        "5",
        ";",
        "if",
        "(",
        "x",
        "<",
        "y",
        ")",
        "{",
        "return",
        "true",
        ";",
        "}",
        "else",
        "{",
        "return",
        "false",
        ";",
        "}",
        "10",
        "==",
        "10",
        ";",
        "1",
        "!=",
        "9",
        ";",
        &[_]u8{0},
    };
    var lex = Lexer.init(input);

    var tok: tokens.Token = undefined;
    for (expected_tokens, 0..) |expected_token, i| {
        tok = lex.nextToken();
        try std.testing.expectEqual(expected_token, tok.type);
        try std.testing.expectEqualSlices(u8, literals[i], tok.literal);
    }
}
