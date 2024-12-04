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

    var similarity: u64 = 0;
    var li: usize = 0;
    var ri: usize = 0;
    while (li < l.items.len) : (li += 1) {
        while (ri < r.items.len and r.items[ri] < l.items[li]) ri += 1;
        var count: u64 = 0;
        for (r.items[ri..]) |re| {
            if (l.items[li] != re) break;
            count += 1;
        }
        similarity += l.items[li] * count;
    }
    try stdout.print("{d}\n", .{similarity});
}
fn lessThan(_: void, lhs: u32, rhs: u32) bool {
    return lhs < rhs;
}
