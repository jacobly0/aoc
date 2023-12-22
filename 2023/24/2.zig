const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\19, 13, 30 @ -2,  1, -2
        \\18, 19, 22 @ -1, -1, -2
        \\20, 25, 34 @ -2, -2, -4
        \\12, 31, 28 @ -1, -2, -1
        \\20, 19, 15 @  1, -5, -3
        \\
    else
        @embedFile("input");

    const Row = [10]f64;
    var matrix = std.ArrayList(Row).init(a);
    defer matrix.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeAny(u8, line, ", @");
        const x: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        const y: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        const z: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        const vx: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        const vy: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        const vz: f64 = @floatFromInt(try std.fmt.parseInt(i64, num_it.next().?, 10));
        try matrix.appendSlice(&.{
            .{ vy, -vx, 0, y, -x, 0, 1, 0, 0, x * vy - y * vx },
            .{ 0, vz, -vy, 0, z, -y, 0, 1, 0, y * vz - z * vy },
            .{ -vz, 0, vx, -z, 0, x, 0, 0, 1, z * vx - x * vz },
        });
    }

    var cur_y: usize = 0;
    for (0..@typeInfo(Row).Array.len - 1) |cur_x| {
        var max_y = cur_y;
        for (cur_y + 1.., matrix.items[cur_y + 1 ..]) |y, row| {
            if (@abs(row[cur_y]) > @abs(matrix.items[max_y][cur_x])) {
                max_y = y;
            }
        }
        std.mem.swap(Row, &matrix.items[cur_y], &matrix.items[max_y]);
        if (matrix.items[cur_y][cur_x] != 0) {
            {
                const factor = 1 / matrix.items[cur_y][cur_x];
                for (&matrix.items[cur_y]) |*elem| elem.* *= factor;
            }
            {
                for (0.., matrix.items) |y, *row| {
                    if (y == cur_y) continue;
                    const factor = row[cur_x];
                    for (0.., row) |x, *elem| elem.* -= matrix.items[cur_y][x] * factor;
                }
            }
            cur_y += 1;
        }
    }

    var sum: i64 = 0;
    for (matrix.items[0..3]) |row| sum += @intFromFloat(@round(row[@typeInfo(Row).Array.len - 1]));
    std.debug.print("{}\n", .{sum});
}
