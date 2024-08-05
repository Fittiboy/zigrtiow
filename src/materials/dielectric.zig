const std = @import("std");

const root = @import("../root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Collision = root.Collision;
const ScatteredRay = root.ScatteredRay;

const Self = @This();
ref_index: E,

pub fn scatter(
    self: Self,
    _: std.Random,
    r_in: Ray,
    collision: Collision,
) ?ScatteredRay {
    const index = if (collision.face == .front) 1.0 / self.ref_index else self.ref_index;
    return .{
        .ray = Ray.fromVecs(collision.p, r_in.dir.refract(collision.normal, index)),
        .attenuation = Vec3.init(1, 1, 1),
    };
}
