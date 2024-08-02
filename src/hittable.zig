const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Sphere = root.Sphere;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub fn initSphere(center: Vec3, radius: E) Self {
        return .{ .sphere = Sphere.init(center, radius) };
    }

    pub const Collision = struct {
        pub const Face = enum { front, back };
        t: E,
        normal: Vec3,
        face: Face,
    };

    pub fn collisionAt(self: Self, t_min: ?E, t_max: ?E, ray: Ray) ?Collision {
        switch (self) {
            inline else => |hittable| return hittable.collisionAt(t_min, t_max, ray),
        }
    }

    test initSphere {
        const sphere = Self.initSphere(Vec3.init(0, 0, 0), 1);

        try testing.expectEqualDeep(Self{ .sphere = Sphere{
            .center = Vec3.init(0, 0, 0),
            .radius = 1,
        } }, sphere);
    }
};
