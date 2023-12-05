const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
        \\
    else
        @embedFile("input");

    var seeds = std.ArrayList(u64).init(a);
    defer seeds.deinit();

    var line_it = std.mem.splitScalar(u8, input, '\n');
    var seeds_it = std.mem.tokenizeScalar(u8, line_it.next().?["seeds: ".len..], ' ');
    while (seeds_it.next()) |seed| try seeds.append(try std.fmt.parseInt(u64, seed, 10));

    _ = line_it.next();
    while (line_it.next()) |_| {
        const marks = try a.alloc(bool, seeds.items.len);
        defer a.free(marks);
        @memset(marks, false);
        while (line_it.next()) |line| {
            var range_it = std.mem.tokenizeScalar(u8, line, ' ');
            const destination_range_start = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);
            const source_range_start = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);
            const range_length = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);
            for (seeds.items, marks) |*seed, *mark| {
                if (mark.*) continue;
                if (seed.* >= source_range_start and seed.* < source_range_start + range_length) {
                    seed.* -= source_range_start;
                    seed.* += destination_range_start;
                    mark.* = true;
                }
            }
        }
    }
    std.debug.print("{}\n", .{std.mem.min(u64, seeds.items)});
}
