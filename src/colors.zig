const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vectors.Vec3;

pub const Color = Vec3;

pub fn writeColor(writer: anytype, color: Color) !void {
    const r = color.x();
    const g = color.y();
    const b = color.z();

    // Translate the [0, 1] floats into bytes
    const rbyte: u8 = @intFromFloat(255.999 * r);
    const gbyte: u8 = @intFromFloat(255.999 * g);
    const bbyte: u8 = @intFromFloat(255.999 * b);

    try writer.print("{d: >3} {d: >3} {d: >3}", .{ rbyte, gbyte, bbyte });
}

test writeColor {
    const color = Color.init(0.5, 0.75, 0.25);
    var buf: [11]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const writer = fbs.writer();
    try writeColor(writer, color);

    const expected = "127 191  63";
    for (expected, buf) |e, f| try testing.expectEqual(e, f);
}

test {
    testing.refAllDecls(@This());
}
