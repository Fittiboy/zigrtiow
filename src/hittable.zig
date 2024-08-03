const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const P3 = root.P3;
const Ray = root.Ray;
const Sphere = root.Sphere;
const Interval = root.Interval;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub fn initSphere(center: [3]E, radius: E) Self {
        return .{ .sphere = Sphere.init(center, radius) };
    }

    pub const Collision = struct {
        pub const Face = enum { front, back };
        t: E,
        p: P3,
        normal: Vec3,
        face: Face,
    };

    pub fn collisionAt(self: Self, interval: Interval, ray: Ray) ?Collision {
        switch (self) {
            inline else => |hittable| return hittable.collisionAt(interval, ray),
        }
    }

    test initSphere {
        const sphere = Self.initSphere(.{ 0, 0, 0 }, 1);

        try testing.expectEqualDeep(Self{ .sphere = Sphere{
            .center = Vec3.fromArray(.{ 0, 0, 0 }),
            .radius = 1,
        } }, sphere);
    }
};
