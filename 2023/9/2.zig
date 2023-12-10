const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\0 3 6 9 12 15
        \\1 3 6 10 15 21
        \\10 13 16 21 30 45
        \\
    else
        @embedFile("input");

    var sum: i64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var list = std.ArrayList(std.ArrayList(i64)).init(a);
        defer {
            for (list.items) |item| item.deinit();
            list.deinit();
        }

        try list.append(std.ArrayList(i64).init(a));
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');
        while (num_it.next()) |num| {
            try list.items[0].append(try std.fmt.parseInt(i64, num, 10));
        }

        while (true) {
            const prev = list.items[list.items.len - 1];
            for (prev.items) |item| {
                if (item != 0) break;
            } else break;

            var next = std.ArrayList(i64).init(a);
            errdefer next.deinit();
            try next.ensureTotalCapacity(prev.items.len - 1);
            for (0..prev.items.len - 1) |i| {
                next.appendAssumeCapacity(prev.items[i + 1] - prev.items[i]);
            }
            try list.append(next);
        }

        var i = list.items.len - 1;
        try list.items[i].insert(0, 0);
        while (i > 0) : (i -= 1) {
            try list.items[i - 1].insert(0, list.items[i - 1].items[0] - list.items[i].items[0]);
        }

        sum += list.items[0].items[0];
    }
    std.debug.print("{}\n", .{sum});
}
