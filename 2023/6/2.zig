const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (true)
        \\Time:      7  15   30
        \\Distance:  9  40  200
        \\
    else
        @embedFile("input");

    var line_it = std.mem.splitScalar(u8, input, '\n');
    const time = parse(line_it.next().?);
    const dist = parse(line_it.next().?);
    const temp = std.math.sqrt(time * time - 4 * dist);
    std.debug.print("{}\n", .{temp + (~(time ^ temp) & 1)});
}

fn parse(str: []const u8) u64 {
    var result: u64 = 0;
    for (str) |c| switch (c) {
        '0'...'9' => result = result * 10 + (c - '0'),
        else => {},
    };
    return result;
}
