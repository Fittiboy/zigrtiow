const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");

pub const Vec3 = Vector3(f64);
pub const P3 = Point3(f64);

const Point3 = Vector3;
pub fn Vector3(comptime E: type) type {
    return struct {
        const Self = @This();
        pub const Elem = E;
        pub const V = @Vector(3, E);
        vec: V,

        pub fn init(vx: E, vy: E, vz: E) Self {
            return .{
                .vec = V{ vx, vy, vz },
            };
        }

        pub inline fn x(self: Self) E {
            return self.vec[0];
        }

        pub inline fn y(self: Self) E {
            return self.vec[1];
        }

        pub inline fn z(self: Self) E {
            return self.vec[2];
        }

        pub inline fn add(self: Self, other: Self) Self {
            return .{ .vec = self.vec + other.vec };
        }

        pub inline fn sub(self: Self, other: Self) Self {
            return .{ .vec = self.vec - other.vec };
        }

        pub inline fn mul(self: Self, other: Self) Self {
            return .{ .vec = self.vec * other.vec };
        }

        pub inline fn div(self: Self, other: Self) Self {
            return .{ .vec = self.vec / other.vec };
        }

        pub inline fn addScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec + @as(V, @splat(scalar)) };
        }

        pub inline fn subScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec - @as(V, @splat(scalar)) };
        }

        pub inline fn mulScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec * @as(V, @splat(scalar)) };
        }

        pub inline fn divScalar(self: Self, scalar: E) Self {
            return .{ .vec = self.vec / @as(V, @splat(scalar)) };
        }

        pub fn lengthSquared(self: Self) E {
            return @reduce(.Add, self.vec * self.vec);
        }

        pub fn length(self: Self) E {
            return @sqrt(lengthSquared(self));
        }

        pub fn normed(self: Self) Self {
            return .{ .vec = self.vec / @as(V, @splat(length(self))) };
        }

        pub fn dot(u: Self, v: Self) E {
            return @reduce(.Add, u.vec * v.vec);
        }

        pub fn cross(u: Self, v: Self) Self {
            const uv, const vv = .{ u.vec, v.vec };
            return .{ .vec = .{
                uv[1] * vv[2] - uv[2] * vv[1],
                uv[2] * vv[0] - uv[0] * vv[2],
                uv[0] * vv[1] - uv[1] * vv[0],
            } };
        }

        test x {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(1.0, vec.x(), 0.01);
        }

        test y {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(2.0, vec.y(), 0.01);
        }

        test z {
            const vec = Vec3.init(1, 2, 3);
            try testing.expectApproxEqAbs(3.0, vec.z(), 0.01);
        }

        test add {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(4, 5, 6);
            const sum = u.add(v);
            const expected = Vec3.init(5, 7, 9);

            try testing.expectEqualDeep(expected, sum);
        }

        test sub {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(4, 5, 6);
            const diff = u.sub(v);
            const expected = Vec3.init(-3, -3, -3);

            try testing.expectEqualDeep(expected, diff);
        }

        test mul {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(4, 5, 6);
            const prod = u.mul(v);
            const expected = Vec3.init(4, 10, 18);

            try testing.expectEqualDeep(expected, prod);
        }

        test div {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(4, 5, 6);
            const quot = u.div(v);
            const expected = Vec3.init(0.25, 0.4, 0.5);

            try testing.expectEqualDeep(expected, quot);
        }

        test addScalar {
            const u = Vec3.init(1, 2, 3);
            const sum = u.addScalar(3);
            const expected = Vec3.init(4, 5, 6);

            try testing.expectEqualDeep(expected, sum);
        }

        test subScalar {
            const u = Vec3.init(1, 2, 3);
            const diff = u.subScalar(1);
            const expected = Vec3.init(0, 1, 2);

            try testing.expectEqualDeep(expected, diff);
        }

        test mulScalar {
            const u = Vec3.init(1, 2, 3);
            const prod = u.mulScalar(3);
            const expected = Vec3.init(3, 6, 9);

            try testing.expectEqualDeep(expected, prod);
        }

        test divScalar {
            const u = Vec3.init(1, 2, 3);
            const quot = u.divScalar(2);
            const expected = Vec3.init(0.5, 1, 1.5);

            try testing.expectEqualDeep(expected, quot);
        }

        test lengthSquared {
            const vec = Vec3.init(3, 4, 0);
            const len = vec.lengthSquared();

            try testing.expectApproxEqAbs(25.0, len, 0.01);
        }

        test length {
            const vec = Vec3.init(3, 4, 0);
            const len = vec.length();

            try testing.expectApproxEqAbs(5.0, len, 0.01);
        }

        test normed {
            const vec = Vec3.init(112, 90, -1);
            const norm = vec.normed();
            const len = norm.length();

            try testing.expectApproxEqAbs(1.0, len, 0.01);
        }

        test dot {
            const left = Vec3.init(1, 2, 3);
            const right = Vec3.init(6, 5, 4);
            const dotted = left.dot(right);

            try testing.expectApproxEqAbs(28, dotted, 0.01);
        }

        test cross {
            const u = Vec3.init(1, 2, 3);
            const v = Vec3.init(6, 5, 4);
            const crossed = u.cross(v);

            try testing.expectApproxEqAbs(-7, crossed.x(), 0.01);
            try testing.expectApproxEqAbs(14, crossed.y(), 0.01);
            try testing.expectApproxEqAbs(-7, crossed.z(), 0.01);
        }
    };
}
