const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    var levels: std.ArrayListUnmanaged(u32) = .empty;
    defer levels.deinit(a);

    var line_it = std.mem.tokenizeScalar(u8, if (false)
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
        \\
    else
        @embedFile("input"), '\n');
    var safe: u32 = 0;
    while (line_it.next()) |line| {
        var tok_it = std.mem.tokenizeScalar(u8, line, ' ');
        levels.clearRetainingCapacity();
        while (tok_it.next()) |tok| try levels.append(a, try std.fmt.parseInt(u32, tok, 10));
        for (0..levels.items.len) |skip_index| {
            const first_index: usize = if (skip_index == 0) 1 else 0;
            var dir: enum { unknown, increasing, decreasing } = .unknown;
            var prev = levels.items[first_index];
            for (levels.items[0..], 0..) |cur, cur_index| {
                if (cur_index == first_index or cur_index == skip_index) continue;
                if (dir == .unknown) {
                    if (cur < prev) dir = .decreasing;
                    if (cur > prev) dir = .increasing;
                }
                switch (dir) {
                    .unknown => break,
                    .decreasing => if (prev <= cur or prev - cur > 3) break,
                    .increasing => if (prev >= cur or cur - prev > 3) break,
                }
                prev = cur;
            } else {
                safe += 1;
                break;
            }
        }
    }
    try stdout.print("{d}\n", .{safe});
}
