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
    const min: i128 = if (false) 7 else 200_000_000_000_000;
    const max: i128 = if (false) 27 else 400_000_000_000_000;

    var hailstones = std.ArrayList(struct { x: i64, y: i64, z: i64, vx: i64, vy: i64, vz: i64 }).init(a);
    defer hailstones.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var num_it = std.mem.tokenizeAny(u8, line, ", @");
        try hailstones.append(.{
            .x = try std.fmt.parseInt(i64, num_it.next().?, 10),
            .y = try std.fmt.parseInt(i64, num_it.next().?, 10),
            .z = try std.fmt.parseInt(i64, num_it.next().?, 10),
            .vx = try std.fmt.parseInt(i64, num_it.next().?, 10),
            .vy = try std.fmt.parseInt(i64, num_it.next().?, 10),
            .vz = try std.fmt.parseInt(i64, num_it.next().?, 10),
        });
    }

    var count: u64 = 0;
    for (1.., hailstones.items) |i, lhs| {
        for (hailstones.items[i..]) |rhs| {
            const lhs_num_temp = lhs.y * rhs.vx - rhs.y * rhs.vx - lhs.x * rhs.vy + rhs.x * rhs.vy;
            const lhs_den_temp = lhs.vx * rhs.vy - lhs.vy * rhs.vx;
            const lhs_num: i128 = if (lhs_den_temp >= 0) lhs_num_temp else -lhs_num_temp;
            const lhs_den: i128 = if (lhs_den_temp >= 0) lhs_den_temp else -lhs_den_temp;

            const rhs_num_temp = rhs.y * lhs.vx - lhs.y * lhs.vx - rhs.x * lhs.vy + lhs.x * lhs.vy;
            const rhs_den_temp = rhs.vx * lhs.vy - rhs.vy * lhs.vx;
            const rhs_num = if (rhs_den_temp >= 0) rhs_num_temp else -rhs_num_temp;
            const rhs_den = if (rhs_den_temp >= 0) rhs_den_temp else -rhs_den_temp;

            if (lhs_num >= 0 and lhs_den != 0 and rhs_num >= 0 and rhs_den != 0) {
                const x = lhs.x * lhs_den + lhs.vx * lhs_num;
                const y = lhs.y * lhs_den + lhs.vy * lhs_num;
                count += @intFromBool(min * lhs_den <= x and x <= max * lhs_den and min * lhs_den <= y and y <= max * lhs_den);
            }
        }
    }
    std.debug.print("{}\n", .{count});
}
