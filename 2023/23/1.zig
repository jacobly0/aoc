const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\#.#####################
        \\#.......#########...###
        \\#######.#########.#.###
        \\###.....#.>.>.###.#.###
        \\###v#####.#v#.###.#.###
        \\###.>...#.#.#.....#...#
        \\###v###.#.#.#########.#
        \\###...#.#.#.......#...#
        \\#####.#.#.#######.#.###
        \\#.....#.#.#.......#...#
        \\#.#####.#.#.#########v#
        \\#.#...#...#...###...>.#
        \\#.#.#v#######v###.###v#
        \\#...#.>.#...>.>.#.###.#
        \\#####v#.#.###v#.#.###.#
        \\#.....#...#...#.#.#...#
        \\#.#########.###.#.#.###
        \\#...###...#...#...#.###
        \\###.###.#.###v#####v###
        \\#...#...#.#.>.>.#.>.###
        \\#.###.###.#.###.#.#v###
        \\#.....###...###...#...#
        \\#####################.#
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    const start = std.mem.indexOfScalar(u8, input, '.').?;
    const start_x: u8 = @intCast(start % stride);
    const start_y: u8 = @intCast(start / stride);

    const Position = struct { x: u8, y: u8 };
    const Path = std.AutoArrayHashMap(Position, void);
    var paths = std.ArrayList(Path).init(a);
    defer {
        for (paths.items) |*path| path.deinit();
        paths.deinit();
    }

    try paths.append(Path.init(a));
    try paths.items[0].putNoClobber(.{ .x = start_x, .y = start_y }, {});

    var path_index: usize = 0;
    while (path_index < paths.items.len) {
        try paths.ensureUnusedCapacity(4);
        const path = &paths.items[path_index];
        const prev = path.keys()[path.count() - 1];
        const c = input[prev.x + stride * prev.y];

        var first = true;
        var next: Position = undefined;
        if (prev.x < width - 1 and (c == '.' or c == '>') and input[(prev.x + 1) + stride * prev.y] != '#' and !path.contains(.{ .x = prev.x + 1, .y = prev.y })) {
            if (first) {
                next = .{ .x = prev.x + 1, .y = prev.y };
                first = false;
            } else {
                paths.appendAssumeCapacity(try path.clone());
                try paths.items[paths.items.len - 1].putNoClobber(.{ .x = prev.x + 1, .y = prev.y }, {});
            }
        }
        if (prev.y < height - 1 and (c == '.' or c == 'v') and input[prev.x + stride * (prev.y + 1)] != '#' and !path.contains(.{ .x = prev.x, .y = prev.y + 1 })) {
            if (first) {
                next = .{ .x = prev.x, .y = prev.y + 1 };
                first = false;
            } else {
                paths.appendAssumeCapacity(try path.clone());
                try paths.items[paths.items.len - 1].putNoClobber(.{ .x = prev.x, .y = prev.y + 1 }, {});
            }
        }
        if (prev.x > 0 and (c == '.' or c == '<') and input[(prev.x - 1) + stride * prev.y] != '#' and !path.contains(.{ .x = prev.x - 1, .y = prev.y })) {
            if (first) {
                next = .{ .x = prev.x - 1, .y = prev.y };
                first = false;
            } else {
                paths.appendAssumeCapacity(try path.clone());
                try paths.items[paths.items.len - 1].putNoClobber(.{ .x = prev.x - 1, .y = prev.y }, {});
            }
        }
        if (prev.y > 0 and (c == '.' or c == '^') and input[prev.x + stride * (prev.y - 1)] != '#' and !path.contains(.{ .x = prev.x, .y = prev.y - 1 })) {
            if (first) {
                next = .{ .x = prev.x, .y = prev.y - 1 };
                first = false;
            } else {
                paths.appendAssumeCapacity(try path.clone());
                try paths.items[paths.items.len - 1].putNoClobber(.{ .x = prev.x, .y = prev.y - 1 }, {});
            }
        }
        if (first) {
            path_index += 1;
        } else {
            try path.putNoClobber(next, {});
        }
    }

    const finish = std.mem.lastIndexOfScalar(u8, input, '.').?;
    const finish_x: u8 = @intCast(finish % stride);
    const finish_y: u8 = @intCast(finish / stride);
    var max: usize = std.math.minInt(usize);
    for (paths.items) |*path| {
        const last = path.keys()[path.count() - 1];
        if (last.x == finish_x and last.y == finish_y) {
            max = @max(path.count() - 1, max);
        }
    }
    std.debug.print("{}\n", .{max});
}
