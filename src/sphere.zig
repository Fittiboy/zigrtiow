const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;
const P3 = root.P3;
const Ray = root.Ray;
const Collision = root.Collision;

const E = root.E;
const Self = @This();
center: Vec3,
radius: E,

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
    const first = (b - sqrt) / a;
    const second = (b + sqrt) / a;

    if (first <= 0 and second <= 0) {
        return .{ .miss = {} };
    } else if (first <= 0) {
        return .{ .inside = second };
    } else return .{ .hit = .{
        .t = first,
        .normal = self.normalAt(ray.at(first)),
    } };
}

pub fn hitBy(self: Self, ray: Ray) bool {
    _, _, const d = self.abDiscriminant(ray);
    return if (d < 0) false else true;
}

fn normalAt(self: Self, point: P3) Vec3 {
    return self.center.to(point).divScalar(self.radius);
}

fn abDiscriminant(self: Self, ray: Ray) [3]E {
    const from_ray = ray.orig.to(self.center);

    const a = ray.dir.lengthSquared();
    // This is not the same b as in the quadratic formula. Since the
    // actual b is -2td, the equation simplifies a bit!
    const b = ray.dir.dot(from_ray);
    const c = from_ray.lengthSquared() - (self.radius * self.radius);

    // The discriminant is simplified as well, factoring out 4, the
    // square root of which cancels out with the 2 in the denominator
    // of the quadratic equation.
    const discriminant = b * b - a * c;
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
        const expected = Collision{ .hit = .{
            .t = 1.0,
            .normal = Vec3.init(0, 0, 1),
        } };

        try testing.expectEqual(expected, coll);
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
    try testing.expectApproxEqAbs(2, b, 0.01);
    try testing.expectApproxEqAbs(1, d, 0.01);
}
