const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;
const Ray = root.Ray;

const E = root.E;
const Self = @This();
center: Vec3,
radius: E,

pub const Collision = union(enum) {
    hit: E,
    inside: E,
    miss,
};

pub fn init(center: Vec3, radius: E) Self {
    return .{
        .center = center,
        .radius = radius,
    };
}

pub fn collisionAt(self: Self, ray: Ray) Collision {
    const a, const b, const d = self.abDiscriminant(ray);
    if (d < 0) return .{ .miss = {} };

    const sqrt = @sqrt(d);
    const denom = 2 * a;
    const first = (-b - sqrt) / denom;
    const second = (-b + sqrt) / denom;

    if (first <= 0 and second <= 0) {
        return .{ .miss = {} };
    } else if (first <= 0) {
        return .{ .inside = second };
    } else return .{ .hit = first };
}

pub fn hitBy(self: Self, ray: Ray) bool {
    _, _, const d = self.abDiscriminant(ray);
    return if (d < 0) false else true;
}

fn abDiscriminant(self: Self, ray: Ray) [3]E {
    const from_ray = ray.orig.to(self.center);

    const a = ray.dir.lengthSquared();
    const b = -ray.dir.mulScalar(2).dot(from_ray);
    const c = from_ray.lengthSquared() - (self.radius * self.radius);

    const discriminant = b * b - 4 * a * c;
    return .{ a, b, discriminant };
}

test collisionAt {
    {
        const center = Vec3.init(0, 0, -2);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const coll = sphere.collisionAt(ray);

        try testing.expectEqual(Collision{ .hit = 1.0 }, coll);
    }
    {
        const center = Vec3.init(0, 0, 0);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const coll = sphere.collisionAt(ray);

        try testing.expectEqual(Collision{ .inside = 1.0 }, coll);
    }
    {
        const center = Vec3.init(5, 0, -2);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const coll = sphere.collisionAt(ray);

        try testing.expectEqual(Collision{ .miss = {} }, coll);
    }
}

test hitBy {
    {
        const center = Vec3.init(0, 0, -2);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const hit = sphere.hitBy(ray);

        try testing.expect(hit);
    }
    {
        const center = Vec3.init(0, 0, 0);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const hit = sphere.hitBy(ray);

        try testing.expect(hit);
    }
    {
        const center = Vec3.init(5, 0, -2);
        const sphere = Self.init(center, 1);
        const origin = Vec3.init(0, 0, 0);
        const dir = Vec3.init(0, 0, -1);
        const ray = Ray.init(origin, dir);
        const hit = sphere.hitBy(ray);

        try testing.expect(!hit);
    }
}

test abDiscriminant {
    const center = Vec3.init(0, 0, -2);
    const sphere = Self.init(center, 1);
    const origin = Vec3.init(0, 0, 0);
    const dir = Vec3.init(0, 0, -1);
    const ray = Ray.init(origin, dir);
    const a, const b, const d = sphere.abDiscriminant(ray);

    try testing.expectApproxEqAbs(1, a, 0.01);
    try testing.expectApproxEqAbs(-4, b, 0.01);
    try testing.expectApproxEqAbs(4, d, 0.01);
}
