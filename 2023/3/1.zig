const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    var sum: u64 = 0;
    const input = if (false)
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
        \\
    else
        @embedFile("input");
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) {
            const pos = x + stride * y;
            switch (input[pos]) {
                '0'...'9' => {
                    const len = std.mem.indexOfNone(u8, input[pos..], "0123456789").?;
                    const number = try std.fmt.parseInt(u64, input[pos..][0..len], 10);
                    var adjacent = false;
                    if (x > 0) {
                        if (y > 0 and isSymbol(input[(x - 1) + stride * (y - 1)])) adjacent = true;
                        if (isSymbol(input[(x - 1) + stride * (y + 0)])) adjacent = true;
                        if (y < height - 1 and isSymbol(input[(x - 1) + stride * (y + 1)])) adjacent = true;
                    }
                    for (0..len) |i| {
                        if (y > 0 and isSymbol(input[(x + i) + stride * (y - 1)])) adjacent = true;
                        if (y < height - 1 and isSymbol(input[(x + i) + stride * (y + 1)])) adjacent = true;
                    }
                    if (x + len < width) {
                        if (y > 0 and isSymbol(input[(x + len) + stride * (y - 1)])) adjacent = true;
                        if (isSymbol(input[(x + len) + stride * (y + 0)])) adjacent = true;
                        if (y < height - 1 and isSymbol(input[(x + len) + stride * (y + 1)])) adjacent = true;
                    }
                    if (adjacent) sum += number;
                    x += len;
                },
                else => x += 1,
            }
        }
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}

fn isSymbol(c: u8) bool {
    return c != '.' and c != '\n' and (c < '0' or c > '9');
}
