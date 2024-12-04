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
    const word = "XMAS";
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);
    var count: u64 = 0;
    for (0..width) |y| {
        for (0..height) |x| {
            if (x + word.len <= width) {
                for (0.., word) |off, c| {
                    if (input[(x + off) + stride * (y + 0)] != c) break;
                } else count += 1;
            }
            if (x >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x - off) + stride * (y - 0)] != c) break;
                } else count += 1;
            }
            if (y + word.len <= height) {
                for (0.., word) |off, c| {
                    if (input[(x + 0) + stride * (y + off)] != c) break;
                } else count += 1;
            }
            if (y >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x - 0) + stride * (y - off)] != c) break;
                } else count += 1;
            }
            if (x + word.len <= width and y + word.len <= height) {
                for (0.., word) |off, c| {
                    if (input[(x + off) + stride * (y + off)] != c) break;
                } else count += 1;
            }
            if (x + word.len <= width and y >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x + off) + stride * (y - off)] != c) break;
                } else count += 1;
            }
            if (x >= word.len - 1 and y + word.len <= height) {
                for (0.., word) |off, c| {
                    if (input[(x - off) + stride * (y + off)] != c) break;
                } else count += 1;
            }
            if (x >= word.len - 1 and y >= word.len - 1) {
                for (0.., word) |off, c| {
                    if (input[(x - off) + stride * (y - off)] != c) break;
                } else count += 1;
            }
        }
    }
    try stdout.print("{d}\n", .{count});
}
