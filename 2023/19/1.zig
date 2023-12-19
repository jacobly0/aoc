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

    var accepted: u32 = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) break;
        var rating_it = std.mem.tokenizeAny(u8, line, "{xmas=,}");
        const x_rating = try std.fmt.parseInt(u32, rating_it.next().?, 10);
        const m_rating = try std.fmt.parseInt(u32, rating_it.next().?, 10);
        const a_rating = try std.fmt.parseInt(u32, rating_it.next().?, 10);
        const s_rating = try std.fmt.parseInt(u32, rating_it.next().?, 10);
        var cur_workflow: []const u8 = "in";
        while (!std.mem.eql(u8, cur_workflow, "A") and !std.mem.eql(u8, cur_workflow, "R")) {
            cur_workflow = for (workflows.get(cur_workflow).?.items) |rule| {
                switch (rule) {
                    .compare => |compare| if (std.math.order(switch (compare.lhs) {
                        'x' => x_rating,
                        'm' => m_rating,
                        'a' => a_rating,
                        's' => s_rating,
                        else => unreachable,
                    }, compare.rhs).compare(compare.op)) break compare.workflow,
                    .always => |workflow| break workflow,
                }
            } else unreachable;
        }
        if (std.mem.eql(u8, cur_workflow, "A")) accepted += x_rating + m_rating + a_rating + s_rating;
    }
    std.debug.print("{}\n", .{accepted});
}
