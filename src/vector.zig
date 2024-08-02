const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");

pub const V = @Vector(3, E);

const Self = @This();
const E = root.E;
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

pub fn add(self: Self, other: Self) Self {
    return .{ .vec = self.vec + other.vec };
}

pub fn sub(self: Self, other: Self) Self {
    return .{ .vec = self.vec - other.vec };
}

pub fn mul(self: Self, other: Self) Self {
    return .{ .vec = self.vec * other.vec };
}

pub fn div(self: Self, other: Self) Self {
    return .{ .vec = self.vec / other.vec };
}

pub fn addScalar(self: Self, scalar: E) Self {
    return .{ .vec = self.vec + @as(V, @splat(scalar)) };
}

pub fn subScalar(self: Self, scalar: E) Self {
    return .{ .vec = self.vec - @as(V, @splat(scalar)) };
}

pub fn mulScalar(self: Self, scalar: E) Self {
    return .{ .vec = self.vec * @as(V, @splat(scalar)) };
}

pub fn divScalar(self: Self, scalar: E) Self {
    return .{ .vec = self.vec / @as(V, @splat(scalar)) };
}

pub fn lengthSquared(self: Self) E {
    return self.dot(self);
}

pub fn length(self: Self) E {
    return @sqrt(lengthSquared(self));
}

pub fn normed(self: Self) Self {
    return self.divScalar(self.length());
}

pub fn abs(self: Self) Self {
    return Self{ .vec = @abs(self.vec) };
}

pub fn positive(self: Self) Self {
    return Self.init(
        @max(self.x(), 0),
        @max(self.y(), 0),
        @max(self.z(), 0),
    );
}

pub fn negative(self: Self) Self {
    return Self.init(
        @min(self.x(), 0),
        @min(self.y(), 0),
        @min(self.z(), 0),
    );
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

pub fn to(self: Self, destination: Self) Self {
    return destination.sub(self);
}

pub fn distanceTo(self: Self, destination: Self) E {
    return self.to(destination).length();
}

pub fn directionTo(self: Self, destination: Self) Self {
    return self.to(destination).normed();
}

test to {
    const start = Self.init(0, 1, 2);
    const dest = Self.init(5, 1, 1);
    const expected = Self.init(5, 0, -1);

    try testing.expectEqualDeep(expected, start.to(dest));
}

pub fn lerp(self: Self, other: Self, a: anytype) Self {
    const info = @typeInfo(@TypeOf(a));
    comptime std.debug.assert(info == .Float or info == .ComptimeFloat);
    return self
        .mulScalar(1 - a)
        .add(other.mulScalar(a));
}

// ***************
// *****TESTS*****
// ***************

test x {
    const vec = Self.init(1, 2, 3);
    try testing.expectApproxEqAbs(1.0, vec.x(), 0.01);
}

test y {
    const vec = Self.init(1, 2, 3);
    try testing.expectApproxEqAbs(2.0, vec.y(), 0.01);
}

test z {
    const vec = Self.init(1, 2, 3);
    try testing.expectApproxEqAbs(3.0, vec.z(), 0.01);
}

test add {
    const u = Self.init(1, 2, 3);
    const v = Self.init(4, 5, 6);
    const sum = u.add(v);
    const expected = Self.init(5, 7, 9);

    try testing.expectEqualDeep(expected, sum);
}

test sub {
    const u = Self.init(1, 2, 3);
    const v = Self.init(4, 5, 6);
    const diff = u.sub(v);
    const expected = Self.init(-3, -3, -3);

    try testing.expectEqualDeep(expected, diff);
}

test mul {
    const u = Self.init(1, 2, 3);
    const v = Self.init(4, 5, 6);
    const prod = u.mul(v);
    const expected = Self.init(4, 10, 18);

    try testing.expectEqualDeep(expected, prod);
}

test div {
    const u = Self.init(1, 2, 3);
    const v = Self.init(4, 5, 6);
    const quot = u.div(v);
    const expected = Self.init(0.25, 0.4, 0.5);

    try testing.expectEqualDeep(expected, quot);
}

test addScalar {
    const u = Self.init(1, 2, 3);
    const sum = u.addScalar(3);
    const expected = Self.init(4, 5, 6);

    try testing.expectEqualDeep(expected, sum);
}

test subScalar {
    const u = Self.init(1, 2, 3);
    const diff = u.subScalar(1);
    const expected = Self.init(0, 1, 2);

    try testing.expectEqualDeep(expected, diff);
}

test mulScalar {
    const u = Self.init(1, 2, 3);
    const prod = u.mulScalar(3);
    const expected = Self.init(3, 6, 9);

    try testing.expectEqualDeep(expected, prod);
}

test divScalar {
    const u = Self.init(1, 2, 3);
    const quot = u.divScalar(2);
    const expected = Self.init(0.5, 1, 1.5);

    try testing.expectEqualDeep(expected, quot);
}

test lengthSquared {
    const vec = Self.init(3, 4, 0);
    const len = vec.lengthSquared();

    try testing.expectApproxEqAbs(25.0, len, 0.01);
}

test length {
    const vec = Self.init(3, 4, 0);
    const len = vec.length();

    try testing.expectApproxEqAbs(5.0, len, 0.01);
}

test normed {
    const vec = Self.init(112, 90, -1);
    const norm = vec.normed();
    const len = norm.length();

    try testing.expectApproxEqAbs(1.0, len, 0.01);
}

test abs {
    const vec = Self.init(112, 90, -1);
    const pos = vec.abs();

    try testing.expectEqualDeep(Self.init(112, 90, 1), pos);
}

test positive {
    const vec = Self.init(1, 0, -5);
    const expected = Self.init(1, 0, 0);

    try testing.expectEqualDeep(expected, vec.positive());
}

test negative {
    const vec = Self.init(1, 0, -5);
    const expected = Self.init(0, 0, -5);

    try testing.expectEqualDeep(expected, vec.negative());
}

test dot {
    const left = Self.init(1, 2, 3);
    const right = Self.init(6, 5, 4);
    const dotted = left.dot(right);

    try testing.expectApproxEqAbs(28, dotted, 0.01);
}

test cross {
    const u = Self.init(1, 2, 3);
    const v = Self.init(6, 5, 4);
    const crossed = u.cross(v);

    try testing.expectApproxEqAbs(-7, crossed.x(), 0.01);
    try testing.expectApproxEqAbs(14, crossed.y(), 0.01);
    try testing.expectApproxEqAbs(-7, crossed.z(), 0.01);
}

test lerp {
    const u = Self.init(0, 1, 3);
    const v = Self.init(2, 3, 9);
    const a = 0.5;
    const lerped = u.lerp(v, a);
    const expected = Self.init(1, 2, 6);

    try testing.expectEqualDeep(expected, lerped);
}

test directionTo {
    const start = Self.init(0, 1, 2);
    const dest = Self.init(5, 1, 1);
    const expected = Self.init(5, 0, -1).divScalar(@sqrt(26.0));

    try testing.expectEqualDeep(expected, start.directionTo(dest));
}

test distanceTo {
    const start = Self.init(0, 1, 2);
    const dest = Self.init(5, 1, 1);
    const expected = @sqrt(26.0);

    try testing.expectApproxEqAbs(expected, start.distanceTo(dest), 0.01);
}
