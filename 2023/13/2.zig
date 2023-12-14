const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\#.##..##.
        \\..#.##.#.
        \\##......#
        \\##......#
        \\..#.##.#.
        \\..##..##.
        \\#.#.##.#.
        \\
        \\#...##..#
        \\#....#..#
        \\..##..###
        \\#####.##.
        \\#####.##.
        \\..##..###
        \\#....#..#
        \\
    else
        @embedFile("input");

    var map = std.ArrayList(u8).init(a);
    defer map.deinit();

    var line_it = std.mem.splitScalar(u8, input, '\n');
    var summary: u64 = 0;
    while (true) {
        var width: u64 = undefined;
        var height: u64 = 0;

        map.clearRetainingCapacity();
        while (line_it.next()) |line| {
            if (line.len == 0) break;
            width = line.len;
            height += 1;
            try map.appendSlice(line);
        }
        if (height == 0) break;

        for (1..width) |x| {
            var different = false;
            reflection: for (0..@min(x, width - x)) |xo| {
                for (0..height) |y| {
                    if (map.items[(x - 1 - xo) + width * y] != map.items[(x + xo) + width * y]) {
                        if (different) {
                            break :reflection;
                        } else {
                            different = true;
                        }
                    }
                }
            } else if (different) summary += x * 1;
        }
        for (1..height) |y| {
            var different = false;
            reflection: for (0..@min(y, height - y)) |yo| {
                for (0..width) |x| {
                    if (map.items[x + width * (y - 1 - yo)] != map.items[x + width * (y + yo)]) {
                        if (different) {
                            break :reflection;
                        } else {
                            different = true;
                        }
                    }
                }
            } else if (different) summary += y * 100;
        }
    }
    std.debug.print("{}\n", .{summary});
}
