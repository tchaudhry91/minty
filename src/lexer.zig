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
            else => Types.ILLEGAL,
        };
        const token = tokens.Token.New(token_type, self.ch);
        return token;
    }

    pub fn init(input: []const u8) Lexer {
        var lex: Lexer = Lexer{
            .input = input,
        };
        lex.readChar();
        return lex;
    }
};

const std = @import("std");
const expect = std.testing.expect;
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
        try expect(tok.type == expected_token);
        try expect(tok.literal.?[0] == literals[i]);
    }
}
