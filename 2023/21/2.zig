const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = @embedFile("input");
    const steps = 26501365;

    const width: i32 = @intCast(std.mem.indexOfScalar(u8, input, '\n').?);
    const stride: usize = @intCast(width + 1);
    const height: i32 = @intCast(@divExact(input.len, stride));

    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const start_x: i32 = @intCast(start % stride);
    const start_y: i32 = @intCast(start / stride);

    var indices = std.ArrayList(u32).init(a);
    defer indices.deinit();
    var queue = std.AutoArrayHashMap(struct { x: i32, y: i32, steps: u32 }, void).init(a);
    defer queue.deinit();
    try queue.putNoClobber(.{ .x = start_x, .y = start_y, .steps = 0 }, {});

    var step_list = try std.ArrayList(u32).initCapacity(a, 3);
    defer step_list.deinit();

    var queue_index: usize = 0;
    while (true) : (queue_index += 1) {
        const prev = queue.keys()[queue_index];
        if (prev.steps >= indices.items.len) {
            try indices.append(@intCast(queue_index));
            if (step_list.items.len == 3) break;
        }
        if (prev.x == -@as(i32, @intCast(step_list.items.len)) * width) {
            try step_list.append(prev.steps);
        }

        for ([_]struct { x: i2, y: i2 }{
            .{ .x = 1, .y = 0 },
            .{ .x = 0, .y = 1 },
            .{ .x = -1, .y = 0 },
            .{ .x = 0, .y = -1 },
        }) |step| {
            const x = prev.x + step.x;
            const y = prev.y + step.y;
            if (input[@as(usize, @intCast(@mod(x, width))) + stride * @as(usize, @intCast(@mod(y, height)))] == '#') continue;
            _ = try queue.getOrPutValue(.{ .x = x, .y = y, .steps = prev.steps + 1 }, {});
        }
    }

    std.debug.assert(step_list.items[1] - step_list.items[0] == step_list.items[2] - step_list.items[1]);
    const quotient = @divExact(steps - step_list.items[0], step_list.items[2] - step_list.items[1]);

    var n: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[1]]..indices.items[step_list.items[1] + 1]]) |key| n += @intFromBool(key.y < 0);

    var nw: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[2]]..indices.items[step_list.items[2] + 1]]) |key| nw += @intFromBool(key.x < 0 and key.y >= -height and key.y < 0);

    var ne: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[2]]..indices.items[step_list.items[2] + 1]]) |key| ne += @intFromBool(key.x >= width and key.y >= -height and key.y < 0);

    var w: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[1]]..indices.items[step_list.items[1] + 1]]) |key| w += @intFromBool(key.x < 0 and key.y >= 0 and key.y < height);

    var o: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[2]]..indices.items[step_list.items[2] + 1]]) |key| o += @intFromBool(key.x >= 0 and key.x < width and key.y >= 0 and key.y < height);

    var x: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[1]]..indices.items[step_list.items[1] + 1]]) |key| x += @intFromBool(key.x >= 0 and key.x < width and key.y >= 0 and key.y < height);

    var e: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[1]]..indices.items[step_list.items[1] + 1]]) |key| e += @intFromBool(key.x >= width and key.y >= 0 and key.y < height);

    var sw: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[2]]..indices.items[step_list.items[2] + 1]]) |key| sw += @intFromBool(key.x < 0 and key.y >= height and key.y < 2 * height);

    var se: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[2]]..indices.items[step_list.items[2] + 1]]) |key| se += @intFromBool(key.x >= width and key.y >= height and key.y < 2 * height);

    var s: u64 = 0;
    for (queue.keys()[indices.items[step_list.items[1]]..indices.items[step_list.items[1] + 1]]) |key| s += @intFromBool(key.y >= height);

    var total: u64 = 0;
    total += n;
    for (0..quotient - 1) |i| {
        total += nw;
        total += i * o;
        total += (i + 1) * x;
        total += ne;
    }
    total += w;
    total += (quotient - 1) * o;
    total += quotient * x;
    total += e;
    for (0..quotient - 1) |i| {
        total += sw;
        total += i * o;
        total += (i + 1) * x;
        total += se;
    }
    total += s;
    std.debug.print("{}\n", .{total});
}
