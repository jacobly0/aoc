const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\.|...\....
        \\|.-.\.....
        \\.....|-...
        \\........|.
        \\..........
        \\.........\
        \\..../.\\..
        \\.-.-/..|..
        \\.|....-|.\
        \\..//.|....
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    var energized = std.AutoHashMap(struct { x: u8, y: u8 }, void).init(a);
    defer energized.deinit();

    var queue = std.AutoArrayHashMap(struct { x: u8, y: u8, dir: enum { right, down, left, up } }, void).init(a);
    defer queue.deinit();
    try queue.put(.{ .x = 0, .y = 0, .dir = .right }, {});

    var queue_index: usize = 0;
    while (queue_index < queue.count()) : (queue_index += 1) {
        const prev = queue.keys()[queue_index];
        try energized.put(.{ .x = prev.x, .y = prev.y }, {});
        switch (input[prev.x + stride * prev.y]) {
            '.' => switch (prev.dir) {
                .right => if (prev.x < width - 1) {
                    try queue.put(.{ .x = prev.x + 1, .y = prev.y, .dir = .right }, {});
                },
                .down => if (prev.y < height - 1) {
                    try queue.put(.{ .x = prev.x, .y = prev.y + 1, .dir = .down }, {});
                },
                .left => if (prev.x > 0) {
                    try queue.put(.{ .x = prev.x - 1, .y = prev.y, .dir = .left }, {});
                },
                .up => if (prev.y > 0) {
                    try queue.put(.{ .x = prev.x, .y = prev.y - 1, .dir = .up }, {});
                },
            },
            '-' => switch (prev.dir) {
                .right => if (prev.x < width - 1) {
                    try queue.put(.{ .x = prev.x + 1, .y = prev.y, .dir = .right }, {});
                },
                .down, .up => {
                    if (prev.x < width - 1) {
                        try queue.put(.{ .x = prev.x + 1, .y = prev.y, .dir = .right }, {});
                    }
                    if (prev.x > 0) {
                        try queue.put(.{ .x = prev.x - 1, .y = prev.y, .dir = .left }, {});
                    }
                },
                .left => if (prev.x > 0) {
                    try queue.put(.{ .x = prev.x - 1, .y = prev.y, .dir = .left }, {});
                },
            },
            '|' => switch (prev.dir) {
                .right, .left => {
                    if (prev.y < height - 1) {
                        try queue.put(.{ .x = prev.x, .y = prev.y + 1, .dir = .down }, {});
                    }
                    if (prev.y > 0) {
                        try queue.put(.{ .x = prev.x, .y = prev.y - 1, .dir = .up }, {});
                    }
                },
                .down => if (prev.y < height - 1) {
                    try queue.put(.{ .x = prev.x, .y = prev.y + 1, .dir = .down }, {});
                },
                .up => if (prev.y > 0) {
                    try queue.put(.{ .x = prev.x, .y = prev.y - 1, .dir = .up }, {});
                },
            },
            '/' => switch (prev.dir) {
                .right => if (prev.y > 0) {
                    try queue.put(.{ .x = prev.x, .y = prev.y - 1, .dir = .up }, {});
                },
                .down => if (prev.x > 0) {
                    try queue.put(.{ .x = prev.x - 1, .y = prev.y, .dir = .left }, {});
                },
                .left => if (prev.y < height - 1) {
                    try queue.put(.{ .x = prev.x, .y = prev.y + 1, .dir = .down }, {});
                },
                .up => if (prev.x < width - 1) {
                    try queue.put(.{ .x = prev.x + 1, .y = prev.y, .dir = .right }, {});
                },
            },
            '\\' => switch (prev.dir) {
                .right => if (prev.y < height - 1) {
                    try queue.put(.{ .x = prev.x, .y = prev.y + 1, .dir = .down }, {});
                },
                .down => if (prev.x < width - 1) {
                    try queue.put(.{ .x = prev.x + 1, .y = prev.y, .dir = .right }, {});
                },
                .left => if (prev.y > 0) {
                    try queue.put(.{ .x = prev.x, .y = prev.y - 1, .dir = .up }, {});
                },
                .up => if (prev.x > 0) {
                    try queue.put(.{ .x = prev.x - 1, .y = prev.y, .dir = .left }, {});
                },
            },
            else => unreachable,
        }
    }
    std.debug.print("{}\n", .{energized.count()});
}
