const std = @import("std");
const ast = @import("./ast.zig");
const lex = @import("./lexer.zig");
const tokens = @import("./tokens.zig");

const Parser = struct {
    lexer: *lex.Lexer,
    current_token: tokens.Token,
    peek_token: tokens.Token,
    allocator: std.mem.Allocator,

    pub fn New(l: *lex.Lexer, allocator: std.mem.Allocator) Parser {
        var p: Parser = Parser{
            .lexer = l,
            .allocator = allocator,
            .current_token = l.nextToken(),
            .peek_token = l.nextToken(),
        };
        return p;
    }

    pub fn nextToken(self: *Parser) void {
        self.current_token = self.peek_token;
        self.peek_token = self.lexer.nextToken();
    }

    pub fn parseProgram(self: *Parser) !ast.Program {
        var stmts: std.ArrayList(ast.Statement) = std.ArrayList(ast.Statement).init(self.allocator);
        while (self.current_token.type != tokens.TokenType.EOF) {
            var stmt = self.parseStatement();
            if (stmt != null) {
                try stmts.append(stmt.?);
            }
            self.nextToken();
        }

        const stmts_slice = try stmts.toOwnedSlice();

        return ast.Program{ .statements = stmts_slice };
    }

    pub fn parseStatement(self: *Parser) ?ast.Statement {
        std.debug.print("token: {any}\n", .{self.current_token.type});
        switch (self.current_token.type) {
            tokens.TokenType.LET => return self.parseLetStatement(),
            else => unreachable,
        }
    }

    pub fn expectPeek(self: *Parser, t: tokens.TokenType) bool {
        if (self.peek_token.type == t) {
            self.nextToken();
            return true;
        } else {
            return false;
        }
    }

    pub fn parseLetStatement(self: *Parser) ?ast.Statement {
        if (!self.expectPeek(tokens.TokenType.IDENT)) {
            return null;
        }

        var ident = ast.Identifier{
            .token = self.current_token,
            .value = self.current_token.literal,
        };

        var stmt = ast.Statement{ .LET = .{
            .token = self.current_token,
            .name = ident,
        } };

        if (!self.expectPeek(tokens.TokenType.ASSIGN)) {
            return null;
        }

        while (self.current_token.type != tokens.TokenType.SEMICOLON) {
            self.nextToken();
        }
        return stmt;
    }
};

test "parser_let" {
    const input = "let x = 5;";
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();
    var l = lex.Lexer.init(input);
    var p = Parser.New(&l, allocator.allocator());
    var program = try p.parseProgram();

    std.debug.print("{any}\n", .{program.statements[0].LET});
}
