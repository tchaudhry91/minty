const std = @import("std");
const ast = @import("./ast.zig");
const lex = @import("./lexer.zig");
const tokens = @import("./tokens.zig");

const prefixParseFn: type = fn () ?ast.Expression;
const infixParseFn: type = fn (ast.Expression) ?ast.Expression;

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
        switch (self.current_token.type) {
            tokens.TokenType.LET => return self.parseLetStatement(),
            tokens.TokenType.RETURN => return self.parseReturnStatement(),
            else => return self.parseExpressionStatement(),
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
        var stmt = ast.Statement{ .LET = .{
            .token = self.current_token,
        } };

        if (!self.expectPeek(tokens.TokenType.IDENT)) {
            return null;
        }

        var ident = ast.Identifier{
            .token = self.current_token,
            .value = self.current_token.literal,
        };

        stmt.LET.name = ident;

        if (!self.expectPeek(tokens.TokenType.ASSIGN)) {
            return null;
        }

        // var expr: ast.Expression = undefined;

        while (self.current_token.type != tokens.TokenType.SEMICOLON) {
            self.nextToken();
        }

        // To-Do Expression parsing

        return stmt;
    }

    pub fn parseReturnStatement(self: *Parser) ?ast.Statement {
        var stmt = ast.Statement{ .RETURN = .{
            .token = self.current_token,
        } };

        self.nextToken();

        while (self.current_token.type != tokens.TokenType.SEMICOLON) {
            self.nextToken();
        }

        // To-Do Expression parsing

        return stmt;
    }

    pub fn parseExpressionStatement(self: *Parser) ?ast.Statement {
        var stmt = ast.Statement{ .EXPRESSION = .{ .token = self.current_token } };
        stmt.EXPRESSION.expression = self.parseExpression(ast.ExpressionOps.LOWEST).?;
        if (self.expectPeek(tokens.TokenType.SEMICOLON)) {
            self.nextToken();
        }
        return stmt;
    }

    pub fn parseIdentifier(self: *Parser) ?ast.Expression {
        return ast.Expression{ .IDENTIFIER = .{
            .token = self.current_token,
            .value = self.current_token.literal,
        } };
    }

    pub fn parseIntegerLiteral(self: *Parser) ?ast.Expression {

        // To-Do Propagate Errors properly
        const val = std.fmt.parseInt(u64, self.current_token.literal, 10) catch null;

        return ast.Expression{ .INTEGERLITERAL = .{
            .token = self.current_token,
            .value = val,
        } };
    }

    pub fn parsePrefixExpression(self: *Parser) ?ast.Expression {
        var prefix = ast.Expression{ .PREFIX = .{
            .token = self.current_token,
            .operator = ast.prefixOperatorsMap.get(self.current_token.literal).?,
            .right = undefined,
        } };
        self.nextToken();

        var right = self.parseExpression(ast.ExpressionOps.LOWEST);
        prefix.PREFIX.right = right;

        return prefix;
    }

    pub fn parseExpression(self: *Parser, precendence: ast.ExpressionOps) ?ast.Expression {
        _ = precendence;
        switch (self.current_token.type) {
            tokens.TokenType.IDENT => return self.parseIdentifier(),
            tokens.TokenType.INT => return self.parseIntegerLiteral(),
            tokens.TokenType.BANG => return self.parsePrefixExpression(),
            tokens.TokenType.MINUS => return self.parsePrefixExpression(),
            else => return null,
        }
    }
};

test "parse_identifier" {
    const input = "y;";
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var l = lex.Lexer.init(input);
    var p = Parser.New(&l, allocator);
    var program = try p.parseProgram();
    std.debug.print("Full Program:\n{!s}\n", .{program.string(allocator)});
}

test "parse_integer" {
    const input = "5;";
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var l = lex.Lexer.init(input);
    var p = Parser.New(&l, allocator);
    var program = try p.parseProgram();
    std.debug.print("Full Program:\n{!s}\n", .{program.string(allocator)});
}

test "parser_let_return" {
    const input = "y; 5;";
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var l = lex.Lexer.init(input);
    var p = Parser.New(&l, allocator);
    var program = try p.parseProgram();
    _ = program;
    // std.debug.print("Let Statement: {!s}\n", .{program.statements[0].string(allocator)});
    // std.debug.print("Return Statement: {!s}\n", .{program.statements[1].string(allocator)});
    // std.debug.print("Full Program:\n{!s}\n", .{program.string(allocator)});
}
