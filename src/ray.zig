const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;
const P3 = root.P3;

const Self = @This();
const E = root.E;
orig: P3,
dir: Vec3,

pub fn init(origin: [3]E, direction: [3]E) Self {
    return .{
        .orig = P3.init(origin),
        .dir = Vec3.init(direction),
    };
}

pub fn at(self: Self, t: E) P3 {
    return self.orig.add(self.dir.mulScalar(t));
}

test at {
    {
        const ray = Self.init(
            .{ 1, 0, 1 },
            .{ 0, 1, 0 },
        );
        const pos = ray.at(1);
        const expected = Vec3.init(.{ 1, 1, 1 });

        try testing.expectEqualDeep(expected, pos);
    }

    {
        const ray = Self.init(
            .{ 1, 0, 1 },
            .{ -1, -1, 0 },
        );
        const pos = ray.at(1);
        const expected = Vec3.init(.{ 0, -1, 1 });

        try testing.expectEqualDeep(expected, pos);
    }
}
