const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        \\
    else
        @embedFile("input");

    var sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const colon = std.mem.indexOfScalar(u8, line, ':').?;
        const bar = std.mem.indexOfScalar(u8, line, '|').?;

        var wins = std.ArrayList(u64).init(a);
        defer wins.deinit();
        var win_it = std.mem.tokenizeScalar(u8, line[colon + ":".len .. bar], ' ');
        while (win_it.next()) |win| try wins.append(try std.fmt.parseInt(u64, win, 10));

        var score: u64 = 0;
        var it = std.mem.tokenizeScalar(u8, line[bar + "|".len ..], ' ');
        while (it.next()) |str| {
            const num = try std.fmt.parseInt(u64, str, 10);
            if (std.mem.indexOfScalar(u64, wins.items, num)) |_| {
                score = switch (score) {
                    0 => 1,
                    else => score * 2,
                };
            }
        }
        sum += score;
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}
