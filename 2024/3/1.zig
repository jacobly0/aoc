const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    const input = if (false)
        \\xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
        \\
    else
        @embedFile("input");
    var sum: u64 = 0;
    var pos: usize = 0;
    while (std.mem.indexOfPos(u8, input, pos, "mul(")) |mul_start| {
        pos = mul_start + "mul(".len;
        const lhs_end = std.mem.indexOfNonePos(u8, input, pos, "0123456789") orelse continue;
        const lhs = try std.fmt.parseInt(u64, input[pos..lhs_end], 10);
        pos = lhs_end;
        if (input[pos] != ',') continue;
        pos += 1;
        const rhs_end = std.mem.indexOfNonePos(u8, input, pos, "0123456789") orelse continue;
        const rhs = try std.fmt.parseInt(u64, input[pos..rhs_end], 10);
        pos = rhs_end;
        if (input[pos] != ')') continue;
        pos += 1;
        sum += lhs * rhs;
    }
    try stdout.print("{d}\n", .{sum});
}
