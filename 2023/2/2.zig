const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    var sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, if (false)
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        \\
    else
        @embedFile("input"), '\n');
    while (line_it.next()) |line| {
        const colon = std.mem.indexOfScalar(u8, line, ':').?;
        var set_it = std.mem.tokenizeScalar(u8, line[colon + ": ".len ..], ';');
        var mins: [3]u32 = .{0} ** 3;
        while (set_it.next()) |set| {
            var count_it = std.mem.tokenizeAny(u8, set, ", ");
            while (count_it.next()) |count_str| {
                const count = try std.fmt.parseInt(u32, count_str, 10);
                const color = count_it.next().?;
                const min = if (std.mem.eql(u8, color, "red"))
                    &mins[0]
                else if (std.mem.eql(u8, color, "green"))
                    &mins[1]
                else if (std.mem.eql(u8, color, "blue"))
                    &mins[2]
                else
                    unreachable;
                min.* = @max(count, min.*);
            }
        }
        sum += mins[0] * mins[1] * mins[2];
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}
