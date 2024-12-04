const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    var l: std.ArrayListUnmanaged(u32) = .empty;
    defer l.deinit(a);
    var r: std.ArrayListUnmanaged(u32) = .empty;
    defer r.deinit(a);

    var line_it = std.mem.tokenizeScalar(u8, if (false)
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\
    else
        @embedFile("input"), '\n');
    while (line_it.next()) |line| {
        var tok_it = std.mem.tokenizeScalar(u8, line, ' ');
        try l.append(a, try std.fmt.parseInt(u32, tok_it.next().?, 10));
        try r.append(a, try std.fmt.parseInt(u32, tok_it.next().?, 10));
    }

    std.mem.sortUnstable(u32, l.items, {}, lessThan);
    std.mem.sortUnstable(u32, r.items, {}, lessThan);

    var sum: u64 = 0;
    for (l.items, r.items) |li, ri| sum += @abs(@as(i33, li) - ri);
    try stdout.print("{d}\n", .{sum});
}
fn lessThan(_: void, lhs: u32, rhs: u32) bool {
    return lhs < rhs;
}
