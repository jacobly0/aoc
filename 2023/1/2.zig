const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    var sum: usize = 0;
    var line_it = std.mem.tokenizeScalar(u8, @embedFile("input"), '\n');
    while (line_it.next()) |line| {
        const digits = "123456789";
        const numbers = [_][]const u8{
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
        };

        var first_digit_index = std.mem.indexOfAny(u8, line, digits).?;
        var first_digit: usize = line[first_digit_index] - '0';
        for (numbers, 1..) |number, digit| {
            if (std.mem.indexOf(u8, line, number)) |index| {
                if (index < first_digit_index) {
                    first_digit_index = index;
                    first_digit = digit;
                }
            }
        }

        var last_digit_index = std.mem.lastIndexOfAny(u8, line, digits).?;
        var last_digit: usize = line[last_digit_index] - '0';
        for (numbers, 1..) |number, digit| {
            if (std.mem.lastIndexOf(u8, line, number)) |index| {
                if (index + number.len - 1 > last_digit_index) {
                    last_digit_index = index + number.len - 1;
                    last_digit = digit;
                }
            }
        }

        sum += first_digit * 10 + last_digit;
    }
    try std.io.getStdOut().writer().print("{}\n", .{sum});
}
