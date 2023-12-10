const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\.....
        \\.S-7.
        \\.|.|.
        \\.L-J.
        \\.....
        \\
    else if (false)
        \\..F7.
        \\.FJ|.
        \\SJ.L7
        \\|F--J
        \\LJ...
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    var queue = std.AutoArrayHashMap(struct { x: u16, y: u16 }, u32).init(a);
    defer queue.deinit();

    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    try queue.putNoClobber(.{ .x = @intCast(start % stride), .y = @intCast(start / stride) }, 0);

    var max_dist: u32 = 0;
    var queue_index: usize = 0;
    while (queue_index < queue.count()) : (queue_index += 1) {
        const prev = queue.keys()[queue_index];
        const dist = queue.values()[queue_index];
        for (adjacent(input[prev.x + stride * prev.y])) |off| {
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
            const gop = try queue.getOrPut(.{ .x = next_clipped_x, .y = next_clipped_y });
            if (!gop.found_existing) gop.value_ptr.* = dist + 1;
            max_dist = @max(dist, max_dist);
        }
    }
    std.debug.print("{}\n", .{max_dist});
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
