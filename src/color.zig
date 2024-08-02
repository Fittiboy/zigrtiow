const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;

const Self = @This();
r: f64,
g: f64,
b: f64,

pub fn init(r: f64, g: f64, b: f64) Self {
    return .{ .r = r, .g = g, .b = b };
}

pub fn fromVec3(vec: Vec3) Self {
    return .{
        .r = vec.x(),
        .g = vec.y(),
        .b = vec.z(),
    };
}

pub fn writeTo(self: Self, writer: anytype) !void {
    // Translate the [0, 1] floats into bytes
    const rbyte: u8 = @intFromFloat(255.999 * self.r);
    const gbyte: u8 = @intFromFloat(255.999 * self.g);
    const bbyte: u8 = @intFromFloat(255.999 * self.b);

    try writer.print("{d: >3} {d: >3} {d: >3}", .{ rbyte, gbyte, bbyte });
}

test writeTo {
    const color = Self.init(0.5, 0.75, 0.25);
    var buf: [11]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const writer = fbs.writer();
    try color.writeTo(writer);

    const expected = "127 191  63";
    for (expected, buf) |e, f| try testing.expectEqual(e, f);
}
