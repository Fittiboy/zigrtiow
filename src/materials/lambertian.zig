const std = @import("std");

const root = @import("../root.zig");
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Collision = root.Collision;
const ScatteredRay = root.ScatteredRay;

const Self = @This();
albedo: Vec3,

pub fn scatter(
    self: Self,
    rand: std.Random,
    _: Ray,
    collision: Collision,
) ?ScatteredRay {
    var scatter_dir = collision.normal.add(Vec3.randomUnit(rand));

    while (scatter_dir.nearZero()) {
        scatter_dir = collision.normal.add(Vec3.randomUnit(rand));
    }

    return ScatteredRay{
        .ray = Ray.fromVecs(collision.p, scatter_dir),
        .attenuation = self.albedo,
    };
}
