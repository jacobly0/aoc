const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\Time:      7  15   30
        \\Distance:  9  40  200
        \\
    else
        @embedFile("input");

    var line_it = std.mem.splitScalar(u8, input, '\n');
    var time_it = std.mem.tokenizeScalar(u8, line_it.next().?["Time:".len..], ' ');
    var dist_it = std.mem.tokenizeScalar(u8, line_it.next().?["Distance:".len..], ' ');
    var product: u64 = 1;
    while (time_it.next()) |time_str| {
        const dist_str = dist_it.next().?;
        const time = try std.fmt.parseInt(u64, time_str, 10);
        const dist = try std.fmt.parseInt(u64, dist_str, 10);
        var count: u64 = 0;
        for (0..time + 1) |hold_time| {
            if (hold_time * (time - hold_time) > dist) count += 1;
        }
        product *= count;
    }
    std.debug.print("{}\n", .{product});
}
