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
    var visited: std.AutoHashMapUnmanaged(struct { u32, u32 }, void) = .{};
    defer visited.deinit(a);
    const width = comptime std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);
    const start = comptime std.mem.indexOfScalar(u8, input, '^').?;
    var dir: enum { up, right, down, left } = .up;
    var x = start % stride;
    var y = start / stride;
    while (true) {
        try visited.put(a, .{ @intCast(x), @intCast(y) }, {});
        switch (dir) {
            .up => {
                y, const ov = @subWithOverflow(y, 1);
                if (ov > 0) break;
                if (input[x + stride * y] == '#') {
                    y += 1;
                    dir = .right;
                }
            },
            .right => {
                x += 1;
                if (x == width) break;
                if (input[x + stride * y] == '#') {
                    x -= 1;
                    dir = .down;
                }
            },
            .down => {
                y += 1;
                if (y == height) break;
                if (input[x + stride * y] == '#') {
                    y -= 1;
                    dir = .left;
                }
            },
            .left => {
                x, const ov = @subWithOverflow(x, 1);
                if (ov > 0) break;
                if (input[x + stride * y] == '#') {
                    x += 1;
                    dir = .up;
                }
            },
        }
    }
    try stdout.print("{d}\n", .{visited.count()});
}
