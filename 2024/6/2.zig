const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    @setEvalBranchQuota(100_000);
    const input = if (false)
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
        \\
    else
        @embedFile("input");
    const Dir = enum { up, right, down, left };
    var visited: std.AutoHashMapUnmanaged(struct { Dir, u32, u32 }, void) = .{};
    defer visited.deinit(a);
    const width = comptime std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);
    var positions: u64 = 0;
    for (0..height) |oy| {
        for (0..width) |ox| {
            visited.clearRetainingCapacity();
            const start = comptime std.mem.indexOfScalar(u8, input, '^').?;
            var dir: Dir = .up;
            var x = start % stride;
            var y = start / stride;
            while (!(try visited.getOrPut(a, .{ dir, @intCast(x), @intCast(y) })).found_existing) switch (dir) {
                .up => {
                    y, const ov = @subWithOverflow(y, 1);
                    if (ov > 0) break;
                    if ((x == ox and y == oy) or input[x + stride * y] == '#') {
                        y += 1;
                        dir = .right;
                    }
                },
                .right => {
                    x += 1;
                    if (x == width) break;
                    if ((x == ox and y == oy) or input[x + stride * y] == '#') {
                        x -= 1;
                        dir = .down;
                    }
                },
                .down => {
                    y += 1;
                    if (y == height) break;
                    if ((x == ox and y == oy) or input[x + stride * y] == '#') {
                        y -= 1;
                        dir = .left;
                    }
                },
                .left => {
                    x, const ov = @subWithOverflow(x, 1);
                    if (ov > 0) break;
                    if ((x == ox and y == oy) or input[x + stride * y] == '#') {
                        x += 1;
                        dir = .up;
                    }
                },
            } else positions += 1;
        }
    }
    try stdout.print("{d}\n", .{positions});
}
