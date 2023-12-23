const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\#.#####################
        \\#.......#########...###
        \\#######.#########.#.###
        \\###.....#.>.>.###.#.###
        \\###v#####.#v#.###.#.###
        \\###.>...#.#.#.....#...#
        \\###v###.#.#.#########.#
        \\###...#.#.#.......#...#
        \\#####.#.#.#######.#.###
        \\#.....#.#.#.......#...#
        \\#.#####.#.#.#########v#
        \\#.#...#...#...###...>.#
        \\#.#.#v#######v###.###v#
        \\#...#.>.#...>.>.#.###.#
        \\#####v#.#.###v#.#.###.#
        \\#.....#...#...#.#.#...#
        \\#.#########.###.#.#.###
        \\#...###...#...#...#.###
        \\###.###.#.###v#####v###
        \\#...#...#.#.>.>.#.>.###
        \\#.###.###.#.###.#.#v###
        \\#.....###...###...#...#
        \\#####################.#
        \\
    else
        @embedFile("input");

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const stride = width + 1;
    const height = @divExact(input.len, stride);

    const Node = struct { x: u8, y: u8 };
    const Edge = struct { neighbor: u8, distance: u16 };
    var intersections = std.AutoArrayHashMap(Node, std.ArrayList(Edge)).init(a);
    defer {
        for (intersections.values()) |*intersection| intersection.deinit();
        intersections.deinit();
    }

    const dirs = [_]struct { x: i2, y: i2 }{
        .{ .x = 1, .y = 0 },
        .{ .x = 0, .y = 1 },
        .{ .x = -1, .y = 0 },
        .{ .x = 0, .y = -1 },
    };
    for (0..height) |y| {
        for (1..width - 1) |x| {
            if (input[x + stride * y] == '#') continue;
            if (y == 0 or y == height - 1 or is_intersection: {
                var count: u3 = 0;
                for (dirs) |dir| {
                    const nx: u8 = @intCast(@as(i9, @intCast(x)) + dir.x);
                    const ny: u8 = @intCast(@as(i9, @intCast(y)) + dir.y);
                    count += @intFromBool(input[nx + stride * ny] != '#');
                }
                std.debug.assert(count >= 2);
                break :is_intersection count > 2;
            }) try intersections.putNoClobber(.{ .x = @intCast(x), .y = @intCast(y) }, try std.ArrayList(Edge).initCapacity(a, 4));
        }
    }

    for (intersections.keys(), intersections.values()) |position, *intersection| {
        for (dirs) |first_dir| {
            var prev = position;
            const first_x = @as(i9, prev.x) + first_dir.x;
            const first_y = @as(i9, prev.y) + first_dir.y;
            if (first_x < 0 or first_x >= width or first_y < 0 or first_y >= height) continue;
            var cur: Node = .{ .x = @intCast(first_x), .y = @intCast(first_y) };
            if (input[cur.x + stride * cur.y] == '#') continue;
            var distance: u16 = 1;
            while (true) : (distance += 1) {
                if (intersections.getIndex(cur)) |intersection_index| {
                    intersection.appendAssumeCapacity(.{ .neighbor = @intCast(intersection_index), .distance = distance });
                    break;
                }
                for (dirs) |dir| {
                    const next: Node = .{ .x = @intCast(@as(i9, cur.x) + dir.x), .y = @intCast(@as(i9, cur.y) + dir.y) };
                    if (next.x == prev.x and next.y == prev.y) continue;
                    if (input[next.x + stride * next.y] == '#') continue;
                    prev = cur;
                    cur = next;
                    break;
                }
            }
        }
    }

    var max: u16 = std.math.minInt(u16);
    var distance: u16 = 0;
    var path = std.AutoArrayHashMap(u8, void).init(a);
    defer path.deinit();
    try path.put(0, {});
    while (true) {
        var cur = path.keys()[path.count() - 1];
        for (intersections.values()[cur].items) |next| {
            const gop = try path.getOrPut(next.neighbor);
            if (!gop.found_existing) {
                gop.value_ptr.* = {};
                distance += next.distance;
                break;
            }
        } else {
            if (cur == intersections.count() - 1) max = @max(distance, max);
            while (path.count() > 1) {
                _ = path.pop();
                const prev = path.keys()[path.count() - 1];
                var found = false;
                for (intersections.values()[prev].items) |next| {
                    if (found) {
                        const gop = try path.getOrPut(next.neighbor);
                        if (!gop.found_existing) {
                            gop.value_ptr.* = {};
                            distance += next.distance;
                            break;
                        }
                    } else if (next.neighbor == cur) {
                        distance -= next.distance;
                        found = true;
                    }
                } else {
                    cur = prev;
                    continue;
                }
                break;
            } else break;
        }
    }
    std.debug.print("{}\n", .{max});
}
