const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Interval = root.Interval;

const Self = @This();
r: E,
g: E,
b: E,

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

fn toGamma(self: Self) Self {
    return Self.init(
        linearToGamma(self.r),
        linearToGamma(self.g),
        linearToGamma(self.b),
    );
}

fn linearToGamma(linear: E) E {
    return if (linear > 0) @sqrt(linear) else 0;
}

pub fn writeTo(self: Self, writer: anytype) !void {
    const corr = self.toGamma();
    // Translate the [0, 1] floats into bytes
    const int = Interval.init(0, 0.999);
    const rbyte: u8 = @intFromFloat(255.999 * int.clamp(corr.r));
    const gbyte: u8 = @intFromFloat(255.999 * int.clamp(corr.g));
    const bbyte: u8 = @intFromFloat(255.999 * int.clamp(corr.b));

    try writer.print("{d: >3} {d: >3} {d: >3}", .{ rbyte, gbyte, bbyte });
}

test toGamma {
    const linear = Self.init(0.25, 0.04, 0.64);
    const expected = Self.init(0.5, 0.2, 0.8);

    try testing.expectEqual(expected, linear.toGamma());
}

test writeTo {
    {
        const color = Self.init(1, 1, 1);
        var buf: [11]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try color.writeTo(writer);

        const expected = "255 255 255";
        for (expected, buf) |e, f| try testing.expectEqual(e, f);
    }
    {
        const color = Self.init(0.25, 0.5625, 0.0625);
        var buf: [11]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try color.writeTo(writer);

        const expected = "127 191  63";
        for (expected, buf) |e, f| try testing.expectEqual(e, f);
    }
    {
        const color = Self.init(0, 0, 0);
        var buf: [11]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();
        try color.writeTo(writer);

        const expected = "  0   0   0";
        for (expected, buf) |e, f| try testing.expectEqual(e, f);
    }
}
