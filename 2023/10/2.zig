const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\...........
        \\.S-------7.
        \\.|F-----7|.
        \\.||.....||.
        \\.||.....||.
        \\.|L-7.F-J|.
        \\.|..|.|..|.
        \\.L--J.L--J.
        \\...........
        \\
    else if (false)
        \\.F----7F7F7F7F-7....
        \\.|F--7||||||||FJ....
        \\.||.FJ||||||||L7....
        \\FJL7L7LJLJ||LJ.L-7..
        \\L--J.L7...LJS7F-7L7.
        \\....F-J..F7FJ|L7L7L7
        \\....L7.F7||L7|.L7L7|
        \\.....|FJLJ|FJ|F7|.LJ
        \\....FJL-7.||.||||...
        \\....L---J.LJ.LJLJ...
        \\
    else if (false)
        \\FF7FSF7F7F7F7F7F---7
        \\L|LJ||||||||||||F--J
        \\FL-7LJLJ||||||LJL-77
        \\F--JF--7||LJLJ7F7FJ-
        \\L---JF-JLJ.||-FJLJJ7
        \\|F|F-JF---7F7-L7L|7|
        \\|FFJF7L7F-JF7|JL---7
        \\7-L-JL7||F7|L7F-7F7|
        \\L.L7LFJ|||||FJL7||LJ
        \\L7JLJL-JLJLJL--JLJ.L
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    var queue = std.AutoArrayHashMap(struct { x: u16, y: u16 }, void).init(a);
    defer queue.deinit();

    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    var start_kind: u8 = undefined;
    try queue.putNoClobber(.{ .x = @intCast(start % stride), .y = @intCast(start / stride) }, {});

    var queue_index: usize = 0;
    while (queue_index < queue.count()) : (queue_index += 1) {
        const prev = queue.keys()[queue_index];
        var bits: u4 = 0;
        for (0.., adjacent(input[prev.x + stride * prev.y])) |bit, off| {
            const next_x = prev.x + off.x;
            const next_y = prev.y + off.y;
            if (next_x < 0 or next_x >= width) continue;
            if (next_y < 0 or next_y >= height) continue;
            const next_clipped_x: u16 = @intCast(next_x);
            const next_clipped_y: u16 = @intCast(next_y);
            if (input[next_clipped_x + stride * next_clipped_y] == '.') continue;
            for (adjacent(input[next_clipped_x + stride * next_clipped_y])) |back_off| {
                if (next_clipped_x + back_off.x == prev.x and
                    next_clipped_y + back_off.y == prev.y) break;
            } else continue;
            try queue.put(.{ .x = next_clipped_x, .y = next_clipped_y }, {});
            bits |= @as(u4, 1) << @intCast(bit);
        }
        if (queue_index == 0) start_kind = switch (bits) {
            0b0011 => 'J',
            0b0101 => 'L',
            0b0110 => '-',
            0b1001 => '|',
            0b1010 => '7',
            0b1100 => 'F',
            else => unreachable,
        };
    }

    var count: u32 = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            if (queue.contains(.{ .x = @intCast(x), .y = @intCast(y) })) continue;
            var inside = false;
            for (x..width) |xo| switch (switch (input[xo + stride * y]) {
                'S' => start_kind,
                else => |c| c,
            }) {
                '|', 'L', 'J' => if (queue.contains(.{ .x = @intCast(xo), .y = @intCast(y) })) {
                    inside = !inside;
                },
                '7', 'F', '-', '.' => {},
                else => unreachable,
            };
            count += @intFromBool(inside);
        }
    }
    std.debug.print("{}\n", .{count});
}

fn adjacent(c: u8) []const struct { x: i32, y: i32 } {
    return switch (c) {
        '|' => &.{
            .{ .x = 0, .y = -1 },
            .{ .x = 0, .y = 1 },
        },
        '-' => &.{
            .{ .x = -1, .y = 0 },
            .{ .x = 1, .y = 0 },
        },
        'L' => &.{
            .{ .x = 0, .y = -1 },
            .{ .x = 1, .y = 0 },
        },
        'J' => &.{
            .{ .x = 0, .y = -1 },
            .{ .x = -1, .y = 0 },
        },
        '7' => &.{
            .{ .x = -1, .y = 0 },
            .{ .x = 0, .y = 1 },
        },
        'F' => &.{
            .{ .x = 1, .y = 0 },
            .{ .x = 0, .y = 1 },
        },
        'S' => &.{
            .{ .x = 0, .y = -1 },
            .{ .x = -1, .y = 0 },
            .{ .x = 1, .y = 0 },
            .{ .x = 0, .y = 1 },
        },
        else => unreachable,
    };
}
