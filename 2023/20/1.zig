const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\broadcaster -> a, b, c
        \\%a -> b
        \\%b -> c
        \\%c -> inv
        \\&inv -> a
        \\
    else if (false)
        \\broadcaster -> a
        \\%a -> inv, con
        \\&inv -> b
        \\%b -> con
        \\&con -> output
        \\
    else
        @embedFile("input");

    const Level = enum {
        low,
        high,

        fn flip(level: *@This()) @This() {
            level.* = switch (level.*) {
                .low => .high,
                .high => .low,
            };
            return level.*;
        }
    };
    const Module = struct {
        kind: Kind,
        ins: std.ArrayList([]const u8),
        outs: std.ArrayList([]const u8),
        state: std.ArrayList(Level),

        const Kind = enum {
            flip_flop,
            conjunction,
            broadcast,
        };

        fn deinit(module: *@This()) void {
            module.ins.deinit();
            module.outs.deinit();
            module.state.deinit();
            module.* = undefined;
        }
    };
    var modules = std.StringArrayHashMap(Module).init(a);
    defer {
        for (modules.values()) |*module| module.deinit();
        modules.deinit();
    }

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var module: Module = .{
            .kind = switch (line[0]) {
                '%' => .flip_flop,
                '&' => .conjunction,
                else => .broadcast,
            },
            .ins = std.ArrayList([]const u8).init(a),
            .outs = std.ArrayList([]const u8).init(a),
            .state = std.ArrayList(Level).init(a),
        };
        errdefer module.deinit();

        var name_it = std.mem.tokenizeAny(u8, line, "%& ->,");
        const name = name_it.next().?;
        while (name_it.next()) |out| try module.outs.append(out);
        try modules.putNoClobber(name, module);
    }

    for (modules.keys(), modules.values()) |in, module| {
        for (module.outs.items) |out| {
            try (modules.getPtr(out) orelse continue).ins.append(in);
        }
    }

    for (modules.values()) |*module| {
        switch (module.kind) {
            .flip_flop => try module.state.append(.low),
            .conjunction => try module.state.appendNTimes(.low, module.ins.items.len),
            .broadcast => {},
        }
    }

    var low_pulses: u64 = 0;
    var high_pulses: u64 = 0;
    for (0..1_000) |_| {
        const Pulse = struct {
            source: []const u8,
            destination: []const u8,
            level: Level,
        };
        var pulses = std.ArrayList(Pulse).init(a);
        defer pulses.deinit();
        low_pulses += 1;
        try pulses.append(.{ .source = "button", .destination = "broadcaster", .level = .low });
        var pulse_index: usize = 0;
        while (pulse_index < pulses.items.len) : (pulse_index += 1) {
            const pulse = pulses.items[pulse_index];
            const module = modules.getPtr(pulse.destination) orelse continue;
            const level = switch (module.kind) {
                .flip_flop => switch (pulse.level) {
                    .low => module.state.items[0].flip(),
                    .high => continue,
                },
                .conjunction => level: {
                    var level: Level = .low;
                    for (module.ins.items, module.state.items) |in, *state| {
                        if (std.mem.eql(u8, in, pulse.source)) {
                            state.* = pulse.level;
                        }
                        switch (state.*) {
                            .low => level = .high,
                            .high => {},
                        }
                    }
                    break :level level;
                },
                .broadcast => pulse.level,
            };
            switch (level) {
                .low => low_pulses += module.outs.items.len,
                .high => high_pulses += module.outs.items.len,
            }
            for (module.outs.items) |out| {
                try pulses.append(.{
                    .source = pulse.destination,
                    .destination = out,
                    .level = level,
                });
            }
        }
    }
    std.debug.print("{}\n", .{low_pulses * high_pulses});
}
