const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\px{a<2006:qkq,m>2090:A,rfg}
        \\pv{a>1716:R,A}
        \\lnx{m>1548:A,A}
        \\rfg{s<537:gd,x>2440:R,A}
        \\qs{s>3448:A,lnx}
        \\qkq{x<1416:A,crn}
        \\crn{x>2662:A,R}
        \\in{s<1351:px,qqz}
        \\qqz{s>2770:qs,m<1801:hdj,R}
        \\gd{a>3333:R,R}
        \\hdj{m>838:A,pv}
        \\
        \\{x=787,m=2655,a=1222,s=2876}
        \\{x=1679,m=44,a=2067,s=496}
        \\{x=2036,m=264,a=79,s=2244}
        \\{x=2461,m=1339,a=466,s=291}
        \\{x=2127,m=1623,a=2188,s=1013}
        \\
    else
        @embedFile("input");

    const Rule = union(enum) {
        compare: struct { lhs: u8, op: std.math.CompareOperator, rhs: u32, workflow: []const u8 },
        always: []const u8,
    };
    var workflows = std.StringHashMap(std.ArrayListUnmanaged(Rule)).init(a);
    defer {
        var it = workflows.valueIterator();
        while (it.next()) |workflow| workflow.deinit(a);
        workflows.deinit();
    }

    var line_it = std.mem.splitScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) break;
        const open = std.mem.indexOfScalar(u8, line, '{').?;
        var rules = std.ArrayList(Rule).init(a);
        defer rules.deinit();
        var rule_it = std.mem.tokenizeScalar(u8, line[open + 1 .. line.len - 1], ',');
        while (rule_it.next()) |rule_str| {
            const rule = try rules.addOne();
            rule.* = if (std.mem.indexOfScalar(u8, rule_str, ':')) |colon| .{ .compare = .{
                .lhs = rule_str[0],
                .op = switch (rule_str[1]) {
                    '<' => .lt,
                    '>' => .gt,
                    else => unreachable,
                },
                .rhs = try std.fmt.parseInt(u32, rule_str[2..colon], 10),
                .workflow = rule_str[colon + 1 ..],
            } } else .{ .always = rule_str };
        }
        try workflows.put(line[0..open], rules.moveToUnmanaged());
    }

    const State = struct {
        ratings: [4]struct { min: u32, max: u32 },
        workflow: []const u8,
        workflow_index: u8,
    };
    var states = std.ArrayList(State).init(a);
    defer states.deinit();
    try states.append(.{
        .ratings = .{.{ .min = 1, .max = 4000 }} ** 4,
        .workflow = "in",
        .workflow_index = 0,
    });

    var accepted: u64 = 0;
    while (states.popOrNull()) |prev| {
        if (std.mem.eql(u8, prev.workflow, "A")) {
            var count: u64 = 1;
            for (prev.ratings) |rating| count *= rating.max - rating.min + 1;
            accepted += count;
        } else if (!std.mem.eql(u8, prev.workflow, "R")) {
            switch (workflows.get(prev.workflow).?.items[prev.workflow_index]) {
                .compare => |compare| {
                    try states.ensureUnusedCapacity(2);

                    const rating_index = std.mem.indexOfScalar(u8, "xmas", compare.lhs).?;
                    var ratings = prev.ratings;
                    const rating = ratings[rating_index];

                    matched: {
                        ratings[rating_index] = switch (compare.op) {
                            .lt => if (rating.min < compare.rhs) .{
                                .min = rating.min,
                                .max = @min(rating.max, compare.rhs - 1),
                            } else break :matched,
                            .gt => if (rating.max > compare.rhs) .{
                                .min = @max(rating.min, compare.rhs + 1),
                                .max = rating.max,
                            } else break :matched,
                            else => unreachable,
                        };
                        states.appendAssumeCapacity(.{
                            .ratings = ratings,
                            .workflow = compare.workflow,
                            .workflow_index = 0,
                        });
                    }

                    unmatched: {
                        ratings[rating_index] = switch (compare.op) {
                            .lt => if (rating.max >= compare.rhs) .{
                                .min = @max(rating.min, compare.rhs),
                                .max = rating.max,
                            } else break :unmatched,
                            .gt => if (rating.min <= compare.rhs) .{
                                .min = rating.min,
                                .max = @min(rating.max, compare.rhs),
                            } else break :unmatched,
                            else => unreachable,
                        };
                        states.appendAssumeCapacity(.{
                            .ratings = ratings,
                            .workflow = prev.workflow,
                            .workflow_index = prev.workflow_index + 1,
                        });
                    }
                },
                .always => |workflow| states.appendAssumeCapacity(.{
                    .ratings = prev.ratings,
                    .workflow = workflow,
                    .workflow_index = 0,
                }),
            }
        }
    }
    std.debug.print("{}\n", .{accepted});
}
