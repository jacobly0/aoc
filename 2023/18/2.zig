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

    var map = std.AutoArrayHashMap(struct { x: i32, y: i32 }, void).init(a);
    defer map.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        for (0..try std.fmt.parseInt(u24, line[line.len - 7 ..][0..5], 16)) |_| {
            try map.put(.{ .x = x, .y = y }, {});
            switch (line[line.len - 2]) {
                '0' => x += 1,
                '1' => y += 1,
                '2' => x -= 1,
                '3' => y -= 1,
                else => unreachable,
            }
            min_x = @min(x, min_x);
            min_y = @min(y, min_y);
            max_x = @max(x, max_x);
            max_y = @max(y, max_y);
        }
    }
    map.unmanaged.sortUnstable(struct {
        map: @TypeOf(map),
        pub fn lessThan(ctx: @This(), lhs_index: usize, rhs_index: usize) bool {
            const keys = ctx.map.keys();
            const lhs = keys[lhs_index];
            const rhs = keys[rhs_index];
            var order = std.math.order(lhs.y, rhs.y);
            if (order.compare(.eq)) order = std.math.order(lhs.x, rhs.x);
            std.debug.assert(!order.compare(.eq));
            return order.compare(.lt);
        }
    }{ .map = map });

    var area: u64 = 0;
    var is_inside = false;
    y = min_y - 1;
    for (map.keys()) |next| {
        if (y < next.y) {
            std.debug.assert(!is_inside);
        } else {
            std.debug.assert(y == next.y);
        }
        area += @intCast(if (is_inside) next.x - x else 1);
        x = next.x;
        y = next.y;
        if (map.contains(.{ .x = x, .y = y - 1 })) is_inside = !is_inside;
    }
    std.debug.print("{}\n", .{area});
}
