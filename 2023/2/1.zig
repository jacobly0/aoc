const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    var sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, @embedFile("input"), '\n');
    while (line_it.next()) |line| {
        const colon = std.mem.indexOfScalar(u8, line, ':').?;
        const id = try std.fmt.parseInt(u32, line["Game ".len..colon], 10);
        var set_it = std.mem.tokenizeScalar(u8, line[colon + ": ".len ..], ';');
        set: while (set_it.next()) |set| {
            var count_it = std.mem.tokenizeAny(u8, set, ", ");
            while (count_it.next()) |count_str| {
                const count = try std.fmt.parseInt(u32, count_str, 10);
                const color = count_it.next().?;
                const max: u32 = if (std.mem.eql(u8, color, "red"))
                    12
                else if (std.mem.eql(u8, color, "green"))
                    13
                else if (std.mem.eql(u8, color, "blue"))
                    14
                else
                    unreachable;
                if (count > max) break :set;
            }
        } else sum += id;
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}
