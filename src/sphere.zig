const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;
const P3 = root.P3;
const Ray = root.Ray;
const Collision = root.Collision;
const Interval = root.Interval;
const RefCounted = root.RefCounted;
const Material = root.Material;

const E = root.E;
const Self = @This();
center: Vec3,
radius: E,
mat: RefCounted(Material),

pub fn init(center: [3]E, radius: E, mat: RefCounted(Material)) Self {
    std.debug.assert(radius >= 0);
    const mat_ref = mat.strongRef();
    return .{
        .center = Vec3.fromArray(center),
        .radius = radius,
        .mat = mat_ref,
    };
}

pub fn deinit(self: Self) void {
    self.mat.deinit();
}

pub fn collisionAt(self: Self, interval: Interval, ray: Ray) ?Collision {
    const a, const b, const d = self.abDiscriminant(ray);
    if (d < 0) return null;

    const sqrt = @sqrt(d);
    const first = (b - sqrt) / a;
    const second = (b + sqrt) / a;

    var face = Collision.Face.front;
    const t = if (!interval.surrounds(first)) blk: {
        if (!interval.surrounds(second)) return null;
        face = .back;
        break :blk second;
    } else first;
    var normal = self.normalAt(ray.at(t));
    if (t == second) normal = normal.mulScalar(-1);

    return Collision{
        .t = t,
        .p = ray.at(t),
        .normal = normal,
        .mat = self.mat,
        .face = face,
    };
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
        const mat = try RefCounted(Material).create(testing.allocator);
        defer mat.deinit();
        const sphere = Self.init(.{ 0, 0, -2 }, 1, mat);
        defer sphere.deinit();
        const ray = Ray.init(.{ 0, 0, 0 }, .{ 0, 0, -1 });
        const coll = sphere.collisionAt(Interval.init(0, 100), ray);
        const expected = Collision{
            .t = 1.0,
            .p = P3.fromArray(.{ 0, 0, -1 }),
            .normal = Vec3.fromArray(.{ 0, 0, 1 }),
            .mat = mat,
            .face = .front,
        };

        try testing.expectEqual(expected, coll);
    }
    {
        const mat = try RefCounted(Material).create(testing.allocator);
        defer mat.deinit();
        const sphere = Self.init(.{ 0, 0, 0 }, 1, mat);
        defer sphere.deinit();
        const ray = Ray.init(.{ 0, 0, 0 }, .{ 0, 0, -1 });
        const coll = sphere.collisionAt(Interval.init(0, 100), ray);
        const expected = Collision{
            .t = 1.0,
            .p = P3.fromArray(.{ 0, 0, -1 }),
            .normal = Vec3.fromArray(.{ 0, 0, 1 }),
            .mat = mat,
            .face = .back,
        };

        try testing.expectEqual(expected, coll);
    }
    {
        const mat = try RefCounted(Material).create(testing.allocator);
        defer mat.deinit();
        const sphere = Self.init(.{ 5, 0, -2 }, 1, mat);
        defer sphere.deinit();
        const ray = Ray.init(.{ 0, 0, 0 }, .{ 0, 0, -1 });
        const coll = sphere.collisionAt(Interval.init(0, 100), ray);

        try testing.expectEqual(null, coll);
    }
}

test abDiscriminant {
    const mat = try RefCounted(Material).create(testing.allocator);
    defer mat.deinit();
    const sphere = Self.init(.{ 0, 0, -2 }, 1, mat);
    defer sphere.deinit();
    const ray = Ray.init(.{ 0, 0, 0 }, .{ 0, 0, -1 });
    const a, const b, const d = sphere.abDiscriminant(ray);

    try testing.expectApproxEqAbs(1, a, 0.01);
    try testing.expectApproxEqAbs(2, b, 0.01);
    try testing.expectApproxEqAbs(1, d, 0.01);
}
