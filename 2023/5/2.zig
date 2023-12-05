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

    var seeds = std.ArrayList(struct { start: u64, length: u64, mark: bool = false }).init(a);
    defer seeds.deinit();

    var line_it = std.mem.splitScalar(u8, input, '\n');
    var seeds_it = std.mem.tokenizeScalar(u8, line_it.next().?["seeds: ".len..], ' ');
    while (seeds_it.next()) |start_str| {
        const start = try std.fmt.parseInt(u64, start_str, 10);
        const length = try std.fmt.parseInt(u64, seeds_it.next().?, 10);
        try seeds.append(.{ .start = start, .length = length });
    }

    _ = line_it.next();
    while (line_it.next()) |_| {
        for (seeds.items) |*seed| seed.mark = false;
        while (line_it.next()) |line| {
            var range_it = std.mem.tokenizeScalar(u8, line, ' ');
            const destination_range_start = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);
            const source_range_start = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);
            const range_length = try std.fmt.parseInt(u64, range_it.next() orelse break, 10);

            var seed_i: usize = 0;
            while (seed_i < seeds.items.len) : (seed_i += 1) {
                const seed = seeds.items[seed_i];
                if (seed.mark) continue;
                if (seed.start >= source_range_start + range_length) continue;
                if (seed.start + seed.length <= source_range_start) continue;
                if (seed.start < source_range_start) {
                    try seeds.append(.{
                        .start = seed.start,
                        .length = source_range_start - seed.start,
                    });
                }
                seeds.items[seed_i] = .{
                    .start = @max(seed.start, source_range_start) - source_range_start + destination_range_start,
                    .length = @min(seed.start + seed.length, source_range_start + range_length) - @max(seed.start, source_range_start),
                    .mark = true,
                };
                if (seed.start + seed.length > source_range_start + range_length) {
                    try seeds.append(.{
                        .start = source_range_start + range_length,
                        .length = (seed.start + seed.length) - (source_range_start + range_length),
                    });
                }
            }
        }
    }

    var min: u64 = std.math.maxInt(u64);
    for (seeds.items) |seed| min = @min(seed.start, min);
    std.debug.print("{}\n", .{min});
}
