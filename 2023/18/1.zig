const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\R 6 (#70c710)
        \\D 5 (#0dc571)
        \\L 2 (#5713f0)
        \\D 2 (#d2c081)
        \\R 2 (#59c680)
        \\D 2 (#411b91)
        \\L 5 (#8ceee2)
        \\U 2 (#caa173)
        \\L 1 (#1b58a2)
        \\U 2 (#caa171)
        \\R 2 (#7807d2)
        \\U 3 (#a77fa3)
        \\L 2 (#015232)
        \\U 2 (#7a21e3)
        \\
    else
        @embedFile("input");

    var min_x: i32 = 0;
    var min_y: i32 = 0;
    var max_x: i32 = 0;
    var max_y: i32 = 0;

    var x: i32 = 0;
    var y: i32 = 0;

    var map = std.AutoHashMap(struct { x: i32, y: i32 }, void).init(a);
    defer map.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var field_it = std.mem.tokenizeScalar(u8, line, ' ');
        const dir = field_it.next().?[0];
        for (0..try std.fmt.parseInt(usize, field_it.next().?, 10)) |_| {
            try map.putNoClobber(.{ .x = x, .y = y }, {});
            switch (dir) {
                'R' => x += 1,
                'D' => y += 1,
                'L' => x -= 1,
                'U' => y -= 1,
                else => unreachable,
            }
            min_x = @min(x, min_x);
            min_y = @min(y, min_y);
            max_x = @max(x, max_x);
            max_y = @max(y, max_y);
        }
    }

    var area: u64 = 0;
    var is_inside = false;
    y = min_y - 1;
    while (y <= max_y + 1) : (y += 1) {
        x = min_x - 1;
        while (x <= max_x + 1) : (x += 1) {
            const is_edge = map.contains(.{ .x = x, .y = y });
            if (is_edge and map.contains(.{ .x = x, .y = y - 1 })) is_inside = !is_inside;
            area += @intFromBool(is_edge or is_inside);
        }
    }
    std.debug.print("{}\n", .{area});
}
