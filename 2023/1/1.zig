const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    var sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, @embedFile("input"), '\n');
    while (line_it.next()) |line| {
        const digit = "0123456789";
        sum += (line[std.mem.indexOfAny(u8, line, digit).?] - '0') * 10 +
            (line[std.mem.lastIndexOfAny(u8, line, digit).?] - '0');
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}
