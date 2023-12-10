const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\RL
        \\
        \\AAA = (BBB, CCC)
        \\BBB = (DDD, EEE)
        \\CCC = (ZZZ, GGG)
        \\DDD = (DDD, DDD)
        \\EEE = (EEE, EEE)
        \\GGG = (GGG, GGG)
        \\ZZZ = (ZZZ, ZZZ)
        \\
    else if (false)
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
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

    var location: [3]u8 = "AAA".*;
    var directions_i: usize = 0;
    var steps: u64 = 0;
    while (!std.mem.eql(u8, &location, "ZZZ")) : (steps += 1) {
        const branches = map.get(location).?;
        location = switch (directions[directions_i]) {
            'L' => branches[0],
            'R' => branches[1],
            else => unreachable,
        };
        directions_i = (directions_i + 1) % directions.len;
    }
    std.debug.print("{}\n", .{steps});
}
