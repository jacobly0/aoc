const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const a = gpa.allocator();
    _ = &a;

    const input = if (false)
        \\rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
        \\
    else
        @embedFile("input");

    var boxes: [256][9]struct { label: []const u8, focal_length: u4 } =
        .{.{.{ .label = "", .focal_length = 0 }} ** 9} ** 256;

    var step_it = std.mem.tokenizeAny(u8, input, ",\n");
    while (step_it.next()) |step| {
        var hash: u8 = 0;
        for (0.., step) |i, c| {
            switch (c) {
                '-' => {
                    const label = step[0..i];
                    const box = &boxes[hash];
                    var read_index: usize = 0;
                    var write_index: usize = 0;
                    while (read_index < box.len) : (read_index += 1) {
                        if (!std.mem.eql(u8, box[read_index].label, label)) {
                            box[write_index] = box[read_index];
                            write_index += 1;
                        }
                    }
                    while (write_index < box.len) : (write_index += 1) {
                        box[write_index] = .{ .label = "", .focal_length = 0 };
                    }
                },
                '=' => {
                    const label = step[0..i];
                    const box = &boxes[hash];
                    const focal_length = try std.fmt.parseInt(u4, step[i + 1 ..], 10);
                    for (box) |*slot| {
                        if (std.mem.eql(u8, slot.label, label)) {
                            slot.focal_length = focal_length;
                            break;
                        } else if (slot.label.len == 0 and slot.focal_length == 0) {
                            slot.* = .{
                                .label = label,
                                .focal_length = focal_length,
                            };
                            break;
                        }
                    }
                },
                else => {
                    hash +%= c;
                    hash *%= 17;
                },
            }
        }
    }

    var focusing_power: u64 = 0;
    for (boxes, 1..) |box, box_number| for (box, 1..) |slot, slot_number| {
        focusing_power += box_number * slot_number * slot.focal_length;
    };
    std.debug.print("{}\n", .{focusing_power});
}
