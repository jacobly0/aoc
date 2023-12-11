const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\...#......
        \\.......#..
        \\#.........
        \\..........
        \\......#...
        \\.#........
        \\.........#
        \\..........
        \\.......#..
        \\#...#.....
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    var galaxies = std.ArrayList(struct { x: u8, y: u8 }).init(a);
    defer galaxies.deinit();
    {
        var expanded_y: usize = 0;
        for (0..height) |y| {
            var expanded_x: usize = 0;
            var any = false;
            for (0..width) |x| {
                if (input[x + stride * y] == '#') {
                    any = true;
                    try galaxies.append(.{ .x = @intCast(expanded_x), .y = @intCast(expanded_y) });
                } else {
                    for (0..height) |yo| {
                        if (input[x + stride * yo] == '#') break;
                    } else expanded_x += 1;
                }
                expanded_x += 1;
            }
            expanded_y += if (any) 1 else 2;
        }
    }

    var sum: u64 = 0;
    for (0.., galaxies.items[0 .. galaxies.items.len - 1]) |i, x| {
        for (galaxies.items[i + 1 ..]) |y| {
            sum += @abs(@as(i32, x.x) - y.x);
            sum += @abs(@as(i32, x.y) - y.y);
        }
    }
    std.debug.print("{}\n", .{sum});
}
