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

    var maps = std.StringArrayHashMap(u64).init(a);
    defer {
        for (maps.keys()) |key| a.free(key);
        maps.deinit();
    }

    while (true) {
        for (0..height) |y| {
            for (0..width) |x| {
                if (map[x + stride * y] != 'O') continue;
                var dy = y;
                while (dy > 0) : (dy -= 1) {
                    if (map[x + stride * (dy - 1)] != '.') break;
                }
                map[x + stride * y] = '.';
                map[x + stride * dy] = 'O';
            }
        }

        for (0..width) |x| {
            for (0..height) |y| {
                if (map[x + stride * y] != 'O') continue;
                var dx = x;
                while (dx > 0) : (dx -= 1) {
                    if (map[(dx - 1) + stride * y] != '.') break;
                }
                map[x + stride * y] = '.';
                map[dx + stride * y] = 'O';
            }
        }

        for (0..height) |y| {
            for (0..width) |x| {
                if (map[(width - 1 - x) + stride * (height - 1 - y)] != 'O') continue;
                var dy = y;
                while (dy > 0) : (dy -= 1) {
                    if (map[(width - 1 - x) + stride * (height - 1 - (dy - 1))] != '.') break;
                }
                map[(width - 1 - x) + stride * (height - 1 - y)] = '.';
                map[(width - 1 - x) + stride * (height - 1 - dy)] = 'O';
            }
        }

        var load: u64 = 0;
        for (0..width) |x| {
            for (0..height) |y| {
                if (map[(width - 1 - x) + stride * (height - 1 - y)] != 'O') continue;
                var dx = x;
                while (dx > 0) : (dx -= 1) {
                    if (map[(width - 1 - (dx - 1)) + stride * (height - 1 - y)] != '.') break;
                }
                map[(width - 1 - x) + stride * (height - 1 - y)] = '.';
                map[(width - 1 - dx) + stride * (height - 1 - y)] = 'O';
                load += height - (height - 1 - y);
            }
        }

        try maps.ensureUnusedCapacity(1);
        const key = try a.dupe(u8, map);
        const gop = maps.getOrPutAssumeCapacity(key);
        if (gop.found_existing) {
            a.free(key);
            std.debug.print("{}\n", .{maps.values()[(999_999_999 - gop.index) % (maps.count() - gop.index) + gop.index]});
            break;
        } else gop.value_ptr.* = load;
    }
}
