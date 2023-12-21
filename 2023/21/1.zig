const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\...........
        \\.....###.#.
        \\.###.##..#.
        \\..#.#...#..
        \\....#.#....
        \\.##..S####.
        \\.##..#...#.
        \\.......##..
        \\.##.#.####.
        \\.##..##.##.
        \\...........
        \\
    else
        @embedFile("input");
    const steps = if (false) 6 else 64;

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const start_x: u8 = @intCast(start % stride);
    const start_y: u8 = @intCast(start / stride);

    var queue = std.AutoArrayHashMap(struct { x: u8, y: u8, steps: u8 }, void).init(a);
    defer queue.deinit();
    try queue.put(.{ .x = start_x, .y = start_y, .steps = 0 }, {});

    var queue_index: usize = 0;
    while (true) : (queue_index += 1) {
        const prev = queue.keys()[queue_index];
        if (prev.steps >= steps) break;
        for ([_]struct { x: i2, y: i2 }{
            .{ .x = 1, .y = 0 },
            .{ .x = 0, .y = 1 },
            .{ .x = -1, .y = 0 },
            .{ .x = 0, .y = -1 },
        }) |step| {
            const x = @as(i9, prev.x) + step.x;
            const y = @as(i9, prev.y) + step.y;
            if (x < 0 or x >= width or y < 0 or y >= height) continue;
            const next_x: u8 = @intCast(x);
            const next_y: u8 = @intCast(y);
            if (input[next_x + stride * next_y] == '#') continue;
            try queue.put(.{ .x = next_x, .y = next_y, .steps = prev.steps + 1 }, {});
        }
    }
    std.debug.print("{}\n", .{queue.count() - queue_index});
}
