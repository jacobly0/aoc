const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\???.### 1,1,3
        \\.??..??...?##. 1,1,3
        \\?#?#?#?#?#?#?#? 1,3,1,6
        \\????.#...#... 4,1,1
        \\????.######..#####. 1,6,5
        \\?###???????? 3,2,1
        \\
    else
        @embedFile("input");

    var sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var space_it = std.mem.tokenizeScalar(u8, line, ' ');

        var unknown_count: u5 = 0;
        const springs = space_it.next().?;
        for (springs) |c| unknown_count += @intFromBool(c == '?');
        const guess = try a.alloc(u8, springs.len + 1);
        defer a.free(guess);
        guess[springs.len] = '.';

        var counts = std.ArrayList(u8).init(a);
        defer counts.deinit();
        var counts_it = std.mem.tokenizeScalar(u8, space_it.next().?, ',');
        while (counts_it.next()) |count| try counts.append(try std.fmt.parseInt(u8, count, 10));

        for (0..@as(u32, 1) << unknown_count) |i| {
            var unknown_i: u5 = 0;
            for (guess[0..springs.len], springs) |*g, s| g.* = switch (s) {
                '.', '#' => |c| c,
                '?' => c: {
                    const c: u8 = if (i & @as(u32, 1) << unknown_i != 0) '#' else '.';
                    unknown_i += 1;
                    break :c c;
                },
                else => unreachable,
            };

            var count_i: usize = 0;
            var count: usize = 0;
            for (guess) |c| switch (c) {
                '.' => if (count > 0) {
                    if (count_i >= counts.items.len) break;
                    if (counts.items[count_i] != count) break;
                    count = 0;
                    count_i += 1;
                },
                '#' => count += 1,
                else => unreachable,
            } else if (count_i == counts.items.len) {
                sum += 1;
            }
        }
    }
    std.debug.print("{}\n", .{sum});
}
