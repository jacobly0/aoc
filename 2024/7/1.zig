const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    const input = if (false)
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
        \\
    else
        @embedFile("input");
    var nums: std.ArrayListUnmanaged(u64) = .{};
    defer nums.deinit(a);
    const Op = enum { add, multiply };
    var ops: std.ArrayListUnmanaged(Op) = .{};
    defer ops.deinit(a);
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var total_calibration_result: u64 = 0;
    while (line_it.next()) |line| {
        nums.clearRetainingCapacity();
        ops.clearRetainingCapacity();
        var tok_it = std.mem.splitScalar(u8, line, ' ');
        const test_value_str = tok_it.next().?;
        std.debug.assert(test_value_str[test_value_str.len - 1] == ':');
        const test_value = try std.fmt.parseInt(u64, test_value_str[0 .. test_value_str.len - 1], 10);
        while (tok_it.next()) |num_str| try nums.append(a, try std.fmt.parseInt(u64, num_str, 10));
        try ops.appendNTimes(a, .add, nums.items.len - 1);
        while (true) {
            var lhs = nums.items[0];
            for (ops.items, nums.items[1..]) |op, rhs| switch (op) {
                .add => lhs += rhs,
                .multiply => lhs *= rhs,
            };
            if (lhs == test_value) {
                total_calibration_result += test_value;
                break;
            }
            for (ops.items) |*op| {
                const op_val = @intFromEnum(op.*);
                if (op_val < @typeInfo(Op).@"enum".fields.len - 1) {
                    op.* = @enumFromInt(op_val + 1);
                    break;
                }
                op.* = @enumFromInt(0);
            } else break;
        }
    }
    try stdout.print("{d}\n", .{total_calibration_result});
}
