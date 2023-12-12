const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\???.### 1,1,3
        \\.??..??...?##. 1,1,3
        \\?#?#?#?#?#?#?#? 1,3,1,6
        \\????.#...#... 4,1,1
        \\????.######..#####. 1,6,5
        \\?###???????? 3,2,1
        \\
    else
        @embedFile("input");

    const factor = 5;
    const Shared = struct {
        mutex: std.Thread.Mutex,
        line_it: std.mem.TokenIterator(u8, .scalar),
        sum: u64,

        fn start(shared: *@This(), backing_allocator: std.mem.Allocator) !void {
            var thread_gpa = std.heap.GeneralPurposeAllocator(.{
                .thread_safe = false,
            }){ .backing_allocator = backing_allocator };
            defer _ = thread_gpa.deinit();
            const thread_a = thread_gpa.allocator();
            _ = &thread_a;

            var sum: u64 = 0;
            while (true) {
                var line: []const u8 = undefined;
                {
                    shared.mutex.lock();
                    defer shared.mutex.unlock();

                    shared.sum += sum;
                    sum = 0;

                    line = shared.line_it.next() orelse return;
                }

                var space_it = std.mem.tokenizeScalar(u8, line, ' ');

                var unknown_count: u5 = 0;
                const springs = space_it.next().?;
                for (springs) |c| unknown_count += @intFromBool(c == '?');
                const guess = try thread_a.alloc(u8, (springs.len + 1) * factor);
                defer thread_a.free(guess);
                for (0..factor) |i| {
                    @memcpy(guess[(springs.len + 1) * i ..][0..springs.len], springs);
                    guess[(springs.len + 1) * i + springs.len] = '?';
                }
                guess[guess.len - 1] = '.';

                var counts_list = std.ArrayList(u8).init(thread_a);
                defer counts_list.deinit();
                var counts_it = std.mem.tokenizeScalar(u8, space_it.next().?, ',');
                while (counts_it.next()) |count| try counts_list.append(try std.fmt.parseInt(u8, count, 10));
                const counts_len = counts_list.items.len;
                try counts_list.ensureTotalCapacity(counts_len * factor);
                for (1..factor) |_| counts_list.appendSliceAssumeCapacity(counts_list.items[0..counts_len]);

                const BitSet = std.StaticBitSet((20 + 1) * factor);
                var stack = std.ArrayList(struct {
                    guess: BitSet,
                    spring_i: u8,
                    count_i: u8,
                    count: u8,

                    fn advance(prev_state: @This(), springs_len: usize, counts: []const u8) ?@This() {
                        var state = prev_state;
                        if (state.guess.isSet(state.spring_i)) {
                            if (state.count_i >= counts.len) return null;
                            state.count += 1;
                            if (state.count > counts[state.count_i]) return null;
                        } else if (state.count > 0) {
                            if (state.count != counts[state.count_i]) return null;
                            state.count_i += 1;
                            state.count = 0;
                        }

                        state.spring_i += 1;
                        var min_needed: u8 = state.spring_i;
                        for (counts[state.count_i..]) |count| {
                            min_needed += count + 1;
                        }
                        min_needed -= state.count + 1;
                        if (min_needed > springs_len) return null;

                        return state;
                    }

                    fn rewind(state: *@This(), counts: []const u8) void {
                        state.spring_i -= 1;
                        if (state.guess.isSet(state.spring_i)) {
                            state.count -= 1;
                        } else if (state.spring_i > 0 and state.guess.isSet(state.spring_i - 1) and state.count == 0) {
                            state.count_i -= 1;
                            state.count = counts[state.count_i];
                        }
                    }
                }).init(thread_a);
                defer stack.deinit();
                try stack.append(.{
                    .guess = BitSet.initEmpty(),
                    .spring_i = 0,
                    .count_i = 0,
                    .count = 0,
                });
                var cache = std.AutoHashMap(struct { spring_i: u8, count_i: u8, count: u8 }, u64).init(thread_a);
                defer cache.deinit();
                try cache.putNoClobber(.{ .spring_i = @intCast(guess.len), .count_i = @intCast(counts_list.items.len), .count = 0 }, 1);

                while (stack.popOrNull()) |prev_state| {
                    var state = prev_state;
                    if (cache.get(.{ .spring_i = state.spring_i, .count_i = state.count_i, .count = state.count })) |cached| {
                        while (state.spring_i > 0) {
                            state.rewind(counts_list.items);
                            const entry =
                                try cache.getOrPutValue(.{ .spring_i = state.spring_i, .count_i = state.count_i, .count = state.count }, 0);
                            entry.value_ptr.* += cached;
                        }
                        std.debug.assert(state.spring_i == 0 and state.count_i == 0 and state.count == 0);
                        sum += cached;
                        continue;
                    }
                    switch (guess[state.spring_i]) {
                        '.' => state.guess.unset(state.spring_i),
                        '#' => state.guess.set(state.spring_i),
                        '?' => {
                            state.guess.set(state.spring_i);
                            try stack.ensureUnusedCapacity(2);
                            if (state.advance(guess.len - 1, counts_list.items)) |next_state| stack.appendAssumeCapacity(next_state);
                            state.guess.unset(state.spring_i);
                        },
                        else => unreachable,
                    }
                    if (state.advance(guess.len - 1, counts_list.items)) |next_state| stack.appendAssumeCapacity(next_state);
                }
            }
        }
    };
    var shared: Shared = .{
        .mutex = .{},
        .line_it = std.mem.tokenizeScalar(u8, input, '\n'),
        .sum = 0,
    };

    const threads = try a.alloc(std.Thread, std.Thread.getCpuCount() catch 1);
    defer a.free(threads);
    for (0.., threads) |thread_id, *thread| {
        errdefer for (threads[0..thread_id]) |old_thread| old_thread.detach();
        thread.* = try std.Thread.spawn(.{ .allocator = a }, Shared.start, .{ &shared, a });
    }
    for (threads) |thread| thread.join();
    std.debug.print("{}", .{shared.sum});
}
