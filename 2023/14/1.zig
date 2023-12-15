const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\O....#....
        \\O.OO#....#
        \\.....##...
        \\OO.#O....O
        \\.O.....O#.
        \\O.#..O.#.#
        \\..O..#O..O
        \\.......O..
        \\#....###..
        \\#OO..#....
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    var map = try a.dupe(u8, input);
    defer a.free(map);

    var load: u64 = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            if (map[x + stride * y] != 'O') continue;
            var dy = y;
            while (dy > 0) : (dy -= 1) {
                if (map[x + stride * (dy - 1)] != '.') break;
            }
            map[x + stride * y] = '.';
            map[x + stride * dy] = 'O';
            load += height - dy;
        }
    }
    std.debug.print("{}\n", .{load});
}
