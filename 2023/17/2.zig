const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\2413432311323
        \\3215453535623
        \\3255245654254
        \\3446585845452
        \\4546657867536
        \\1438598798454
        \\4457876987766
        \\3637877979653
        \\4654967986887
        \\4564679986453
        \\1224686865563
        \\2546548887735
        \\4322674655533
        \\
    else if (false)
        \\111111111111
        \\999999999991
        \\999999999991
        \\999999999991
        \\999999999991
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    const Dir = enum { right, down, left, up };
    const Map = std.AutoArrayHashMap(struct { x: u8, y: u8, dir: Dir, limit: u4 }, u32);
    var visited = Map.init(a);
    defer visited.deinit();

    var queue = std.PriorityQueue(u32, *const Map, struct {
        fn lessThan(map: *const Map, lhs: u32, rhs: u32) std.math.Order {
            const values = map.values();
            return std.math.order(values[lhs], values[rhs]);
        }
    }.lessThan).init(a, &visited);
    defer queue.deinit();

    try visited.put(.{
        .x = 0,
        .y = 0,
        .dir = .right,
        .limit = 10,
    }, 0);
    try visited.put(.{
        .x = 0,
        .y = 0,
        .dir = .down,
        .limit = 10,
    }, 0);
    for (0..visited.count()) |index| try queue.add(@intCast(index));

    while (queue.removeOrNull()) |prev_index| {
        const prev = visited.keys()[prev_index];
        const prev_loss = visited.values()[prev_index];
        if (prev.limit <= 6 and prev.x == width - 1 and prev.y == height - 1) {
            std.debug.print("{}\n", .{prev_loss});
            break;
        }
        for (std.enums.values(Dir)) |dir| {
            if (prev.limit > 6 and dir != prev.dir) continue;
            switch (prev.dir) {
                .right => if (dir == .left) continue,
                .down => if (dir == .up) continue,
                .left => if (dir == .right) continue,
                .up => if (dir == .down) continue,
            }
            const next: struct { x: i9, y: i9 } = switch (dir) {
                .right => .{ .x = @as(i9, prev.x) + 1, .y = @as(i9, prev.y) + 0 },
                .down => .{ .x = @as(i9, prev.x) + 0, .y = @as(i9, prev.y) + 1 },
                .left => .{ .x = @as(i9, prev.x) - 1, .y = @as(i9, prev.y) + 0 },
                .up => .{ .x = @as(i9, prev.x) + 0, .y = @as(i9, prev.y) - 1 },
            };
            if (next.x < 0 or next.x >= width or next.y < 0 or next.y >= height) continue;
            const gop = try visited.getOrPut(.{
                .x = @intCast(next.x),
                .y = @intCast(next.y),
                .dir = dir,
                .limit = if (dir == prev.dir) std.math.sub(u4, prev.limit, 1) catch continue else 9,
            });
            if (!gop.found_existing) {
                gop.value_ptr.* = prev_loss + input[gop.key_ptr.x + stride * gop.key_ptr.y] - '0';
                try queue.add(@intCast(gop.index));
            }
        }
    }
}
