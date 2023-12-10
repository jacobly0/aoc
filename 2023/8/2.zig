const std = @import("std");

pub fn main() !void {
    if (true) {
        for (0..1 << 35) |i| std.mem.doNotOptimizeAway(i);
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
        \\
    else
        @embedFile("input");

    var map = std.AutoArrayHashMap([3]u8, struct { [3]u8, [3]u8 }).init(a);
    defer map.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    const directions = line_it.next().?;
    while (line_it.next()) |line| {
        try map.putNoClobber(line[0..3].*, .{ line[7..10].*, line[12..15].* });
    }

    var steps_list = std.ArrayList(std.ArrayList(u64)).init(a);
    defer {
        for (steps_list.items) |*steps| steps.deinit();
        steps_list.deinit();
    }
    for (map.keys()) |start| {
        if (start[2] != 'A') continue;
        var location: [3]u8 = start;
        var directions_i: usize = 0;
        var steps: u64 = 0;
        const steps_last = try steps_list.addOne();
        steps_last.* = std.ArrayList(u64).init(a);
        while (steps_list.getLast().items.len < 2) : (steps += 1) {
            if (location[2] == 'Z') try steps_last.append(steps);
            const branches = map.get(location).?;
            location = switch (directions[directions_i]) {
                'L' => branches[0],
                'R' => branches[1],
                else => unreachable,
            };
            directions_i = (directions_i + 1) % directions.len;
        }
        std.debug.assert(steps_last.items[0] * 2 == steps_last.items[1]);
    }

    var gcd = steps_list.items[0].items[0];
    for (steps_list.items[1..]) |steps| gcd = std.math.gcd(steps.items[0], gcd);
    var product: u64 = steps_list.items[0].items[0];
    for (steps_list.items[1..]) |steps| product *= @divExact(steps.items[0], gcd);
    std.debug.print("{}\n", .{product});
}
