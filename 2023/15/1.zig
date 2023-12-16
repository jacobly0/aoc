const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
        \\
    else
        @embedFile("input");

    var sum: u64 = 0;
    var step_it = std.mem.tokenizeAny(u8, input, ",\n");
    while (step_it.next()) |step| {
        var hash: u8 = 0;
        for (step) |c| {
            hash +%= c;
            hash *%= 17;
        }
        sum += hash;
    }
    std.debug.print("{}\n", .{sum});
}
