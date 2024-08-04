const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const P3 = root.P3;
const Ray = root.Ray;
const Sphere = root.Sphere;
const Interval = root.Interval;
const RefCounted = root.RefCounted;
const Material = root.Material;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub fn initSphere(center: [3]E, radius: E, mat: RefCounted(Material)) Self {
        return .{ .sphere = Sphere.init(center, radius, mat) };
    }

    pub fn deinit(self: Self) void {
        switch (self) {
            inline else => |hittable| hittable.deinit(),
        }
    }

    pub const Collision = struct {
        const Inner = @This();
        pub const Face = enum { front, back };
        t: E,
        p: P3,
        normal: Vec3,
        mat: RefCounted(Material),
        face: Face,

        pub fn matRef(self: Inner) *Material {
            return self.mat.weakRef();
        }
    };

    pub fn collisionAt(self: Self, interval: Interval, ray: Ray) ?Collision {
        switch (self) {
            inline else => |hittable| return hittable.collisionAt(interval, ray),
        }
    }

    test initSphere {
        const mat = try RefCounted(Material).create(testing.allocator);
        defer mat.deinit();
        mat.data.value = Material.default();
        const sphere = Self.initSphere(.{ 0, 0, 0 }, 1, mat);
        defer sphere.deinit();

        try testing.expectEqualDeep(Self{ .sphere = Sphere{
            .center = Vec3.fromArray(.{ 0, 0, 0 }),
            .radius = 1,
            .mat = mat,
        } }, sphere);
    }
};
