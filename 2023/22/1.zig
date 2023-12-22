const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\1,0,1~1,2,1
        \\0,0,2~2,0,2
        \\0,2,3~2,2,3
        \\0,0,4~0,2,4
        \\2,0,5~2,2,5
        \\0,1,6~2,1,6
        \\1,1,8~1,1,9
        \\
    else
        @embedFile("input");

    var x_map = std.AutoHashMap(u32, std.AutoArrayHashMapUnmanaged(u32, void)).init(a);
    defer {
        var value_it = x_map.valueIterator();
        while (value_it.next()) |value| value.deinit(a);
        x_map.deinit();
    }

    var y_map = std.AutoHashMap(u32, std.AutoArrayHashMapUnmanaged(u32, void)).init(a);
    defer {
        var value_it = y_map.valueIterator();
        while (value_it.next()) |value| value.deinit(a);
        y_map.deinit();
    }

    var z_map = std.AutoHashMap(u32, std.AutoArrayHashMapUnmanaged(u32, void)).init(a);
    defer {
        var value_it = z_map.valueIterator();
        while (value_it.next()) |value| value.deinit(a);
        z_map.deinit();
    }

    var bricks = std.ArrayList(struct {
        x1: u32,
        y1: u32,
        z1: u32,
        x2: u32,
        y2: u32,
        z2: u32,
    }).init(a);
    defer bricks.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var coord_it = std.mem.tokenizeAny(u8, line, ",~");
        const brick_index: u32 = @intCast(bricks.items.len);
        const brick = try bricks.addOne();
        brick.* = .{
            .x1 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
            .y1 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
            .z1 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
            .x2 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
            .y2 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
            .z2 = try std.fmt.parseInt(u32, coord_it.next().?, 10),
        };
        if (brick.x1 > brick.x2) std.mem.swap(u32, &brick.x1, &brick.x2);
        if (brick.y1 > brick.y2) std.mem.swap(u32, &brick.y1, &brick.y2);
        if (brick.z1 > brick.z2) std.mem.swap(u32, &brick.z1, &brick.z2);
        if (brick.x1 == brick.x2) {
            const gop = try x_map.getOrPut(brick.x1);
            if (!gop.found_existing) gop.value_ptr.* = .{};
            try gop.value_ptr.putNoClobber(a, brick_index, {});
        }
        if (brick.y1 == brick.y2) {
            const gop = try y_map.getOrPut(brick.y1);
            if (!gop.found_existing) gop.value_ptr.* = .{};
            try gop.value_ptr.putNoClobber(a, brick_index, {});
        }
        if (brick.z1 == brick.z2) {
            const gop = try z_map.getOrPut(brick.z1);
            if (!gop.found_existing) gop.value_ptr.* = .{};
            try gop.value_ptr.putNoClobber(a, brick_index, {});
        }
    }

    var done = false;
    while (!done) {
        done = true;
        for (0.., bricks.items) |brick_index, *brick| {
            move: while (brick.z1 > 0) {
                if (brick.x1 == brick.x2) {
                    if (x_map.getPtr(brick.x1)) |other_bricks| {
                        for (other_bricks.keys()) |other_brick_index| {
                            const other_brick = &bricks.items[other_brick_index];
                            if (other_brick.y1 <= brick.y2 and brick.y1 <= other_brick.y2 and other_brick.z2 == brick.z1 - 1) break :move;
                        }
                    }
                }
                if (brick.y1 == brick.y2) {
                    if (y_map.getPtr(brick.y1)) |other_bricks| {
                        for (other_bricks.keys()) |other_brick_index| {
                            const other_brick = &bricks.items[other_brick_index];
                            if (other_brick.x1 <= brick.x2 and brick.x1 <= other_brick.x2 and other_brick.z2 == brick.z1 - 1) break :move;
                        }
                    }
                }
                if (z_map.getPtr(brick.z1 - 1)) |other_bricks| {
                    for (other_bricks.keys()) |other_brick_index| {
                        const other_brick = &bricks.items[other_brick_index];
                        if (other_brick.x1 <= brick.x2 and brick.x1 <= other_brick.x2 and other_brick.y1 <= brick.y2 and brick.y1 <= other_brick.y2) break :move;
                    }
                }

                done = false;
                if (brick.z1 == brick.z2) {
                    std.debug.assert(z_map.getPtr(brick.z1).?.swapRemove(@intCast(brick_index)));
                    const gop = try z_map.getOrPut(brick.z1 - 1);
                    if (!gop.found_existing) gop.value_ptr.* = .{};
                    try gop.value_ptr.putNoClobber(a, @intCast(brick_index), {});
                }
                brick.z1 -= 1;
                brick.z2 -= 1;
            }
        }
    }

    var supported_bricks = std.AutoArrayHashMap(u32, void).init(a);
    defer supported_bricks.deinit();

    var count: u32 = 0;
    for (0.., bricks.items) |brick_index, *brick| {
        supported_bricks.clearRetainingCapacity();

        if (brick.x1 == brick.x2) {
            if (x_map.getPtr(brick.x1)) |other_bricks| {
                for (other_bricks.keys()) |other_brick_index| {
                    const other_brick = &bricks.items[other_brick_index];
                    if (other_brick.y1 <= brick.y2 and brick.y1 <= other_brick.y2 and other_brick.z1 == brick.z2 + 1) try supported_bricks.put(other_brick_index, {});
                }
            }
        }
        if (brick.y1 == brick.y2) {
            if (y_map.getPtr(brick.y1)) |other_bricks| {
                for (other_bricks.keys()) |other_brick_index| {
                    const other_brick = &bricks.items[other_brick_index];
                    if (other_brick.x1 <= brick.x2 and brick.x1 <= other_brick.x2 and other_brick.z1 == brick.z2 + 1) try supported_bricks.put(other_brick_index, {});
                }
            }
        }
        if (z_map.getPtr(brick.z2 + 1)) |other_bricks| {
            for (other_bricks.keys()) |other_brick_index| {
                const other_brick = &bricks.items[other_brick_index];
                if (other_brick.x1 <= brick.x2 and brick.x1 <= other_brick.x2 and other_brick.y1 <= brick.y2 and brick.y1 <= other_brick.y2) try supported_bricks.put(other_brick_index, {});
            }
        }

        supported: for (supported_bricks.keys()) |supported_brick_index| {
            const supported_brick = &bricks.items[supported_brick_index];
            if (supported_brick.x1 == supported_brick.x2) {
                if (x_map.getPtr(supported_brick.x1)) |other_bricks| {
                    for (other_bricks.keys()) |other_brick_index| {
                        if (other_brick_index == brick_index) continue;
                        const other_brick = &bricks.items[other_brick_index];
                        if (other_brick.y1 <= supported_brick.y2 and supported_brick.y1 <= other_brick.y2 and other_brick.z2 == supported_brick.z1 - 1) continue :supported;
                    }
                }
            }
            if (supported_brick.y1 == supported_brick.y2) {
                if (y_map.getPtr(supported_brick.y1)) |other_bricks| {
                    for (other_bricks.keys()) |other_brick_index| {
                        if (other_brick_index == brick_index) continue;
                        const other_brick = &bricks.items[other_brick_index];
                        if (other_brick.x1 <= supported_brick.x2 and supported_brick.x1 <= other_brick.x2 and other_brick.z2 == supported_brick.z1 - 1) continue :supported;
                    }
                }
            }
            if (z_map.getPtr(supported_brick.z1 - 1)) |other_bricks| {
                for (other_bricks.keys()) |other_brick_index| {
                    if (other_brick_index == brick_index) continue;
                    const other_brick = &bricks.items[other_brick_index];
                    if (other_brick.x1 <= supported_brick.x2 and supported_brick.x1 <= other_brick.x2 and other_brick.y1 <= supported_brick.y2 and supported_brick.y1 <= other_brick.y2) continue :supported;
                }
            }
            break;
        } else count += 1;
    }

    std.debug.print("{}\n", .{count});
}
