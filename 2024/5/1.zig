const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    const input = if (false)
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
        \\
    else
        @embedFile("input");
    var sum: u64 = 0;
    var map: std.AutoHashMapUnmanaged(struct { u32, u32 }, void) = .{};
    defer map.deinit(a);
    var line_it = std.mem.splitScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) break;
        var tok_it = std.mem.splitScalar(u8, line, '|');
        const lhs = try std.fmt.parseInt(u32, tok_it.next().?, 10);
        const rhs = try std.fmt.parseInt(u32, tok_it.next().?, 10);
        try map.put(a, .{ lhs, rhs }, {});
    }
    var update: std.ArrayListUnmanaged(u32) = .{};
    defer update.deinit(a);
    line: while (line_it.next()) |line| {
        if (line.len == 0) break;
        update.clearRetainingCapacity();
        var tok_it = std.mem.splitScalar(u8, line, ',');
        while (tok_it.next()) |tok| try update.append(a, try std.fmt.parseInt(u32, tok, 10));
        for (update.items[0 .. update.items.len - 1], 0..) |lhs, lhs_index| for (update.items[lhs_index + 1 ..]) |rhs| if (map.contains(.{ rhs, lhs })) continue :line;
        sum += update.items[update.items.len / 2];
    }
    try stdout.print("{d}\n", .{sum});
}
