const std = @import("std");
const tokens = @import("./tokens.zig");
const Types = tokens.TokenType;

const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    read_position: usize = 0,
    ch: u8 = 0,

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn nextToken(self: *Lexer) tokens.Token {
        defer self.readChar();
        self.skipWhitespace();
        var token_type: Types = switch (self.ch) {
            '=' => Types.ASSIGN,
            ';' => Types.SEMICOLON,
            '(' => Types.LPAREN,
            ')' => Types.RPAREN,
            ',' => Types.COMMA,
            '+' => Types.PLUS,
            '{' => Types.LBRACE,
            '}' => Types.RBRACE,
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
                    std.debug.print("illegal character: {}\n", .{self.ch});
                    return tokens.Token.New(Types.ILLEGAL, &[_]u8{self.ch});
                }
            },
        };
        const token = tokens.Token.New(token_type, &[_]u8{self.ch});
        return token;
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
    const input: []const u8 = "=+(){},;";
    const expected_tokens = [_]Types{
        Types.ASSIGN,
        Types.PLUS,
        Types.LPAREN,
        Types.RPAREN,
        Types.LBRACE,
        Types.RBRACE,
        Types.COMMA,
        Types.SEMICOLON,
        Types.EOF,
    };
    const literals = [_]u8{
        '=',
        '+',
        '(',
        ')',
        '{',
        '}',
        ',',
        ';',
        0,
    };
    var lex = Lexer.init(input);

    var tok: tokens.Token = undefined;
    for (expected_tokens, 0..) |expected_token, i| {
        tok = lex.nextToken();
        try std.testing.expect(tok.type == expected_token);
        try std.testing.expect(tok.literal.?[0] == literals[i]);
    }
}

test "src_parse" {
    const input: []const u8 =
        \\ let five = 5;
        \\ let ten = 10;
        \\ let add = fn(x, y) {
        \\     x + y;
        \\ };
        \\ let result = add(five, ten);
    ;

    const expected_tokens = [_]Types{
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.INT,
        Types.LET,
        Types.IDENT,
        Types.ASSIGN,
        Types.INT,
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
        Types.EOF,
    };
    const literals = [_][]const u8{
        "let",
        "five",
        "=",
        "5",
        "let",
        "ten",
        "=",
        "10",
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
        "0",
    };
    var lex = Lexer.init(input);

    var tok: tokens.Token = undefined;
    for (expected_tokens, 0..) |expected_token, i| {
        tok = lex.nextToken();
        try std.testing.expectEqual(expected_token, tok.type);
        try std.testing.expectEqualSlices(u8, tok.literal.?, literals[i]);
    }
}
