const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = .{ stdout, a };

    const input = if (false)
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
        \\
    else
        @embedFile("input");
    const word = "MAS";
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);
    var counts: std.AutoArrayHashMapUnmanaged(struct { usize, usize }, u2) = .{};
    defer counts.deinit(a);
    for (0..width) |y| {
        for (0..height) |x| {
            if (x + word.len <= width and y + word.len <= height) {
                for (0.., word) |off, c| {
                    if (input[(x + off) + stride * (y + off)] != c) break;
                } else {
                    const gop = try counts.getOrPut(a, .{ x + 1, y + 1 });
                    if (!gop.found_existing) gop.value_ptr.* = 0;
                    gop.value_ptr.* += 1;
                }
            }
            if (x + word.len <= width and y >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x + off) + stride * (y - off)] != c) break;
                } else {
                    const gop = try counts.getOrPut(a, .{ x + 1, y - 1 });
                    if (!gop.found_existing) gop.value_ptr.* = 0;
                    gop.value_ptr.* += 1;
                }
            }
            if (x >= word.len - 1 and y + word.len <= height) {
                for (0.., word) |off, c| {
                    if (input[(x - off) + stride * (y + off)] != c) break;
                } else {
                    const gop = try counts.getOrPut(a, .{ x - 1, y + 1 });
                    if (!gop.found_existing) gop.value_ptr.* = 0;
                    gop.value_ptr.* += 1;
                }
            }
            if (x >= word.len - 1 and y >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x - off) + stride * (y - off)] != c) break;
                } else {
                    const gop = try counts.getOrPut(a, .{ x - 1, y - 1 });
                    if (!gop.found_existing) gop.value_ptr.* = 0;
                    gop.value_ptr.* += 1;
                }
            }
        }
    }
    var total: u64 = 0;
    for (counts.values()) |count| {
        if (count == 2) total += 1;
    }
    try stdout.print("{d}\n", .{total});
}
