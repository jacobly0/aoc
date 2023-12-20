const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = @embedFile("input");

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

    const expected_cycles = for (modules.values()) |*module| {
        for (module.outs.items) |out| {
            if (std.mem.eql(u8, out, "rx")) {
                break;
            }
        } else continue;
        break module.ins.items.len;
    } else unreachable;
    var cycles = std.StringHashMap(u64).init(a);
    defer cycles.deinit();
    try cycles.ensureTotalCapacity(@intCast(expected_cycles));

    const Pulse = struct {
        source: []const u8,
        destination: []const u8,
        level: Level,
    };
    var pulses = std.ArrayList(Pulse).init(a);
    defer pulses.deinit();

    var press: u64 = 0;
    presses: while (cycles.count() < expected_cycles) {
        press += 1;
        pulses.clearRetainingCapacity();
        try pulses.append(.{ .source = "button", .destination = "broadcaster", .level = .low });
        var pulse_index: usize = 0;
        while (pulse_index < pulses.items.len) : (pulse_index += 1) {
            const pulse = pulses.items[pulse_index];
            if (pulse.level == .low and std.mem.eql(u8, pulse.destination, "rx")) break :presses;
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
                    if (module.ins.items.len > 1 and level == .low) {
                        _ = try cycles.getOrPutValue(pulse.destination, press);
                    }
                    break :level level;
                },
                .broadcast => pulse.level,
            };
            for (module.outs.items) |out| {
                try pulses.append(.{
                    .source = pulse.destination,
                    .destination = out,
                    .level = level,
                });
            }
        }
    }

    var cycle_it = cycles.valueIterator();
    var gcd: u64 = cycle_it.next().?.*;
    while (cycle_it.next()) |cycle| gcd = std.math.gcd(cycle.*, gcd);
    cycle_it = cycles.valueIterator();
    var lcm: u64 = cycle_it.next().?.*;
    while (cycle_it.next()) |cycle| lcm *= @divExact(cycle.*, gcd);
    std.debug.print("{}\n", .{lcm});
}
