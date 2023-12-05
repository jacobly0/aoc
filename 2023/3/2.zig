const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

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

    var gears = std.AutoHashMap(struct { usize, usize }, std.ArrayList(u64)).init(a);
    defer {
        var it = gears.valueIterator();
        while (it.next()) |numbers| numbers.deinit();
        gears.deinit();
    }

    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) {
            const pos = x + stride * y;
            switch (input[pos]) {
                '0'...'9' => {
                    const len = std.mem.indexOfNone(u8, input[pos..], "0123456789").?;
                    const number = try std.fmt.parseInt(u64, input[pos..][0..len], 10);
                    if (x > 0) {
                        if (y > 0 and isSymbol(input[(x - 1) + stride * (y - 1)])) {
                            try (try gears.getOrPutValue(.{ x - 1, y - 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                        if (isSymbol(input[(x - 1) + stride * (y + 0)])) {
                            try (try gears.getOrPutValue(.{ x - 1, y + 0 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                        if (y < height - 1 and isSymbol(input[(x - 1) + stride * (y + 1)])) {
                            try (try gears.getOrPutValue(.{ x - 1, y + 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                    }
                    for (0..len) |i| {
                        if (y > 0 and isSymbol(input[(x + i) + stride * (y - 1)])) {
                            try (try gears.getOrPutValue(.{ x + i, y - 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                        if (y < height - 1 and isSymbol(input[(x + i) + stride * (y + 1)])) {
                            try (try gears.getOrPutValue(.{ x + i, y + 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                    }
                    if (x + len < width) {
                        if (y > 0 and isSymbol(input[(x + len) + stride * (y - 1)])) {
                            try (try gears.getOrPutValue(.{ x + len, y - 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                        if (isSymbol(input[(x + len) + stride * (y + 0)])) {
                            try (try gears.getOrPutValue(.{ x + len, y + 0 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                        if (y < height - 1 and isSymbol(input[(x + len) + stride * (y + 1)])) {
                            try (try gears.getOrPutValue(.{ x + len, y + 1 }, std.ArrayList(u64).init(a))).value_ptr.append(number);
                        }
                    }
                    x += len;
                },
                else => x += 1,
            }
        }
    }

    var sum: u64 = 0;
    var gear_it = gears.valueIterator();
    while (gear_it.next()) |numbers| {
        if (numbers.items.len != 2) continue;
        sum += numbers.items[0] * numbers.items[1];
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}

fn isSymbol(c: u8) bool {
    return c != '.' and c != '\n' and (c < '0' or c > '9');
}
