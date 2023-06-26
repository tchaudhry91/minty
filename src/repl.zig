const std = @import("std");
const lexer = @import("./lexer.zig");
const tokens = @import("./tokens.zig");

const PROMPT = "mynt>> ";

pub fn Start(allocator: std.mem.Allocator) !void {
    var stdin = std.io.getStdIn();
    var stdout = std.io.getStdOut();

    while (true) {
        try stdout.writeAll(PROMPT);
        const line = try stdin.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize));
        defer allocator.free(line.?);

        var l = lexer.Lexer.init(line.?);
        var tok = l.nextToken();
        while (tok.type != tokens.TokenType.EOF) {
            const token_info = try std.fmt.allocPrint(allocator, "type: {any}, literal: {s}\n", .{ tok.type, tok.literal });
            defer allocator.free(token_info);
            try stdout.writeAll(token_info);
            tok = l.nextToken();
        }
    }
}
